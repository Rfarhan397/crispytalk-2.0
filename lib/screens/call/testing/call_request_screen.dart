import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/screens/call/testing/provider/webrtc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';

class CallRequestScreen extends StatefulWidget {
  final String callID,doctorName,doctorImage;
  final bool isVideo;
  const CallRequestScreen({super.key,
    required this.callID,
    required this.doctorName,
    required this.doctorImage, required this.isVideo
  });

  @override
  State<CallRequestScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<CallRequestScreen> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<WebrtcProvider>().startCall(widget.callID,audioOnly: !widget.isVideo);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
          child: Consumer<WebrtcProvider>(
            builder: (context, provider, child){
              return Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.h,
                    color: Colors.amber,
                  ),

                  if(provider.isUserJoined)...[
                    if(widget.isVideo)
                      Container(
                        color: Colors.black,
                        child: RTCVideoView(
                            mirror: false,
                            provider.remoteRenderer),
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
                                    provider.localRenderer
                                ),
                              ),
                            ),
                          )
                      )

                  ]else...[
                    Positioned(
                        top: 10.h,
                        left: 35.w,
                        child: Column(
                          children: [
                            Container(
                              width: 30.w,
                              height: 30.w,
                              child: ClipRRect(
                                child: Image.network(widget.doctorImage),
                              ),
                            ),
                            SizedBox(height: 3.h,),
                            AppTextWidget(
                              text: "Dr. ${widget.doctorName}",
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                            SizedBox(height: 3.h,),
                            if(!provider.isUserJoined)
                              const AppTextWidget(
                                text: "Ringing",
                                fontSize: 16.0,
                                color: Colors.white,
                              )
                          ],
                        )
                    ),
                  ],

                  Positioned(
                      bottom: 10.w,
                      child: Container(
                        width: 100.w,
                        child: Column(
                          children: [
                            if(provider.isUserJoined)
                              AppTextWidget(
                                text: "Dr. ${widget.doctorName}",
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
                                    provider.endCall(
                                        widget.callID,remoteEnd: true,userJoined: provider.isUserJoined);
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
