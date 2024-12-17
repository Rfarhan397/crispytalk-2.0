import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/screens/ImageDetail/image_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/mediaPost/mediaPost_model.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/components/app_button_widget.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_colors.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/constant/app_utils.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/customDialog.dart';
import '../../../model/user_model/user_model.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';
import '../../../provider/otherUserData/otherUserDataProvider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../video/mediaViewerScreen.dart';
import '../userProfile.dart';

class OtherUserProfile extends StatelessWidget {
  const OtherUserProfile(
      {super.key, required this.userID, required this.userName});

  final String userID;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final streamDataProvider =
        Provider.of<StreamDataProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: AppBackButton(),
        actions: [_buildPopupMenu(context)],
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

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      surfaceTintColor: primaryColor,
      color: primaryColor,
      icon: SvgPicture.asset(AppIcons.menu),
      onSelected: (value) => _handlePopupMenuSelection(value, context),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'Block',
          onTap: () {
            blockUser();
            Get.back();
          },
          child: const Text('Block', style: TextStyle(color: Colors.white)),
        ),
        PopupMenuItem<String>(
          value: 'Report',
          child: const Text('Report', style: TextStyle(color: Colors.white)),
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

  void _handlePopupMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Block':
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            content: 'Are you sure you want to Block?',
            cancel: "Cancel",
            yes: "Block",
            userID: '',
          ),
        );
        break;

      case 'Report':
        showDialog(
          context: context,
          builder: (_) => CustomDialog(
            userID: userID,
            content: 'Why you report this user? Write a short Description',
            title: 'Report User?',
            cancel: "Cancel",
            yes: "Submit",
            showTextField: true,
            hintText: 'Write the Description',
          ),
        );
        break;
    }
  }
}

class UserProfileOtherUser extends StatelessWidget {
  final UserModelT userModel;

  const UserProfileOtherUser({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BackgroundImage(profileUrl: userModel.bgUrl),
        ProfileImage(profileUrl: userModel.profileUrl),
        Transform.translate(
          offset: Offset(0, -8.h),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserDetails(postData: userModel),
                FollowAndActionButtons(postData: userModel),
                SizedBox(height: 3.w),
                _otherActionButton(userModel),
                SizedBox(height: 2.h),
                _MediaWrap(userUid: userModel.userUid),
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
  const BackgroundImage({required this.profileUrl});

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

class ProfileImage extends StatelessWidget {
  final String profileUrl;
  const ProfileImage({required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -10.h),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(ImageDetailScreen(
                imageUrl: profileUrl,
              ));
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 3),
                borderRadius: BorderRadius.circular(56),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(56),
                  child: CachedShimmerImageWidget(imageUrl: profileUrl)),
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetails extends StatelessWidget {
  final UserModelT postData;
  const UserDetails({required this.postData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppTextWidget(
            textAlign: TextAlign.center,
            text: postData.name ?? 'Unknown User',
            fontWeight: FontWeight.w600,
            color: primaryColor,
            fontSize: 18,
          ),
          AppTextWidget(
            text: postData.bio ?? 'N/A',
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
            fontSize: 12,
          ),
          SizedBox(height: 1.h),
        ],
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
                  'userId': postData.userUid, // Pass the current user's ID
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
              postData.likes.length.toString(),
              "Likes",
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

class _otherActionButton extends StatelessWidget {
  final UserModelT postData;
  const _otherActionButton(this.postData);

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context, listen: false);

    return Consumer<ActionProvider>(
      builder: (context, value, _) {
        final isFollowed = postData.followers.contains(currentUser);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButtonWidget(
              radius: 8,
              onPressed: () =>
                  value.toggleFolloww(postData.userUid, postData.userUid),
              text: isFollowed ? "Following" : "Follow",
            ),
            const SizedBox(width: 5),
            AppButtonWidget(
              radius: 8,
              onPressed: () => _handleMessagePress(chat, context),
              text: "Message",
            ),
          ],
        );
      },
    );
  }

  void _handleMessagePress(ChatProvider chat, BuildContext context) {
    chat.getChatID(
        friendId: postData.userUid,
        context: context,
        name: postData.name,
        image: postData.profileUrl,
        fcmToken: postData.fcmToken,
        status: postData.isOnline);
  }
}

class _MediaWrap extends StatelessWidget {
  final String userUid;

  const _MediaWrap({required this.userUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userUid', isEqualTo: userUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No media uploaded yet."));
        }

        final mediaList = snapshot.data!.docs
            .map((doc) => MediaPost.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 20,
          children: mediaList
              .map((media) => _buildMediaItem(context, media))
              .toList(),
        );
      },
    );
  }

  Widget _buildMediaItem(BuildContext context, MediaPost media) {
    final mediaType = _determineMediaType(media.mediaUrl);

    return GestureDetector(
      onTap: () {
        if (media.mediaUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoUrl: media.mediaUrl),
            ),
          );
        }
      },
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width / 2 - 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _buildMediaContent(media.mediaUrl, mediaType),
        ),
      ),
    );
  }

  String _determineMediaType(String url) {
    if (RegExp(r'\.jpe?g$|\.png$', caseSensitive: false).hasMatch(url)) {
      return 'image';
    } else if (RegExp(r'\.mov|\.avi|\.mp4$', caseSensitive: false)
        .hasMatch(url)) {
      return 'video';
    }
    return 'unknown';
  }

  Widget _buildMediaContent(String url, String mediaType) {
    if (url.isEmpty) {
      return const Icon(Icons.broken_image, color: Colors.grey);
    }

    return mediaType == "image"
        ? Image.network(url, fit: BoxFit.cover)
        : VideoThumbnail(videoUrl: url);
  }
}
