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
import '../../model/res/widgets/hover_button_loader.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/profile/profileProvider.dart';
import '../../provider/current_user/current_user_provider.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: true);
    final currentUserProvider = Provider.of<CurrentUserProvider>(context);
    final userData = currentUserProvider.currentUser;

    if (userData != null) {
      profileProvider.initializeControllers({
        'name': userData.name,
        'bio': userData.bio,
        'instagram': userData.instagram,
        'facebook': userData.facebook,
        'gender': userData.gender,
      });
    }

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
                    color: customGrey,
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
                        if (value.backgroundImage != null)
                          Image.file(value.backgroundImage!, fit: BoxFit.cover, width: double.infinity)
                        else if (userData?.bgUrl != null && userData!.bgUrl.isNotEmpty)
                          Image.network(customLink+userData.bgUrl, fit: BoxFit.cover, width: double.infinity),
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
                              color: customGrey,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: value.profileImage != null
                                  ? Image.file(value.profileImage!, fit: BoxFit.cover, width: 100.w)
                                  : userData?.profileUrl != null && userData!.profileUrl.isNotEmpty
                                      ? Image.network(customLink+userData.profileUrl, fit: BoxFit.cover, width: 100.w)
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
                      controller: profileProvider.nameController,
                      radius: 8,
                      hintText: "Enter Name",
                    ),
                  ),
                ],
              ),
            ),

            // Bio Field
            buildUserInfo("Bio:", "Edit your bio", 11.w, context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  const AppTextWidget(
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
                            profileProvider.setGender(value);
                          }
                        },
                      ),
                      const Text('Male'),
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
                            profileProvider.setGender(value);
                          }
                        },
                      ),
                      const Text('Female'),
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
                buildUserInfo("Instagram:", "Add Link", 3.w, context),
                buildUserInfo("Facebook:", "Add Link", 4.w, context),
              ],
            ),

            SizedBox(height: 2.h),

            // Save Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 7.w),
                child: HoverLoadingButton(
                  radius: 8,
                  width: 25.w,
                  height: 5.h,
                  onClicked: () async {
                    uploadProfile(context);
                  },
                  text: 'Save',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildUserInfo(String name, String hint, double width, BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
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
              controller: getControllerByName(name, profileProvider),
              radius: 8,
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController getControllerByName(String name, ProfileProvider provider) {
    switch (name) {
      case "Bio:":
        return provider.bioController;
      case "Instagram:":
        return provider.instaController;
      case "Facebook:":
        return provider.fbController;
      default:
        return provider.nameController;
    }
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
    var currentUserProvider = Provider.of<CurrentUserProvider>(context, listen: false);
    var action = Provider.of<ActionProvider>(context, listen: false);
    ActionProvider.startLoading();

    try {
      Map<String, dynamic> updateData = {};

      if (profile.profileImage != null) {
        // Uint8List profileImageBytes = await profile.convertFileToUint8List(profile.profileImage!);
        // await profile.uploadImage(profileImageBytes, type: "profile");
        final profileUrl = await action.uploadFileThrough(profile.profileImage!.path.toString());
        updateData['profileUrl'] = profileUrl;
      }

      if (profile.backgroundImage != null) {
        // Uint8List backgroundImageBytes = await profile.convertFileToUint8List(profile.backgroundImage!);
        // await profile.uploadImage(backgroundImageBytes, type: "background");
        final bgUrl = await action.uploadFileThrough(profile.backgroundImage!.path.toString());
        updateData['bgUrl'] = bgUrl;
      }

      if (profile.nameController.text.trim().isNotEmpty) {
        updateData['name'] = profile.nameController.text.trim();
      }

      if (profile.bioController.text.trim().isNotEmpty) {
        updateData['bio'] = profile.bioController.text.trim();
      }

      if (profile.instaController.text.trim().isNotEmpty) {
        updateData['instagram'] = profile.instaController.text.trim();
      }

      if (profile.fbController.text.trim().isNotEmpty) {
        updateData['facebook'] = profile.fbController.text.trim();
      }
      updateData['gender'] = profile.selectedGender;

      if (updateData.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(currentUser).update(updateData);
        await currentUserProvider.fetchCurrentUserDetails(); // Refresh user data
        AppUtils().showToast(text: 'Profile updated successfully!');
        profile.clear();
        profile.nameController.clear();
        profile.bioController.clear();
        profile.instaController.clear();
        profile.fbController.clear();
        action.clearUploadedMediaUrl();
        Get.back(); // Navigate back to profile screen
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
