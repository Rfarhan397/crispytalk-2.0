import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/constant.dart';
import 'package:crispy/main.dart';
import 'package:crispy/model/res/components/app_back_button.dart';
import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/model/res/widgets/app_text_field.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/action/action_provider.dart';
import 'package:crispy/provider/cloudinary/cloudinary_provider.dart';
import 'package:crispy/screens/chat/Groups/editGroupDetails/editGroupDetails.dart';
import 'package:crispy/screens/chat/Groups/groupList.dart';
import 'package:crispy/screens/mainScreen/mainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../model/res/components/app_button_widget.dart';
import '../../../../model/res/constant/app_icons.dart';
import '../../../../model/res/constant/app_utils.dart';
import '../../../../model/res/widgets/button_widget.dart';
import '../../../../provider/profile/profileProvider.dart';
import '../../chatListScreen/groupChat.dart';

class EditNameAndPhoto extends StatelessWidget {
  final String groupName, groupPhoto,groupID;
  final TextEditingController nameController = TextEditingController();

  EditNameAndPhoto(
      {super.key, required this.groupName, required this.groupPhoto, required this.groupID}) {
    nameController.text =
        groupName; // Initialize controller with current group name
  }

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading:  AppBackButton(onTap: () {
          Get.to(MainScreen());
        },),
        title: const AppTextWidget(
          fontWeight: FontWeight.w500,
          text: 'Edit Group',
          fontSize: 18,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                      radius: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: profile.profileImage != null
                            ? Image.file(profile.profileImage!,
                                fit: BoxFit.cover, width: 100.w)
                            : groupPhoto.isNotEmpty
                                ? Image.network(groupPhoto,
                                    fit: BoxFit.cover, width: 100.w)
                                : Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      AppIcons.camera,
                                      color: Colors.black12,
                                    ),
                                  ),
                      )),
                  SizedBox(
                    height: 2.h,
                  ),
                  GestureDetector(
                      onTap: () {
                        _showImagePicker(context, profile);
                      },
                      child: AppTextWidget(
                        text: 'Add Photo',
                        fontSize: 18,
                        color: primaryColor,
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            AppTextField(
              hintText: 'Enter group name',
              controller: nameController,
            ),
            SizedBox(
              height: 5.h,
            ),
            AppButtonWidget(
                alignment: Alignment.center,
                text: 'Done',
                onPressed: () async{
              _updateProfile(context, profile,groupID);
                },
                radius: 4,
                width: 30.w,
                height:4.h,
                fontWeight:FontWeight.w500)
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context, ProfileProvider provider) {
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
              onClicked: provider.pickProfileImage,
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Camera",
              onClicked: provider.pickProfileImageFromCamera,
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile(context,ProfileProvider provider,groupID) async {
    ActionProvider.startLoading();
    final cloud = Provider.of<CloudinaryProvider>(context, listen: false);
    try {
      if (nameController.text.trim().isEmpty && provider.profileImage == null) {
        AppUtils().showToast(text: 'Please enter a name or select an image');
        ActionProvider.stopLoading();
        return;
      }

      // Reference to group document
      final groupRef = FirebaseFirestore.instance
          .collection('groupChats')
          .doc(groupID);

      Map<String, dynamic> updateData = {};

      // Update name if changed
      if (nameController.text.trim().isNotEmpty) {
        updateData['groupName'] = nameController.text.trim();
      }

      // Update image if selected
      if (provider.profileImage != null) {
        // Upload image to Cloudinary
        String? imageUrl = await cloud.uploadFile(provider.profileImage!);
        
        if (imageUrl != null) {
          updateData['groupImage'] = imageUrl;
        }
      }

      // Update Firestore if there are changes
      if (updateData.isNotEmpty) {
        await groupRef.update(updateData);
        AppUtils().showToast(text: 'Group updated successfully');
        Get.back();
      }
      ActionProvider.stopLoading();

    } catch (e) {
      ActionProvider.stopLoading();
      log('Error updating group: $e');
      AppUtils().showToast(text: 'Error updating group');
    }
  }
}
