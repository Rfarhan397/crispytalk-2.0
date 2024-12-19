import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/app_text_field.dart';
import '../../model/res/widgets/hover_button_loader.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/passwpordVisibility/passwordVisibilityProvider.dart';
import '../../provider/stream/streamProvider.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final password = Provider.of<PasswordVisibilityProvider>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                const AppTextWidget(
                  text: 'Login',
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 3.h),
                AppTextField(
                  controller: emailController,
                  hintText: 'Email',
                  borderSides: false,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SvgPicture.asset(AppAssets.email),
                  ),
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
                AppTextField(
                  controller: passwordController,
                  obscureText: password.isObscure,
                  hintText: 'Password',
                  borderSides: false,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SvgPicture.asset(AppAssets.password),
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      password.toggleVisibility();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: password.isObscure
                          ? SvgPicture.asset(AppAssets.eye)
                          : SvgPicture.asset(AppAssets.eyeOff),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 1.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.toNamed(RoutesName.forget);
                    },
                    child: AppTextWidget(
                      text: 'Forget Password?',
                      color: primaryColor,
                      fontSize: 12,
                      textDecoration: TextDecoration.underline,
                      underlinecolor: primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Align(
                  alignment: Alignment.center,
                  child: HoverLoadingButton(
                    height: 5.h,
                    onClicked: () async {
                      if (_formKey.currentState!.validate()) {
                        signIn();
                      }
                    },
                    radius: 8,
                    width: 60.w,
                    fontWeight: FontWeight.w700,
                    text: 'Log In',
                    isIcon: false,
                    oneColor: true,
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ),
                    const AppTextWidget(
                      text: 'Continue With',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _signInWithGoogle();
                    },
                    child: Image.asset(AppIcons.google),
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppTextWidget(
                      text: 'New User?',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RoutesName.signUp);
                      },
                      child: AppTextWidget(
                        text: ' Register Now',
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
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    await googleSignIn.signOut();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);

      DocumentSnapshot userDoc = await firestore.collection('users').doc(userCredential.user!.uid).get();
      if (!userDoc.exists) {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'profileUrl': userCredential.user!.photoURL,
          'phone': userCredential.user!.phoneNumber,
          'userType': 'google',
          'password': '',
          'userUid': userCredential.user!.uid,
          'createdAt': timestampId,
          'bgUrl' : '',
          'bio' : '',
          'likes' : [],
          'followers': [],
          'following': [],
          'savedPosts' :[],
          'blocks' : [],
          'userStatus' : "true",
          'blockStatus' : 'active',
          'isOnline' : false,
          'instagram' : '',
          'facebook' : '',


        });
      }
      //clear
      StreamDataProvider().updateFcmToken();
      log('fcm token update from google');

      Get.toNamed(RoutesName.mainScreen); // Navigate to the main screen
    } catch (error) {
      log(        'Failed to sign in with Google: $error',);
      AppUtils().showToast(text:  'Failed to sign in with Google: $error',);
    }
  }

  void signIn() async {
    try {
      ActionProvider.startLoading();
      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      //clear
      ActionProvider.stopLoading();
      StreamDataProvider().updateFcmToken();
      log('fcm token update from login screen');
      Get.toNamed(RoutesName.mainScreen);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      ActionProvider.stopLoading();
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password provided.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user has been disabled.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many login attempts. Please try again later.';
      } else {
        errorMessage = 'Login failed. Please check your credentials.';
      }
      AppUtils().showToast(text:  'Failed to sign in : $errorMessage',);

    } catch (e) {
      ActionProvider.stopLoading();
      if (mounted) {
        AppUtils().showToast(text:   'An unexpected error occurred. Please try again.',);

      }
    }
  }
}
