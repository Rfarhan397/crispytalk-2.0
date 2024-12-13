import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../provider/notification/notificationProvider.dart';

class SettingNotificationScreen extends StatelessWidget {
  const SettingNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final switchState = Provider.of<NotificationProvider>(context);


    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.transparent,
        leading: const AppBackButton(),
        centerTitle: true,
        title: const AppTextWidget(text: 'Notifications',color: primaryColor,fontSize: 18,fontWeight: FontWeight.w700,),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 4.h,),
            Container(
              width: 80.w,
              padding:  EdgeInsets.symmetric(horizontal: 16.0,vertical: 2.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppTextWidget(text:
                    'On/Off',
                      color: Colors.white, // Text color
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                  ),
                  CustomSwitch(
                    isOn: switchState.isSwitched,
                    onTap: () {
                      switchState.toggleSwitch();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CustomSwitch extends StatelessWidget {
  final bool isOn;
  final VoidCallback onTap;

  CustomSwitch({required this.isOn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.0,
        height: 20.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(30.0),
          color: isOn ? primaryColor : primaryColor, // Change color based on the switch state
        ),
        child: Stack(
          children: [
            // The circle inside the switch
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20.0,
                height: 20.0,
                margin: const EdgeInsets.all(1.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Circle color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}