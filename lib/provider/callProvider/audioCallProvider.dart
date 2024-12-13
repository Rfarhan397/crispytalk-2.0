import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioCallProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  bool isMuted = false;
  bool inCall = false;
  bool isUserJoined = false;

  Timer? _callTimer;
  DateTime? _callStartTime;
  String callDuration = "00:00";
  bool isTimerRunning = false;

  AudioCallProvider();

  Future<void> startCall(String callId) async {
    try {
      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDoc.collection('candidates').add({
          'candidate': candidate.toMap(),
        });
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'audio') {
          isUserJoined = true;
          notifyListeners();
        }
      };

      localStream = await _getUserMedia();
      localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, localStream!);
      });

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await callDoc.set({
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        },
        'status': 'active' // Set the call status to active
      });

      callDoc.snapshots().listen(
            (snapshot) async {
          if (snapshot.exists) {
            var data = snapshot.data();
            if (data != null && data['answer'] != null) {
              RTCSessionDescription answer = RTCSessionDescription(
                  data['answer']['sdp'], data['answer']['type']);
              await _peerConnection!.setRemoteDescription(answer);
              isUserJoined = true;
              _startCallTimer();
              notifyListeners();
            }
            // Listen for call status changes
            if (data?['status'] == 'ended') {
              await endCall(callId,
                  context: null); // Handle ending call on this side
            }
          }
        },
      );

      callDoc.collection('candidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var data = change.doc.data()!;
            _peerConnection?.addCandidate(RTCIceCandidate(
                data['candidate']['candidate'],
                data['candidate']['sdpMid'],
                data['candidate']['sdpMLineIndex']));
          }
        }
      });

      inCall = true;
      notifyListeners();
    } catch (e) {
      print("Error starting call: $e");
    }
  }

  Future<void> joinCall(String callId) async {
    try {
      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDoc.collection('candidates').add({
          'candidate': candidate.toMap(),
        });
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == 'audio') {
          isUserJoined = true;
          notifyListeners();
        }
      };

      localStream = await _getUserMedia();
      localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, localStream!);
      });

      var offerSnapshot = await callDoc.get();
      if (offerSnapshot.exists) {
        var offerData = offerSnapshot.data();
        if (offerData != null && offerData['offer'] != null) {
          RTCSessionDescription offer = RTCSessionDescription(
              offerData['offer']['sdp'], offerData['offer']['type']);
          await _peerConnection!.setRemoteDescription(offer);

          RTCSessionDescription answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);

          await callDoc.update({
            'answer': {
              'sdp': answer.sdp,
              'type': answer.type,
            },
            'status': 'active' // Set the call status to active
          });
          isUserJoined = true;
          _startCallTimer();
          notifyListeners();
        }
      }

      callDoc.collection('candidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var data = change.doc.data()!;
            _peerConnection?.addCandidate(RTCIceCandidate(
                data['candidate']['candidate'],
                data['candidate']['sdpMid'],
                data['candidate']['sdpMLineIndex']));
          }
        }
      });

      inCall = true;
      notifyListeners();
    } catch (e) {
      log("Error joining call: $e");
    }
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    isTimerRunning = true;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final duration = now.difference(_callStartTime!);
      final minutes =
      duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      callDuration = "$minutes:$seconds";
      notifyListeners();
    });
  }

  Future<void> endCall(String callId, {required BuildContext? context}) async {
    try {
      // Stop the local audio track to disable the microphone

      if (localStream != null) {
        localStream!.getAudioTracks().forEach((track) {
          track.stop(); // Stop the audio track
        });

        await localStream!.dispose(); // Dispose of the media stream
        localStream = null; // Clear the reference
      }

      // Update Firestore document to indicate the call has ended
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended', // Set the status to ended
      });

      // Clean up peer connection
      if (_peerConnection != null) {
        await _peerConnection!.close(); // Close the peer connection
        _peerConnection = null; // Clear the reference
      }

      // Stop and clear the call timer
      _stopCallTimer();
      callDuration = "00:00"; // Reset the call duration
      inCall = false; // Update the call state
      isMuted = false; // Reset mute state
      isUserJoined = false; // Reset user joined state
      notifyListeners(); // Notify listeners about state changes
    } catch (e) {
      log('Error ending the call: $e');
    }
  }

  void _stopCallTimer() {
    if (_callTimer != null && _callTimer!.isActive) {
      _callTimer!.cancel();
      isTimerRunning = false;
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    final pc = await createPeerConnection(configuration);
    return pc;
  }

  Future<MediaStream> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': false, // Disable video for audio-only call
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  void toggleMute() {
    if (localStream != null) {
      final audioTracks = localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        final audioTrack = audioTracks.first;
        isMuted = !isMuted;
        audioTrack.enabled = !isMuted;
        // Log the mute state
        print("Audio Track Muted: $isMuted");
        notifyListeners();
      } else {
        print("No audio tracks found!");
      }
    } else {
      print("Local stream is null!");
    }
  }

  @override
  void dispose() {
    localStream?.dispose();
    _peerConnection?.close(); // Ensure peer connection is closed
    super.dispose();
  }
}