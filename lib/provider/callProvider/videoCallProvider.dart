import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart' as getX;
import 'package:get/get_core/src/get_main.dart';

class VideoCallProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  bool isMuted = false;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool inCall = false;
  bool isFrontCamera = true;
  bool isUserJoined = false;
  bool isAudioCall = false;

  // PiP variables
  double pipWidth = 120;
  double pipHeight = 160;

  // Call duration variables
  Timer? _callTimer;
  DateTime? _callStartTime;
  String callDuration = "0:00";
  bool isTimerRunning = false;

  VideoCallProvider() {
    initRenderers();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> startCall(String callId, {bool audioOnly = false}) async {
    isAudioCall = audioOnly;
    try {
      await initRenderers();
      localStream = await _getUserMedia(audioOnly: isAudioCall);

      if (localStream == null) {
        log("Error: Failed to initialize local stream.");
        return;
      }

      if (!isAudioCall) {
        localRenderer.srcObject = localStream;
      }

      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();
      if (_peerConnection == null) {
        log("Error: Failed to create peer connection.");
        return;
      }

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDoc.collection('candidates').add({
          'candidate': candidate.toMap(),
        });
        log("ICE candidate added: ${candidate.toMap()}");
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == (isAudioCall ? 'audio' : 'video')) {
          remoteRenderer.srcObject = event.streams[0];
          isUserJoined = true;
          log("Remote track received and assigned.");
          notifyListeners();
        }
      };

      localStream!.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, localStream!);
      });

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await callDoc.set({
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        }
      });

      callDoc.snapshots().listen((snapshot) async {
        if (snapshot.exists) {
          var data = snapshot.data();
          if (data != null && data['answer'] != null) {
            RTCSessionDescription answer = RTCSessionDescription(
                data['answer']['sdp'], data['answer']['type']);
            await _peerConnection!.setRemoteDescription(answer);
            isUserJoined = true;
            _startCallTimer();
            notifyListeners();
            log("Remote answer set.");
          }
        }
      });

      callDoc.collection('candidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            var data = change.doc.data()!;
            _peerConnection?.addCandidate(RTCIceCandidate(
                data['candidate']['candidate'],
                data['candidate']['sdpMid'],
                data['candidate']['sdpMLineIndex']));
            log("Added remote ICE candidate: ${data['candidate']}");
          }
        }
      });

      inCall = true;
      notifyListeners();
    } catch (e) {
      print("Error starting call: $e");
    }
  }

  Future<void> joinCall(String callId, {bool audioOnly = false}) async {
    isAudioCall = audioOnly;
    try {
      await initRenderers();
      localStream = await _getUserMedia(audioOnly: isAudioCall);

      if (localStream == null) {
        log("Error: Failed to initialize local stream.");
        return;
      }

      if (!isAudioCall) {
        localRenderer.srcObject = localStream;
      }

      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();
      if (_peerConnection == null) {
        log("Error: Failed to create peer connection.");
        return;
      }

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        callDoc.collection('candidates').add({
          'candidate': candidate.toMap(),
        });
        log("ICE candidate added: ${candidate.toMap()}");
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == (isAudioCall ? 'audio' : 'video')) {
          remoteRenderer.srcObject = event.streams[0];
          isUserJoined = true;
          log("Remote track received and assigned.");
          notifyListeners();
        }
      };

      localStream!.getTracks().forEach((track) {
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
            }
          });
          isUserJoined = true;
          _startCallTimer();
          notifyListeners();
          log("Local answer set and sent to remote.");
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
            log("Added remote ICE candidate: ${data['candidate']}");
          }
        }
      });

      inCall = true;
      notifyListeners();
    } catch (e) {
      log("Error joining call: $e");
    }
  }

  Future<void> endCall(String callId,
      {bool remoteEnd = false, required BuildContext context}) async {
    try {
      if (!remoteEnd) {
        await _firestore.collection('calls').doc(callId).update({
          'status': 'ended',
        });
      }
      _stopCallTimer();
      _peerConnection?.close();
      _peerConnection = null;
      localStream?.dispose();
      callDuration = "0:00";
      remoteRenderer.srcObject = null;
      localRenderer.srcObject = null;
      inCall = false;
      isMuted = false;
      isUserJoined = false;
      notifyListeners();

      Get.back();
    } catch (e) {
      log('Error ending the call: $e');
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    return await createPeerConnection(configuration);
  }

  Future<MediaStream> _getUserMedia({bool audioOnly = false}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': audioOnly ? false : {'facingMode': 'user'},
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  void toggleMute() {
    if (localStream != null) {
      final audioTrack = localStream!.getAudioTracks().first;
      isMuted = !isMuted;
      audioTrack.enabled = !isMuted;
      notifyListeners();
      log("Mute toggled: $isMuted");
    }
  }

  void switchCamera(String callID) async {
    if (localStream != null) {
      // Stop all current tracks in the local stream
      localStream!.getTracks().forEach((track) {
        track.stop();
      });

      // Dispose of the old local stream
      localStream!.dispose();

      // Switch the camera
      isFrontCamera = !isFrontCamera;
      final mediaConstraints = {
        'audio': true,
        'video': {'facingMode': isFrontCamera ? 'user' : 'environment'},
      };

      // Get the new media stream with the switched camera
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Set the new local stream to the local renderer
      localRenderer.srcObject = localStream;

      // Add new tracks to the peer connection
      localStream!.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, localStream!);
      });

      log("Camera switched.");
      notifyListeners();
    }
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    isTimerRunning = true;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isTimerRunning) {
        final now = DateTime.now();
        final duration = now.difference(_callStartTime!);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        final seconds = duration.inSeconds.remainder(60);

        // Format the duration string based on the elapsed time
        if (hours > 0) {
          callDuration =
          "$hours:${minutes.toString().padLeft(2, '0')}"; // For example: "1:37"
        } else {
          callDuration =
          "${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}"; // For example: "0:01"
        }

        notifyListeners();
      }
    });
  }

  void _stopCallTimer() {
    isTimerRunning = false;
    _callTimer?.cancel();
    _callTimer = null;
    callDuration = "0:00";
    notifyListeners();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    _peerConnection?.dispose();
    localStream?.dispose();
    super.dispose();
  }
}