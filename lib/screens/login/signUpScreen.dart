import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/app_text_field.dart';
import '../../model/res/widgets/hover_button_loader.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/passwpordVisibility/passwordVisibilityProvider.dart';
import '../../provider/stream/streamProvider.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPassController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final passwordVisibilityProvider = Provider.of<PasswordVisibilityProvider>(context, listen: true);
    

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              const AppTextWidget(
                text: 'Sign Up',
                color: primaryColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 3.h),
              _buildTextField(
                controller: nameController,
                hintText: 'Full Name',
                prefixIcon: SvgPicture.asset(AppAssets.person),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
              ),
              SizedBox(height: 3.h),
              _buildTextField(
                controller: emailController,
                hintText: 'Email',
                prefixIcon: SvgPicture.asset(AppAssets.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),
              _buildPasswordField(
                controller: passwordController,
                hintText: 'Password',
                isObscure: passwordVisibilityProvider.isObscure,
                toggleVisibility: passwordVisibilityProvider.toggleVisibility,
                showVisibilityToggle: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  else if (!value.contains(RegExp(r'[A-Z]')) ||
                      !value.contains(RegExp(r'[a-z]')) ||
                      !value.contains(RegExp(r'[0-9]')) ||
                      !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'It contain uppercase,lowercase,number and special character';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),
              _buildPasswordField(
                controller: cPassController,
                hintText: 'Confirm Password',
                isObscure: passwordVisibilityProvider.isObscure,
                toggleVisibility: passwordVisibilityProvider.toggleVisibility,
                showVisibilityToggle: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),
              SizedBox(height: 5.h),
              Align(
                alignment: Alignment.center,
                child: HoverLoadingButton(
                  height: 5.h,
                  onClicked: () async{
                    if (_formKey.currentState!.validate()) {
                      _signUp(context);
                    }
                  },
                  radius: 8,
                  width: 60.w,
                  fontWeight: FontWeight.w700,
                  text: 'Sign Up',
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppTextWidget(
                    text: 'Already have an account?',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(RoutesName.loginScreen),
                    child: const AppTextWidget(
                      text: ' Login',
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Widget prefixIcon,
    required String? Function(String?) validator,
  }) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      borderSides: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(14.0),
        child: prefixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscure,
    required VoidCallback toggleVisibility,
    required bool showVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      obscureText: isObscure,
      borderSides: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SvgPicture.asset(AppAssets.password),
      ),
      suffixIcon: showVisibilityToggle ? GestureDetector(
        onTap: toggleVisibility,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SvgPicture.asset(isObscure ? AppAssets.eye : AppAssets.eyeOff),
        ),
      ) : null,
      validator: validator,
    );
  }

  Future<void> _signUp(BuildContext context) async {
    final actionProvider = Provider.of<ActionProvider>(context, listen: false);
    ActionProvider.startLoading();

    try {
      final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userUid = authResult.user?.uid ?? '';
      await FirebaseFirestore.instance.collection('users').doc(userUid).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'userUid': userUid,
        'createdAt': DateTime.now().microsecondsSinceEpoch.toString(),
        'userType': 'custom',
        'profileUrl': '',
        'bgUrl': '',
        'bio': '',
        'likes': [],
        'followers': [],
        'following': [],
        'savedPosts': [],
        'blocks': [],
        'userStatus': "true",
        'blockStatus' : 'active',
        'isOnline' : false,
        'instagram' : '',
        'facebook' : '',
        'phone': '',
      });

      ActionProvider.stopLoading();
      Get.snackbar('Success', 'Sign Up Completed Successfully', backgroundColor: primaryColor);
      StreamDataProvider().updateFcmToken();
      log('fcm token update from sign up screen');
      Get.toNamed(RoutesName.loginScreen);
    } on FirebaseAuthException catch (e) {
      ActionProvider.stopLoading();
      _handleAuthError(e);
    } catch (e) {
      ActionProvider.stopLoading();
      Get.snackbar('Error', 'An unexpected error occurred.');
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      Get.snackbar('Error', 'The email is already in use.');
    } else if (e.code == 'weak-password') {
      Get.snackbar('Error', 'The password is too weak.');
    } else {
      Get.snackbar('Error', 'An error occurred. Please try again.');
    }
  }
}
