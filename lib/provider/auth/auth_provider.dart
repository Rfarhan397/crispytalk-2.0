import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../model/res/constant/app_utils.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/services/enum/toastType.dart';
import '../action/action_provider.dart';

class AuthProvider extends ChangeNotifier{
  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final login = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (login.user != null) {
        ActionProvider.stopLoading();
        AppUtils().showToast(text: "Login Successful");
        Get.offNamed(RoutesName.mainScreen);

        log("Login successful");
      }
    } on FirebaseAuthException catch (e) {
      ActionProvider.stopLoading();
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
        // ToastService().showToast("No user found for that email.", ToastType.error);

        AppUtils().showToast(text:  "Login failed, No user found for that email.",);

      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
        AppUtils().showToast(text: "Wrong password provided.",);
        //AppUtils().showToast(text:  "Login failed Wrong password provided.",);

      } else {
        AppUtils().showToast(text:"Login failed: ${e.message}",);

        log('Login failed: ${e.message}');
      }
    }
  }
  
}