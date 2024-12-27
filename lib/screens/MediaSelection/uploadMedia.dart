import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constant.dart';
import '../../model/filterModel/ColorFilters.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/constant/app_utils.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/hover_button_loader.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/cloudinary/cloudinary_provider.dart';
import '../../provider/mediaSelection/mediaSelectionProvider.dart';

class UploadMediaScreen extends StatelessWidget {
  UploadMediaScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final greyColor = const Color(0xffD9D9D9);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActionProvider>(context);
    final mediaProvider = Provider.of<MediaSelectionProvider>(context);

    final MediaWithFilter? mediaData = Get.arguments as MediaWithFilter?;
    if (mediaData != null) {
      // Now you can safely use mediaData as MediaWithFilter
    } else {
      // Handle the case where the cast fails
      print('Error: arguments is not of type MediaWithFilter');
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5.h),
          TextField(
            cursorColor: primaryColor,
            maxLength: 90,
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Add a Catchy title',
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              hintStyle: TextStyle(
                fontSize: 16,
                color: greyColor,
                fontWeight: FontWeight.w600,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            child: GestureDetector(
              onTap: () {
                print('message');

              //  _showPrivacySettingsBottomSheet(context);
              },
              child: _privacySettingsRow(context, provider),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: HoverLoadingButton(
              height: 5.h,
              width: 30.w,
              radius: 8,
              onClicked: () async{
                // ActionProvider.stopLoading();

                log('message');
              // await provider.uploadFile();
                uploadPost(
                  context,
                  // mediaData!.mediaBytes ,
                  // mediaData.mediaType,
                  mediaData?.selectedFilterIndex,
                );
              },
              text: 'Post',
            )
          ),
        ],
      ),
    );
  }

  Widget _privacySettingsRow(BuildContext context, ActionProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(AppIcons.group),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTextWidget(
                  text: "Who can see this post?",
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
                AppTextWidget(
                  text: provider.selectedOption,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ],
        ),
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showPrivacySettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PrivacySettingsBottomSheet();
      },
    );
  }
  void uploadPost(
      BuildContext context, int? filterIndex) async {
    final provider = Provider.of<ActionProvider>(context, listen: false);
    final cloudinaryProvider = Provider.of<CloudinaryProvider>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
    final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    log('Video have been uploaded');

    if (currentUser == null) {
      ActionProvider.stopLoading();
      AppUtils().showToast(text: 'User not authenticated');
      log('User not authenticated');
      return;
    }

    ActionProvider.startLoading();
    log('Title: ${titleController.text}');
    log('Audience: ${provider.selectedOption}');

    if (titleController.text.isEmpty || provider.selectedOption.isEmpty) {
      ActionProvider.stopLoading();
      AppUtils().showToast(text: 'Please fill all fields');
      return;
    }

    try {
      // Upload media and retrieve the URL
      // await cloudinaryProvider.uploadMedia(mediaData, mediaType);
      await provider.uploadFile();
      String? mediaUrl = provider.uploadedMediaName;


      if (mediaUrl == null || mediaUrl.isEmpty) {
        throw Exception('Media upload failed');
      }

      log('media URL: $mediaUrl');

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('posts').doc(timeStamp).set({
        'timeStamp': timeStamp,
        'title': titleController.text,
        'audience': provider.selectedOption,
        'mediaUrl': mediaUrl,
        'mediaType': provider.uploadedMediaTypee,
        'likes': [],
        'saved': [],
        'userUid': currentUser,
      });

      ActionProvider.stopLoading();
      cloudinaryProvider.clearMedia();
      provider.clearUploadedMediaUrl();
      titleController.clear();
      AppUtils().showToast(text: 'Data uploaded successfully');
       Get.toNamed(RoutesName.mainScreen);
    } catch (e) {
      log('Error uploading data: $e');
      ActionProvider.stopLoading();
      AppUtils().showToast(text: 'Failed to upload data');
    }
  }

}
class PrivacySettingsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ActionProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: const AppTextWidget(
              text: 'Who can see this post?',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 1.h),
          _privacyOptions(provider, context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        color: const Color(0xffFDCD9D),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          const AppTextWidget(
            text: "Privacy Setting",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _privacyOptions(ActionProvider provider, BuildContext context) {
    return Column(
      children: [
        _privacyOption(context, "Everyone", "Everyone on crispy talk", provider),
        _privacyOption(context, "Friends", "Follow you and Follow back", provider),
        _privacyOption(context, "Only You", "Only you can see the post", provider),
      ],
    );
  }

  Widget _privacyOption(BuildContext context, String title, String subtitle, ActionProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.selectOption(title);
        Get.back();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextWidget(text: title, fontSize: 16.0),
                AppTextWidget(text: subtitle, fontSize: 12.0, fontWeight: FontWeight.w300),
              ],
            ),
            provider.selectedOption == title
                ? const Icon(Icons.check_circle_outline)
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
