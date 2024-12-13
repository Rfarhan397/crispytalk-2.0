import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/app_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetScreen extends StatelessWidget {
  ForgetScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            const AppTextWidget(
              text: 'Forgot Password',
              color: primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 5.h),
            RichText(
              text: const TextSpan(
                text: 'Please write your ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: ' to receive the confirmation code to set a ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  TextSpan(
                    text: 'new password',
                    style: TextStyle(
                      fontSize: 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            AppTextField(
              hintText: 'Email',
              controller: emailController,
              borderSides: false,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14.0),
                child: SvgPicture.asset(AppAssets.email),
              ),
            ),
            SizedBox(height: 5.h),
            AppButtonWidget(
                alignment: Alignment.center,
                onPressed: () async{
                  _sendPasswordResetEmail();
                },
                radius: 8,
                height: 5.h,
                width: 60.w,
                fontWeight: FontWeight.w700,
                text: 'Verify Email'),
          ],
        ),
      ),
    );
  }

  void _sendPasswordResetEmail() async {
    final email = emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      AppUtils().showToast(text: "Check your email for the password reset link.");
      Get.offNamed(RoutesName.loginScreen);
    } catch (e) {
      AppUtils().showToast(text: "Error: ${e.toString()}");
    }
  }


}
