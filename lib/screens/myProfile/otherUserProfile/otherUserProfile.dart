import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:crispy/provider/mediaPost/media_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/res/components/ProfileActionButton.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/components/mediaWrap.dart';
import '../../../model/res/components/profileBackGroundImage.dart';
import '../../../model/res/components/profileImage.dart';
import '../../../model/res/components/socialLinks.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_colors.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/constant/app_utils.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/customDialog.dart';
import '../../../model/user_model/user_model.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/stream/streamProvider.dart';

class OtherUserProfile extends StatelessWidget {
    OtherUserProfile(
      {super.key, required this.userID, required this.userName});

  final String userID;
  final String userName;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final streamDataProvider = Provider.of<StreamDataProvider>(context, listen: false);
    final action = Provider.of<ActionProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: const AppBackButton(),
        actions: [_buildPopupMenu(context,action)],
      ),
      body: StreamBuilder(
        stream: streamDataProvider.getSingleUser(userID),
        builder: (context, AsyncSnapshot<UserModelT> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("User not found"));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: UserProfileOtherUser(userModel: snapshot.data!),
          );
        },
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context,ActionProvider action) {
    return PopupMenuButton<String>(
      surfaceTintColor: primaryColor,
      color: primaryColor,
      icon: SvgPicture.asset(AppIcons.menu),
      onSelected: (value) => _handlePopupMenuSelection(value, context, action),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'Block',
          child: Text('Block', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem<String>(
          value: 'Report',
          child: Text('Report', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> blockUser() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final usersCollection = FirebaseFirestore.instance.collection('users');

      // Update current user's blocks and following
      batch.update(usersCollection.doc(currentUser), {
        'blocks': FieldValue.arrayUnion([userID]),
        'following': FieldValue.arrayRemove([userID]),
      });
      Get.back();
      // Update blocked user's followers
      batch.update(usersCollection.doc(userID), {
        'followers': FieldValue.arrayRemove([currentUser]),
      });

      await batch.commit();

      AppUtils().showToast(
        text: 'You have blocked $userName',
        bgColor: primaryColor,
      );

    } catch (e) {
      log("Error blocking user: $e");
      AppUtils().showToast(
        text: 'Failed to block user. Please try again.',
        bgColor: Colors.red,
      );
    }
  }

  void _handlePopupMenuSelection(String value, BuildContext context,ActionProvider action) {
    switch (value) {
      case 'Block':
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            content: 'Are you sure you want to Block?',
            cancel: "Cancel",
            yes: "Block",
            yesTap: () {
              blockUser();
              Provider.of<CurrentUserProvider>(context,listen: false).fetchCurrentUserDetails();
            },
          ),
        );
        break;

      case 'Report':
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            content: 'Why you report this user? Write a short Description',
            title: 'Report User?',
            cancel: "Cancel",
            yes: "Submit",
            showTextField: true,
            hintText: 'Write the Description',
            textController: controller,
            yesTap: () {
              action.reportUser(text: controller.text.trim(),userID: userID);
              Get.back();
              controller.clear();
              AppUtils().showToast(text: 'You reported this user successfully');
            },
          ),
        );
        break;
    }
  }
}

class UserProfileOtherUser extends StatelessWidget {
  final UserModelT userModel;

  const UserProfileOtherUser({
    super.key,
    required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    final cUser = Provider.of<CurrentUserProvider>(context,).currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfileBackgroundImage(profileUrl: customLink+userModel.bgUrl),
        ProfileImage(profileUrl: customLink+userModel.profileUrl),
        Transform.translate(
          offset: Offset(0, -8.h),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserBioScreen( name: userModel.name,bio: userModel.bio,),
                FollowAndActionButtons(postData: userModel,),
                SizedBox(height: 3.w),
                userModel.facebook != null && userModel.facebook!.isNotEmpty ?
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SocialLinksScreen(
                      userModel: userModel,
                    )
                  ),
                ):
                const Align(
                  alignment: Alignment.center,
                  child: AppTextWidget(text: 'No Social Link',),
                ),
                SizedBox(height: 3.w),
                OtherActionButton(userModel),
                SizedBox(height: 2.h),
                // if(cUser!.blocks.contains(userModel.userUid))

                  const Align(
                    alignment: Alignment.center,
                    child: AppTextWidget(
                      text: 'Blocked',
                    ),
                  ),
                // if(!cUser.blocks.contains(userModel.userUid))

                  MediaWrap(userUid: userModel.userUid),
              ],
            ),
          ),
        )
      ],
    );
  }

}

class BackgroundImage extends StatelessWidget {
  final String profileUrl;
  const BackgroundImage({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.w,
      width: 100.w,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: profileUrl.isNotEmpty
            ? Image.network(profileUrl, fit: BoxFit.cover)
            : Image.asset(AppAssets.noImage, fit: BoxFit.cover),
      ),
    );
  }
}





class FollowAndActionButtons extends StatelessWidget {

  final UserModelT postData;

  const FollowAndActionButtons({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    final countPr = Provider.of<MediaPostProvider>(context,listen: false);
    countPr.fetchUserPosts(postData.userUid);


    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFollowItem(
              postData.followers.length.toString(),
              "Followers",
              () => Get.toNamed(
                RoutesName.followerScreen,
                arguments: {
                  'userId': postData.userUid,
                },
              ),
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            _buildFollowItem(
              postData.following.length.toString(),
              "Following",
              () => Get.toNamed(RoutesName.followingScreen,
                arguments: {
                  'userId': postData.userUid,
                },
              ),
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            _buildFollowItem(
              countPr.getPostCount(postData.userUid).toString(),
              "Posts",
              () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowItem(String count, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AppTextWidget(
            text: count,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          AppTextWidget(
            text: label,
            fontSize: 14,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}


