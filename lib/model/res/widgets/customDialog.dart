import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import 'app_text.dart.dart';
import 'app_text_field.dart';

class CustomDialog extends StatelessWidget {
  final String? content, cancel, yes, hintText, title;
  final TextEditingController? textController;
  final bool showTextField, showTitle;
  final String userID;

  CustomDialog({
    super.key,
    this.content,
    this.cancel,
    this.yes,
    this.showTextField = false,
    this.textController,
    this.hintText,
    this.title,
    this.showTitle = false, required this.userID,
  });
  TextEditingController controller = TextEditingController();

  Future<void> storeTextInFirestore({
    String? userID, // Optional: If you want to specify a document ID
    String? text, // Optional: If you want to specify a document ID
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection("reports")
          .doc();
      await docRef.set({
        'text': text,
        'createdAt': DateTime.now(),
        'reportTo':userID,
        'reportBy':currentUser,
        'docID':docRef.id
      });

      print("Text stored successfully in Firestore.");
    } catch (e) {
      print("Failed to store text in Firestore: $e");
      rethrow;
    }
  }
  @override
  Widget build(BuildContext context) {
    print("Current User ID : $currentUser");
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Optional: for rounded corners
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 400), // Set a maximum height
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
                      controller: controller, // Use the controller if provided
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
                      onTap: () {
                        print("User Id : $userID");
                        storeTextInFirestore(text: controller.text.trim(),userID: userID);
                        Get.back();
                      },
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
        showTitle: showTitle, userID:'',
      ),
    );
  }
}
class MyCustomDialog extends StatelessWidget {
  final String? content, cancel, yes, hintText, title;
  final TextEditingController? textController;
  final bool showTextField, showTitle;
  final VoidCallback cancelTap,yesTap;

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
  });
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("Current User ID : $currentUser");
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Optional: for rounded corners
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 400), // Set a maximum height
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
                      controller: controller, // Use the controller if provided
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
        showTitle: showTitle, cancelTap: cancelTap, yesTap: yesTap,
      ),
    );
  }
}
