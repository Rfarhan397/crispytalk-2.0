import 'package:crispy/model/res/widgets/app_text_field.dart';
import 'package:crispy/model/res/widgets/button_widget.dart';
import 'package:crispy/screens/call/testing/provider/webrtc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CallStatusScreen extends StatelessWidget {
   CallStatusScreen({Key? key}) : super(key: key);

  TextEditingController controller =  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              SizedBox(height: 20.w,),
              AppTextField(
                  hintText: "hintText",
                  controller: controller,
              ),
              SizedBox(height: 10.w,),


              Consumer<WebrtcProvider>(
               builder: (context, provider, child){
                 return Row(
                   children: [
                     Expanded(
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: ButtonWidget(
                               text: "Call Now", onClicked: (){
                                 provider.startCall("12",audioOnly: true);
                           },
                               width: 30.w,
                               height: 60,
                               fontWeight:FontWeight.normal
                           ),
                         )),
                     Expanded(
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: ButtonWidget(
                               text: "Received Call", onClicked: (){
                                 provider.joinCall("12",audioOnly: true);
                           },
                               width: 30.w,
                               height: 60,
                               fontWeight:FontWeight.normal
                           ),
                         ))
                   ],
                 );
               },
              )



            ],
          ),
        ),
      ),
    );
  }
}
