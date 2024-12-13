import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
    final action = Provider.of<ActionProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    final otherUser =
        Provider.of<OtherUSerDataProvider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: AppBackButton(),
        actions: [_buildPopupMenu(context, userID, userName)],
      ),
      body: StreamBuilder(
        stream: streamDataProvider.getSingleUser(userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return Center(child: Text("User not found"));
          } else {
            final user = snapshot.data!;
            log('User Data : ${user.profileUrl}');
            return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: UserProfileOtherUser(
                  userModel: user,
                ));
          }
        },
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, userId, name) {
    return PopupMenuButton<String>(
      surfaceTintColor: primaryColor,
      color: primaryColor,
      icon: SvgPicture.asset(AppIcons.menu),
      onSelected: (value) {
        _handlePopupMenuSelection(value, context);
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            onTap: () {
              log("Bolcekd click");
              log(userId);
              log(name);
              blockUser(userId, name);
              Get.back();
            },
            value: 'Block',
            child: Text('Block', style: TextStyle(color: Colors.white)),
          ),
          PopupMenuItem<String>(
            onTap: () {},
            value: 'Report',
            child: Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ];
      },
    );
  }

  Future<void> blockUser(String userId, String name) async {
    log('Block Function Triggered');
    try {
      // Replace this with your method to get the current user ID
      final currentUserId = currentUser;

      // Get a reference to the Firestore instance
      final usersCollection = FirebaseFirestore.instance.collection('users');

      // Perform Firestore updates in a batch
      final batch = FirebaseFirestore.instance.batch();

      // Add the blocked user to the blocks list
      batch.update(usersCollection.doc(currentUserId), {
        'blocks': FieldValue.arrayUnion([userId]),
        'following': FieldValue.arrayRemove([userId]), // Remove from following
      });

      // Remove current user from the blocked user's followers list
      batch.update(usersCollection.doc(userId), {
        'followers':
            FieldValue.arrayRemove([currentUserId]), // Remove from followers
      });

      // Commit the batch
      await batch.commit();

      AppUtils().showToast(
        text: 'You have blocked $name',
        bgColor: primaryColor,
      );

      log("User $userId successfully blocked and removed from followers/following lists");
    } catch (e) {
      log("Error blocking user: $e");
      AppUtils().showToast(
        text: 'Failed to block user. Please try again.',
        bgColor: Colors.red,
      );
    }
  }

  void _handlePopupMenuSelection(String value, BuildContext context) {
    if (value == 'block') {
      showDialog(
        context: context,
        builder: (_) => CustomDialog(
          content: 'Are you sure you want to Block?',
          cancel: "Cancel",
          yes: "Block",
          userID: '',
        ),
      );
    } else if (value == 'Report') {
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
    print("user image :${userModel.profileUrl}");
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
                FollowAndActionButtons(
                  postData: userModel,
                ),
                SizedBox(
                  height: 3.w,
                ),
                _otherActionButton(userModel),
                SizedBox(
                  height: 2.h,
                ),
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
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 3),
              borderRadius: BorderRadius.circular(56),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(56),
              child: profileUrl.isNotEmpty
                  ? Image.network(profileUrl)
                  : Image.asset(AppAssets.noProfile, fit: BoxFit.cover),
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
  // final ActionProvider action;
  // final ChatProvider chat;

  const FollowAndActionButtons({
    super.key,
    required this.postData,
    // required this.action,
    // required this.chat,
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
            buildFollow(
                postData.followers.length.toString() ?? "0", "Followers",
                onTap: () {
              Get.toNamed(RoutesName.followerScreen,
                  arguments: postData.followers);
            }),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            buildFollow(
                postData.following.length.toString() ?? "0", "Following",
                onTap: () {
              Get.toNamed(RoutesName.followingScreen);
            }),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            buildFollow(
                postData.likes.isNotEmpty ? "${postData.likes.length}" : "0",
                "Likes",
                onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget buildFollow(String title, String subtitle,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AppTextWidget(
            text: title,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          AppTextWidget(
            text: subtitle,
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
    final otherUser = Provider.of<OtherUSerDataProvider>(
      context,
    );
    final chat = Provider.of<ChatProvider>(context, listen: false);
    return Consumer<ActionProvider>(
      builder: (context, value, child) {
        final isFollowed = value.isFollowed(postData.userUid);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppButtonWidget(
              radius: 8,
              onPressed: () async {
                value.toggleFolloww(
                  postData.userUid,
                  postData.userUid,
                );
              },
              text: isFollowed ? "Following" : "Follow",
            ),
            const SizedBox(width: 5),
            AppButtonWidget(
              radius: 8,
              onPressed: () {
                log('Chat created');
                chat.getChatID(
                    friendId: postData.userUid,
                    context: context,
                    name: postData.name,
                    image: postData.profileUrl,
                    fcmToken: postData.fcmToken,
                    status: postData.isOnline);
                log('fcm token in other user profile is ::${postData.fcmToken}');
              },
              text: "Message",
            ),
          ],
        );
      },
    );
  }
}

class _MediaWrap extends StatelessWidget {
  final String userUid;

  const _MediaWrap({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userUid', isEqualTo: userUid)
          .snapshots(),
      builder: (context, snapshot) {
        final post = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No media uploaded yet."));
        }

        final mediaList = snapshot.data!.docs
            .map((doc) => MediaPost.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        String mediaType = '';
        String determineMediaType(String url) {
          if (RegExp(r'\.jpe?g$|\.png$', caseSensitive: false).hasMatch(url)) {
            return 'image';
          } else if (RegExp(r'\.mov|\.avi|\.mp4$', caseSensitive: false)
              .hasMatch(url)) {
            return 'video';
          }
          return 'unknown';
        }

        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 8, // Horizontal space between items
          runSpacing: 20, // Vertical space between lines
          children: mediaList.map((media) {
            final mediaType = determineMediaType(media.mediaUrl);
            return GestureDetector(
              onTap: () {
                if (media.mediaUrl.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoPlayerScreen(videoUrl: media.mediaUrl),
                    ),
                  );
                }
              },
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width / 2 -
                    15, // Half width with some padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black12,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: media.mediaUrl.isNotEmpty
                      ? mediaType == "image"
                          ? Image.network(media.mediaUrl, fit: BoxFit.cover)
                          : VideoThumbnail(
                              videoUrl: media.mediaUrl,
                            )
                      : const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class ImageCard extends StatelessWidget {
  final String mediaUrl;

  const ImageCard({
    super.key,
    required this.mediaUrl,
  });

  bool _isVideo(String url) {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoUrl: mediaUrl,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black12,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _isVideo(mediaUrl)
                ? const Icon(Icons.play_circle, size: 50, color: Colors.white)
                : Image.network(
                    mediaUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey),
                  ),
          ),
        ),
      ),
    );
  }
}
