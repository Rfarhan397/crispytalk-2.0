import 'dart:developer';

import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/screens/call/testing/provider/webrtc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';


import '../../../constant.dart';
import '../../../model/services/fcm/fcm_services.dart';
import '../../../model/services/fcm/rehman_fcm.dart';

class VideoCallAcceptScreen extends StatefulWidget {
  final String callID,doctorName,doctorImage,id,patientToken;
  final bool isVideo;
  const VideoCallAcceptScreen({super.key,
    required this.callID,
    required this.doctorName,
    required this.doctorImage, required this.isVideo, required this.id, required this.patientToken,
  });

  @override
  State<VideoCallAcceptScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallAcceptScreen> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<WebrtcProvider>().joinCall(widget.callID,audioOnly: !widget.isVideo);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
          child: Consumer<WebrtcProvider>(
            builder: (context,provider, child){
              return Stack(
                children: [
                  if(widget.isVideo)
                    Container(
                      color: Colors.black,
                      child: RTCVideoView(provider.remoteRenderer),
                    ),
                  if(widget.isVideo)
                    Positioned(
                        top: 10.w,
                        right: 5.w,
                        child: SizedBox(
                          width: 40.w,
                          height: 60.w,
                          child:  ClipRRect(
                            borderRadius: BorderRadius.circular(5.w),
                            child: Container(
                              color: Colors.black,
                              child: RTCVideoView(
                                  mirror: true,
                                  provider.localRenderer),
                            ),
                          ),
                        )
                    ),

                  if(!widget.isVideo)
                    Container(
                      width: 100.w,
                      height: 100.h,
                      color: Colors.amber,
                    ),

                  Positioned(
                      bottom: 10.w,
                      child: SizedBox(
                        width: 100.w,
                        child: Column(
                          children: [
                            AppTextWidget(
                              text: widget.doctorName,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            SizedBox(height: 3.h,),
                            AppTextWidget(
                              text: provider.callDuration,
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            SizedBox(height: 3.h,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    final fcm = FCMServiceR();
                                    fcm.sendNotification(
                                        widget.patientToken,
                                        "Dr. ${widget.doctorName} has ended your call",
                                        "Your ${widget.isVideo ? "Video" : "Audio"} call are ended",
                                        auth.currentUser?.uid.toString() ?? ""
                                    );
                                    provider.endCall(
                                        widget.callID,
                                        remoteEnd: true,
                                        type: "doctor",
                                        id: widget.id,
                                        userJoined: provider.isUserJoined
                                    );
                                  },
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(50.w),
                                    ),
                                    child: const Center(child: Icon(Icons.call_end, color: Colors.white)),
                                  ),
                                ),

                                SizedBox(width: 5.w,),
                                GestureDetector(
                                  onTap: (){
                                    provider.toggleMute();
                                  },
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(50.w),
                                    ),
                                    child: Center(
                                        child:
                                        Icon(
                                            provider.isMuted ?  Icons.mic_off : Icons.mic,
                                            color: Colors.white)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                  )

                ],
              );
            },
          )
      ),
    );
  }
}
