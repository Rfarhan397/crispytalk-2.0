import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../constant.dart';
import '../../../model/res/constant/app_utils.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/button_widget.dart';
import '../../../provider/callProvider/videoCallProvider.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final bool isCaller;
  final String callerImage;
  final String callerName;

  const VideoCallScreen({
    super.key,
    required this.callId,
    required this.isCaller,
    required this.callerImage,
    required this.callerName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoCallProvider(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: VideoCallWidget(
          callId: widget.callId,
          isCaller: widget.isCaller,
          callerImage: widget.callerImage,
          callerName: widget.callerName,
        ),
      ),
    );
  }
}

class VideoCallWidget extends StatefulWidget {
  final String callId;
  final bool isCaller;
  final String callerImage;
  final String callerName;

  const VideoCallWidget({
    super.key,
    required this.callId,
    required this.isCaller,
    required this.callerImage,
    required this.callerName,
  });

  @override
  _VideoCallWidgetState createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  late VideoCallProvider callProvider;
  late Stream<DocumentSnapshot> callStatusStream;

  @override
  void initState() {
    super.initState();
    callProvider = Provider.of<VideoCallProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isCaller) {
        _startOrJoinCall();
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => dialogWidget(),
        );
      }
    });
  }

  Future<void> _startOrJoinCall() async {
    if (widget.isCaller) {
      await callProvider.startCall(widget.callId);
    } else {
      await callProvider.joinCall(widget.callId);
    }

    // Listen to call status in real-time **after starting or joining the call**
    callStatusStream = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots();

    callStatusStream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data['status'] == 'ended') {
          Get.back();
          _endCall();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoCallProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // Remote Video Stream taking full height and width
            provider.isUserJoined
                ? RTCVideoView(
              filterQuality: FilterQuality.medium,
              provider.remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
                : Center(
              child: AppTextWidget(
                text: 'Calling ...',
                color: whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            // Local Video Stream in Picture-in-Picture (PiP) with rounded borders
            Positioned(
              bottom: 2.h,
              right: 5.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 28.h,
                  width: 32.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: RTCVideoView(
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    provider.localRenderer,
                    mirror: true,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
            ),
            // Caller Information
            Positioned(
              top: 5.h,
              left: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.callDuration,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 2.h,
              left: 5.w,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
                decoration: BoxDecoration(
                  color: const Color(0xff1f2c34),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mute button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        provider.toggleMute();
                      },
                      child: Icon(
                        provider.isMuted ? Icons.mic_off : Icons.mic,
                        size: 26,
                        color: const Color(0xff1f2c34),
                      ),
                    ),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     shape: const CircleBorder(),
                    //     padding: const EdgeInsets.all(8),
                    //     backgroundColor: Colors.white,
                    //   ),
                    //   onPressed: () {
                    //     provider.switchCamera(widget.callId);
                    //   },
                    //   child: const Icon(
                    //     Icons.video_camera_back,
                    //     size: 26,
                    //     color: Color(0xff1f2c34),
                    //   ),
                    // ),
                    // End call button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _endCall();
                      },
                      child: const Icon(
                        Icons.call_end,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _endCall() async {
    Get.back();
    callProvider.endCall(widget.callId, context: context);
    AppUtils().showToast(text:  'Call Ended');
  }

  Dialog dialogWidget() {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: whiteColor,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextWidget(
              text: 'Accept Video Call Request',
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            SizedBox(height: 1.5.h),
            AppTextWidget(
              text: '${widget.callerName} is calling you...',
              color: customGrey,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    height: 44,
                    backgroundColor: Colors.black,
                    text: 'Cancel',
                    width: 20.w,
                    fontWeight: FontWeight.w500,
                    onClicked: () async {
                      Get.back();
                      _endCall();
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ButtonWidget(
                    height: 44,
                    text: 'Start',
                    width: 20.w,
                    fontWeight: FontWeight.w500,
                    onClicked: () {
                      Get.back();
                      _startOrJoinCall();
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    callProvider.dispose();
    super.dispose();
  }
}