import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebrtcProvider with ChangeNotifier {
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
  bool isPiPMode = false; // Track whether PiP mode is active
  double pipWidth = 120; // Width of the PiP window
  double pipHeight = 160; // Height of the PiP window

  // Call duration variables
  Timer? _callTimer;
  DateTime? _callStartTime;
  String callDuration = "00:00"; // To show the duration in the format mm:ss
  bool isTimerRunning = false;

  CallProvider() {
    initRenderers();
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> startCall(String callId,{bool audioOnly = false}) async {
    isAudioCall = audioOnly; // Set the call type
    try {
      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate != null) {
          callDoc.collection('candidates').add({
            'candidate': candidate.toMap(),
          });
        }
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == (isAudioCall ? 'audio' : 'video')) {
          remoteRenderer.srcObject = event.streams[0];
          isUserJoined = true;
          notifyListeners();
        }
      };

      localStream = await _getUserMedia(audioOnly: isAudioCall);
      if (!isAudioCall) {
        localRenderer.srcObject = localStream; // Only set for video calls
      }
      if (isAudioCall) {
        await AudioOutputManager.setAudioOutput("earpiece");
      }
      // localRenderer.srcObject = localStream;

      localStream?.getTracks().forEach((track) {
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
          }
          // Start timer when user joins
          if (data != null && data['userJoined'] == true) {
            _startCallTimer();
          }
        }
      });


      // initCallListener(callId);

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

  // Timer to track the call duration
  void _startCallTimer() {
    _callStartTime = DateTime.now();
    isTimerRunning = true;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final duration = now.difference(_callStartTime!);
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      callDuration = "$minutes:$seconds";
      notifyListeners();
    });
  }

  // Stop the timer and return the total call duration
  void _stopCallTimer() {
    if (_callTimer != null && _callTimer!.isActive) {
      _callTimer!.cancel();
      isTimerRunning = false;
    }
  }

  Future<void> joinCall(String callId,{bool audioOnly = false}) async {
    isAudioCall = audioOnly; // Set the call type
    try {

      final callDoc = _firestore.collection('calls').doc(callId);
      _peerConnection = await _createPeerConnection();

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate != null) {
          callDoc.collection('candidates').add({
            'candidate': candidate.toMap(),
          });
        }
      };

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.track.kind == (isAudioCall ? 'audio' : 'video')) {
          remoteRenderer.srcObject = event.streams[0];
          isUserJoined = true;
          notifyListeners();
        }
      };

      localStream = await _getUserMedia(audioOnly: isAudioCall);
      if (!isAudioCall) {
        localRenderer.srcObject = localStream; // Only set for video calls
      }
      if (isAudioCall) {
        await AudioOutputManager.setAudioOutput("earpiece");
      }
      localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, localStream!);
      });
      // localRenderer.srcObject = localStream;

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
        }
      }

      // initCallListener(callId);

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

  // Future<void> endCall() async {
  //   _stopCallTimer();
  //   _peerConnection?.close();
  //   _peerConnection = null;
  //   localStream?.dispose();
  //   callDuration = "00:00";
  //   remoteRenderer.srcObject = null;
  //   localRenderer.srcObject = null;
  //   inCall = false;
  //   isMuted = false;
  //   isUserJoined = false;
  //   notifyListeners();
  // }


  // End call function
  Future<void> endCall(String callId,
      {
        bool remoteEnd = false,
        String type = "patient",
        bool userJoined = false,
        String id = ""
      }) async {
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
      callDuration = "00:00";
      remoteRenderer.srcObject = null;
      localRenderer.srcObject = null;
      inCall = false;
      isMuted = false;
      isUserJoined = false;
      notifyListeners();



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
    final pc = await createPeerConnection(configuration);
    return pc;
  }



  Future<MediaStream> _getUserMedia({bool audioOnly = false}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': audioOnly
          ? false
          : {
        'facingMode': 'user',
      },
    };
    return await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  void toggleMute() {
    if (localStream != null) {
      final audioTrack = localStream!.getAudioTracks().first;
      isMuted = !isMuted;
      audioTrack.enabled = !isMuted; // Disable or enable audio
      notifyListeners();
    }
  }

  // // Switch audio output to earpiece or loudspeaker
  // Future<void> switchToEarpiece() async {
  //   try {
  //     // Set the audio output to the earpiece
  //     await Helper.setAudioOutput(RTCAudioOutputType.earpiece);
  //   } catch (e) {
  //     print("Error switching to earpiece: $e");
  //   }
  // }
  //
  // Future<void> switchToLoudspeaker() async {
  //   try {
  //     // Set the audio output to the loudspeaker
  //     await Helper.setAudioOutput(RTCAudioOutputType.speaker);
  //   } catch (e) {
  //     print("Error switching to loudspeaker: $e");
  //   }
  // }

  Future<void> switchCamera() async {
    if (localStream != null) {
      // Stop all current tracks and dispose of the stream
      for (var track in localStream!.getTracks()) {
        track.stop();
      }
      localStream!.dispose();

      // Switch between front and back camera
      isFrontCamera = !isFrontCamera;

      // Set new constraints for the camera
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': isFrontCamera ? 'user' : 'environment',
        },
      };

      // Create a new media stream with the new camera direction
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

      // Update the local renderer with the new stream
      localRenderer.srcObject = localStream;

      // Access the existing video sender from the peer connection
      var senders = await _peerConnection!.getSenders();
      for (var sender in senders) {
        if (sender.track?.kind == 'video') {
          // Remove the existing video track
          await _peerConnection!.removeTrack(sender);
          break; // Exit loop after removing the video track
        }
      }

      // Add the new video track to the peer connection
      var newVideoTrack = localStream!.getVideoTracks().first;
      await _peerConnection!.addTrack(newVideoTrack, localStream!);

      // Create an offer to send to the remote peer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      // Update the call document with the new offer
      final callDoc = _firestore.collection('calls').doc("23");
      await callDoc.update({
        'offer': {
          'sdp': offer.sdp,
          'type': offer.type,
        }
      });

      // Notify the other peer about the camera switch
      // Note: You might need to listen to remote offers to handle their answer appropriately

      notifyListeners(); // Notify UI to update
    }
  }


  // Method to toggle PiP mode
  void togglePiP() {
    isPiPMode = !isPiPMode;
    notifyListeners();
  }

  @override
  void dispose() {
    localStream?.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> initCallListener(String callId) async {
    final callDoc = _firestore.collection('calls').doc(callId);

    callDoc.snapshots().listen((snapshot) async {
      if (snapshot.exists) {
        var data = snapshot.data();

        if (data != null && data['offer'] != null) {
          RTCSessionDescription offer = RTCSessionDescription(
              data['offer']['sdp'],
              data['offer']['type']
          );

          // Add null check for peerConnection
          if (_peerConnection != null) {
            // Ensure the connection state is appropriate
            if (_peerConnection!.signalingState == RTCSignalingState.RTCSignalingStateStable) {
              await _peerConnection!.setRemoteDescription(offer);

              RTCSessionDescription answer = await _peerConnection!.createAnswer();
              await _peerConnection!.setLocalDescription(answer);

              await callDoc.update({
                'answer': {
                  'sdp': answer.sdp,
                  'type': answer.type,
                }
              });
            } else {
              log('Peer connection is not in a stable state. Current state: ${_peerConnection!.signalingState}');
            }
          } else {
            log('Peer connection is null.');
          }
        }
        // Detect if the call has ended
        if (data != null && data['status'] == 'ended') {
          log('Call has ended');
          endCall(callId, remoteEnd: true); // Automatically end call on this side
        }
      } else {
        log('Call document does not exist.');
      }
    });
  }

// Future<void> switchAudioOutput(RTCAudioOutputType type) async {
//
//   try {
//
//     await navigator.mediaDevices.setAudioOutput(type);
//
//   } catch (e) {
//
//     print("Error switching audio output: $e");
//
//   }
//
// }

}
class AudioOutputManager {
  static const MethodChannel _channel = MethodChannel('audio_output');
  static Future<void> setAudioOutput(String type) async {
    try {
      await _channel.invokeMethod('setAudioOutput', {'type': type});
    } on PlatformException catch (e) {
      log("Failed to set audio output: '${e.message}'.");
    }

  }

}