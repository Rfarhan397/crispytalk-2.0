import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/res/components/app_back_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/app_text_field.dart';
import '../../provider/passwpordVisibility/passwordVisibilityProvider.dart';
class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final password = Provider.of<PasswordVisibilityProvider>(context,listen: true);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h,),
              const AppTextWidget(
                text: 'New Password',
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        
              SizedBox(height: 5.h,),
              AppTextWidget(
                text: 'Please write your new password',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 4.h,),
              AppTextField(
                obscureText: password.isObscure,
                hintText: 'Password',
                borderSides: false,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SvgPicture.asset(AppAssets.password,),
                ),
                suffixIcon:  GestureDetector(
                  onTap: () {
                    password.toggleVisibility();
        
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: password.isObscure?
                    SvgPicture.asset(AppAssets.eye):
                    SvgPicture.asset(AppAssets.eyeOff),
                  ),
                ),),
              SizedBox(height: 4.h,),
              AppTextField(
                obscureText: password.isObscure,
                hintText: 'Confirm Password',
                borderSides: false,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SvgPicture.asset(AppAssets.password,),
                ),
                suffixIcon:  GestureDetector(
                  onTap: () {
                    password.toggleVisibility();
        
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: password.isObscure?
                    SvgPicture.asset(AppAssets.eye):
                    SvgPicture.asset(AppAssets.eyeOff),
                  ),
                ),),
              SizedBox(height: 5.h,),
              AppButtonWidget(
                  alignment: Alignment.center,
                  onPressed: () {
                    Get.toNamed(RoutesName.loginScreen);
                  },
                  radius: 8,
                  height: 5.h,
                  width: 60.w,
                  fontWeight: FontWeight.w700,
                  text: 'Confirm Password'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetPasswordInApp(String newPassword) async {
    try {
      // Assuming the user is already authenticated, or you've verified their identity.
      User? user = FirebaseAuth.instance.currentUser;

      // Update the password without needing the current password
      await user?.updatePassword(newPassword);
      print("Password updated successfully.");
    } catch (error) {
      print("Failed to reset password: $error");
      // Handle errors (e.g., weak password, network issues)
    }

}
}
