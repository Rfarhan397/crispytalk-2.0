import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';
import 'package:pinput/pinput.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';

class CodeScreen extends StatelessWidget {
   CodeScreen({super.key});

  final defaultPinTheme = PinTheme(
    width: 65,
    height: 50,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    decoration: BoxDecoration(
      color: const Color(0xffD9D9D9),
      borderRadius: BorderRadius.circular(10),
    ),
  );
   final submittedPinTheme = PinTheme(
     width: 65,
     height: 50,
     textStyle: const TextStyle(
       fontSize: 22,
       color: Colors.black,
       fontWeight: FontWeight.bold,
     ),
     decoration: BoxDecoration(
       border: Border.all(
         color: primaryColor
       ),
       borderRadius: BorderRadius.circular(10),
     ),
   );
  @override
  Widget build(BuildContext context) {
  final String otp = Get.arguments as String;
  log('otp :${otp.toString()}');
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const AppTextWidget(text: 'Enter the Code',fontSize: 18,fontWeight: FontWeight.w500,),
         centerTitle: true,
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: AppTextWidget(
                text: 'We have emailed you an activation code',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,),
            ),
            SizedBox(height: 2.h,),
            Pinput(
              defaultPinTheme: defaultPinTheme,
              submittedPinTheme: submittedPinTheme,
              onCompleted: (pin){
                if (pin == otp) {
                  Get.toNamed(RoutesName.newPassword); // Navigate to the next page
                } else {
                  // Show error or do nothing
                  Get.snackbar('Error', 'Invalid code. Please try again.');
                }
              },
            ),
            SizedBox(height: 3.h,),
            const AppTextWidget(
              text: 'Crispytalk will send the code to you in : 1:00',
              fontSize: 16,
              color: AppColors.textGrey,),
            SizedBox(height: 2.h,),
             Row(
              mainAxisAlignment: MainAxisAlignment.center ,
              children: [
                AppTextWidget(
                  text: 'If you have not received the code ',
                  fontSize: 16,
                  color: AppColors.textGrey,),
                GestureDetector(
                  onTap: () async{
                    Get.toNamed(RoutesName.forget );
                  },
                  child: AppTextWidget(
                    text: 'Click here',
                    fontSize: 16,
                    color: primaryColor,),
                ),
              ],
            ),
            SizedBox(height: 6.h,),
            Container(
              height: 80,
              width: 100.w,
              color: Color(0xffF5F5F5),
              child: Center(
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 8.w),
                  child: AppTextWidget(
                      text: 'If the message is not in your inbox,please check spam.',
                    color: primaryColor,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
