import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constant.dart';
import '../../../model/res/constant/app_utils.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/button_widget.dart';
import '../../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../../provider/callProvider/audioCallProvider.dart';

class AudioCallScreen extends StatefulWidget {
  final String callId;
  final bool isCaller;
  final String callerImage;
  final String callerName;

  const AudioCallScreen({
    super.key,
    required this.callId,
    required this.isCaller,
    required this.callerImage,
    required this.callerName,
  });

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioCallProvider(),
      child: Scaffold(
        body: AudioCallWidget(
          callId: widget.callId,
          isCaller: widget.isCaller,
          callerImage: widget.callerImage,
          callerName: widget.callerName,
        ),
      ),
    );
  }
}

class AudioCallWidget extends StatefulWidget {
  final String callId;
  final bool isCaller;
  final String callerImage;
  final String callerName;
  const AudioCallWidget({super.key,
    required this.callId,
    required this.isCaller,
    required this.callerImage,
    required this.callerName,
  });

  @override
  _AudioCallWidgetState createState() => _AudioCallWidgetState();
}

class _AudioCallWidgetState extends State<AudioCallWidget> {
  late AudioCallProvider callProvider;
  late Stream<DocumentSnapshot> callStatusStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callProvider = Provider.of<AudioCallProvider>(context, listen: false);
      if (widget.isCaller) {
        _startOrJoinCall();
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
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
    // Start listening to the call document for real-time status updates
    callStatusStream = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.callId)
        .snapshots();

    // Listen to the call status in real time
    callStatusStream.listen(
          (snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          if (data['status'] == 'ended') {
            _endCall();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioCallProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      provider.callDuration,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.isUserJoined ? 'Connected' : 'Calling ...',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 20.w,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedShimmerImageWidget(
                            imageUrl: widget.callerImage),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.callerName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mute button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor:
                        provider.isMuted ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        provider.toggleMute();
                      },
                      child: Icon(
                        provider.isMuted ? Icons.mic_off : Icons.mic,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 40),
                    // End call button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _endCall();
                      },
                      child: const Icon(
                        Icons.call_end,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              text: 'Accept Audio Call Request',
              fontWeight: FontWeight.w600,
              fontSize: 18
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
                    onClicked: () async {
                      Get.back();
                      _endCall();
                    }, width: 20.w, fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ButtonWidget(
                    height: 44,
                    width: 20.w,
                    fontWeight: FontWeight.w500,
                    text: 'Start',
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