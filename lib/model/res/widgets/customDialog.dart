import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import 'app_text.dart.dart';
import 'app_text_field.dart';
import 'dart:developer';

class CustomDialog extends StatelessWidget {
  final String? content, cancel, yes, hintText, title;
  final TextEditingController? textController;
  final bool showTextField, showTitle;
  final VoidCallback? yesTap;

  CustomDialog({
    super.key,
    this.content,
    this.cancel,
    this.yes,
    this.showTextField = false,
    this.textController,
    this.hintText,
    this.title,
    this.showTitle = false,
     this.yesTap,
  });


  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Optional: for rounded corners
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400), // Set a maximum height
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle)
                  AppTextWidget(
                    text: title ?? '',
                    color: primaryColor,
                    fontSize: 18,
                  ),
                SizedBox(height: 1.h),
                AppTextWidget(
                  text: content ?? '',
                  color: Colors.black,
                  fontSize: 15,
                ),
                if (showTextField)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppTextField(
                      radius: 8,
                      hintText: hintText ?? '',
                      controller: textController, // Use the controller if provided
                    ),
                  ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        child: AppTextWidget(
                          text: cancel ?? '',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w,),
                    GestureDetector(
                      onTap: yesTap,
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppTextWidget(
                          text: yes ?? '',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the dialog
  static void show({
    String? content,
    String? cancel,
    String? yes,
    bool showTextField = false,
    TextEditingController? textController,
    String? hintText,
    String? title,
    bool showTitle = false,
  }) {
    Get.dialog(
      CustomDialog(
        content: content,
        cancel: cancel,
        yes: yes,
        showTextField: showTextField,
        textController: textController,
        hintText: hintText,
        title: title,
        showTitle: showTitle,
      ),
    );
  }
}
class MyCustomDialog extends StatelessWidget {
  final String? content, cancel, yes, hintText, title;
  final TextEditingController? textController;
  final bool showTextField, showTitle;
  final VoidCallback cancelTap,yesTap;
  final Color? hintColor;

  MyCustomDialog({
    super.key,
    this.content,
    this.cancel,
    this.yes,
    this.showTextField = false,
    this.textController,
    this.hintText,
    this.title,
    this.showTitle = false,
    required this.cancelTap,
    required this.yesTap,
     this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Optional: for rounded corners
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400), // Set a maximum height
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle)
                  AppTextWidget(
                    text: title ?? '',
                    color: primaryColor,
                    fontSize: 18,
                  ),
                SizedBox(height: 1.h),
                AppTextWidget(
                  text: content ?? '',
                  color: Colors.black,
                  fontSize: 15,
                ),
                if (showTextField)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppTextField(
                      radius: 8,
                      hintText: hintText ?? '',
                      hintColor: hintColor,
                      controller: textController, // Use the controller if provided
                    ),
                  ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: cancelTap,
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryColor,
                            width: 1,
                          ),
                        ),
                        child: AppTextWidget(
                          text: cancel ?? '',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w,),
                    GestureDetector(
                      onTap: yesTap,
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppTextWidget(
                          text: yes ?? '',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to show the dialog
  static void show({
    String? content,
    String? cancel,
    String? yes,
    bool showTextField = false,
    TextEditingController? textController,
    String? hintText,
    Color? color,
    String? title,
    bool showTitle = false,
    required VoidCallback cancelTap,
    required VoidCallback yesTap,  // Add required callbacks here
  }) {
    Get.dialog(
      MyCustomDialog(
        content: content,
        cancel: cancel,
        yes: yes,
        showTextField: showTextField,
        textController: textController,
        hintText: hintText,
        title: title,
        hintColor: color,
        showTitle: showTitle, cancelTap: cancelTap, yesTap: yesTap,
      ),
    );
  }
}
