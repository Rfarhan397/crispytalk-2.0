import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/app_text_field.dart';
import '../../model/res/widgets/button_widget.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/profile/profileProvider.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController instaController = TextEditingController();
  final TextEditingController fbController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);
    Color greyColor = const Color(0xffD9D9D9);


    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Background Image Section
            Consumer<ProfileProvider>(
              builder: (context, value, child) {
                return Container(
                  height: 60.w,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: greyColor,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showImagePicker(context, value.pickBackgroundImage, value.pickBackgroundImageFromCamera);
                    },
                    child: Stack(
                      children: [
                        value.backgroundImage != null
                            ? Image.file(value.backgroundImage!, fit: BoxFit.cover,)
                            : const SizedBox(),
                        Positioned(
                          bottom: 5.h,
                          left: 25.w,
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                AppIcons.camera,
                                color: Colors.black12,
                              ),
                              const AppTextWidget(
                                text: 'Change Bg Photo',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 22,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),

            // Profile Image Section
            Consumer<ProfileProvider>(
              builder: (context, value, child) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showImagePicker(context, value.pickProfileImage, value.pickProfileImageFromCamera);
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: greyColor,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: value.profileImage != null
                                  ? Image.file(value.profileImage!, fit: BoxFit.cover, width: 100.w)
                                  : Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  AppIcons.camera,
                                  color: Colors.black12,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 1.w),
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 2.h),

            // Name Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const AppTextWidget(
                    text: "Name:",
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                  SizedBox(width: 6.w),
                  SizedBox(
                    height: 40,
                    width: 60.w,
                    child: AppTextField(
                      controller: nameController,
                      radius: 8,
                      hintText: nameController.text.isEmpty ? "Enter Name" : nameController.text,
                    ),
                  ),
                ],
              ),
            ),

            // Bio Field
            buildUserInfo("Bio:", "Edit your bio", 11.w, bioController),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            children: [
              AppTextWidget(
                text: 'Gender:',
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 18,
              ),
              Row(
                children: [
                  Radio<String>(
                    activeColor: primaryColor,
                    value: 'male',
                    groupValue: profileProvider.selectedGender,
                    onChanged: (String? value) {
                      if (value != null) {
                        profileProvider.setGender(value); // Updates the provider state
                      }
                    },
                  ),
                  Text('Male'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    activeColor: primaryColor,
                    value: 'female',
                    groupValue: profileProvider.selectedGender,
                    onChanged: (String? value) {
                      if (value != null) {
                        profileProvider.setGender(value); // Updates the provider state
                      }
                    },
                  ),
                  Text('Female'),
                ],
              ),
            ],
          ),
        ),
            SizedBox(height: 2.h),

            // Social Links
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: const AppTextWidget(
                      text: 'Add Links:',
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 22,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                buildUserInfo("Instagram:", "Add Link", 3.w, instaController),
                buildUserInfo("Facebook:", "Add Link", 4.w, fbController),
              ],
            ),

            SizedBox(height: 2.h),

            // Save Button
            Padding(
              padding: EdgeInsets.only(right: 7.w),
              child: AppButtonWidget(
                radius: 8,
                width: 25.w,
                height: 5.h,
                alignment: Alignment.centerRight,
                onPressed: () {
                  uploadProfile(context);
                },
                text: 'Save',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildUserInfo(String name, String hint, double width, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppTextWidget(
            text: name,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 18,
          ),
          SizedBox(width: width),
          SizedBox(
            height: 40,
            width: 60.w,
            child: AppTextField(
              controller: controller,
              radius: 8,
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(BuildContext context, VoidCallback pickFromGallery, VoidCallback pickFromCamera) {
    Get.bottomSheet(
      Container(
        width: 100.w,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Gallery",
              onClicked: pickFromGallery,
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Camera",
              onClicked: pickFromCamera,
            ),
          ],
        ),
      ),
    );
  }

  void uploadProfile(BuildContext context) async {
    var profile = Provider.of<ProfileProvider>(context, listen: false);
    ActionProvider.startLoading();

    try {
      // Map to store updated fields
      Map<String, dynamic> updateData = {};

      // Check if profile image has been updated
      if (profile.profileImage != null) {
        Uint8List profileImageBytes = await profile.convertFileToUint8List(profile.profileImage!);
        await profile.uploadImage(profileImageBytes, type: "profile");
        updateData['profileUrl'] = profile.imageUrl;
      }

      // Check if background image has been updated
      if (profile.backgroundImage != null) {
        Uint8List backgroundImageBytes = await profile.convertFileToUint8List(profile.backgroundImage!);
        await profile.uploadImage(backgroundImageBytes, type: "background");
        updateData['bgUrl'] = profile.imageUrl;
      }

      // Update name if not empty
      if (nameController.text.trim().isNotEmpty) {
        updateData['name'] = nameController.text.trim();
      }

      // Update bio if not empty
      if (bioController.text.trim().isNotEmpty) {
        updateData['bio'] = bioController.text.trim();
      }

      // Update Instagram link if not empty
      if (instaController.text.trim().isNotEmpty) {
        updateData['instagram'] = instaController.text.trim();
      }

      // Update Facebook link if not empty
      if (fbController.text.trim().isNotEmpty) {
        updateData['facebook'] = fbController.text.trim();
      }
      if (profile.selectedGender.isNotEmpty) {
        updateData['gender'] = profile.selectedGender;
      }

      // If there are updates, send them to Firestore

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser).update(updateData);
        AppUtils().showToast(text: 'Profile updated successfully!');
        profile.clear();
        nameController.clear();
        bioController.clear();
        instaController.clear();
        fbController.clear();

      } else {
        AppUtils().showToast(text: 'No changes detected.');
      }

      ActionProvider.stopLoading();
    } catch (e) {
      AppUtils().showToast(text: 'Error updating profile: $e');
      log('Error updating profile: $e');
      ActionProvider.stopLoading();
    }
  }
}
