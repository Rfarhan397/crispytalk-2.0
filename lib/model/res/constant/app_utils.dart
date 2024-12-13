



import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../routes/routes_name.dart';

class AppUtils{


  showToast({String? text, Color? bgColor, Color? txtColor}) {
    Fluttertoast.showToast(
      msg: text!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM_LEFT,
      timeInSecForIosWeb: 3,
      backgroundColor: bgColor ?? Colors.black45,
      textColor: txtColor ?? Colors.white,
      fontSize: 14.0,
    );
  }

  String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Password must contain at least one uppercase letter"
      );
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Password must contain at least one lowercase letter"
      );
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigits) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Password must contain at least one number"
      );
      return 'Password must contain at least one number';
    }
    if (!hasSpecialCharacters) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Password must contain at least one special character"
      );
      return 'Password must contain at least one special character';
    }

    return null;
  }


  String? validateEmail(String? value) {
    // Regular expression for validating an Email
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Please enter your email"
      );
      return 'Please enter your email';
    } else if (!regex.hasMatch(value)) {
      showToast(
          txtColor: Colors.white,
          bgColor: Colors.red,
          text:"Please enter a valid email"
      );
      return 'Please enter a valid email';
    }
    return null; // Return null if the email is valid
  }
  int generateUniqueNumber() {
    // Generate a random 4-digit number
    int min = 1000,max  = 9999;

    Random random = Random();
    int randomNumber = random.nextInt(max - min + 1) + min;

    // Ensure uniqueness by checking against a list of used numbers
    List<int> usedNumbers = [];
    while (usedNumbers.contains(randomNumber)) {
      randomNumber = random.nextInt(max - min + 1) + min;
    }

    // Add the generated number to the used list
    usedNumbers.add(randomNumber);

    return randomNumber;
  }
  sendMail({
    required String recipientEmail,
    required String otpCode,
    required BuildContext context,
    String request = "",
  }) async {
    // change your email here
    String username = 'Crispytalk29@gmail.com';
    // change your password here
    String password = 'gwls uosk mqej gyjt';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'CrispyTalk Support')
      ..recipients.add(recipientEmail)
      ..subject = 'One-Time OTP Verification '
      ..text = "Your CrispyTalk Verification Code is: $otpCode";

    try {
      await send(message, smtpServer);
      Get.snackbar("OTP SEND", "Email sent successfully");
      Get.toNamed(RoutesName.code,arguments: otpCode.toString());
      // Get.to(()=>OtpScreen(otp: otpCode.toString(),));
      if(!context.mounted) return;
      // Provider.of<ValueProvider>(context,listen: false).setLoading(false);
      // if(request == "resend"){
      // }else{
      //   Get.offAll(OtpScreen(otpCode: otpCode,email: recipientEmail));
      // }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}