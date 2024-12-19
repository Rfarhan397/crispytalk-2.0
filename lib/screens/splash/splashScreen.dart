import 'dart:developer';
import 'package:crispy/provider/action/action_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';
import '../../model/res/constant/app_assets.dart';
import '../../provider/current_user/current_user_provider.dart';
import '../../provider/postCache/postCacheProvider.dart';
import '../../provider/savedPost/savedPostProvider.dart';
import '../../provider/stream/streamProvider.dart';
import '../../provider/suggested_users/suggested_users_provider.dart';
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final auth = FirebaseAuth.instance;
      
      // Run critical initialization tasks first
      await Future.wait([
        StreamDataProvider().updateFcmToken(),
        Provider.of<PostCacheProvider>(context, listen: false).initializePosts(),
      ], eagerError: true);

      // Only fetch additional data if user is logged in
      if (auth.currentUser != null) {
        await Future.wait([
          Provider.of<SavedPostsProvider>(context, listen: false)
              .fetchSavedPosts(currentUser),
          Provider.of<SuggestedUsersProvider>(context, listen: false)
              .fetchSuggestedUsers(currentUser),
        ]);
      }

      // Add a shorter timeout
      await Future.delayed(const Duration(seconds: 2));

      // Navigation
      if (auth.currentUser != null) {
        log('User is logged in: ${auth.currentUser}');
        Get.off(() => const MainScreen());
      } else {
        Get.off(() => const OnBoardingScreenOne());
      }
    } catch (e) {
      log('Splash screen initialization error: $e');
      // Handle error - navigate to login or show error dialog
      Get.off(() =>  LoginScreen());
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
