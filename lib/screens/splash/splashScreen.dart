import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/res/constant/app_assets.dart';
import '../../provider/current_user/current_user_provider.dart';
import '../../provider/stream/streamProvider.dart';
import '../login/loginScreen.dart';
import '../mainScreen/mainScreen.dart';
import 'OnBoarding/OnBoardingScreenOne.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
    StreamDataProvider().updateFcmToken();

  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 5)); // Splash delay
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser != null) {
      log('User is logged in: ${auth.currentUser}');
      Get.off(() => MainScreen());
    } else {
      Get.off(() => OnBoardingScreenOne());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDFE19),
              Color(0xFFFC9025),
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            AppAssets.splashImage,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
