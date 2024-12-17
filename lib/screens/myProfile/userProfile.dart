import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/res/components/app_button_widget.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/current_user/current_user_provider.dart';
import '../ImageDetail/image_detail.dart';
import '../video/mediaViewerScreen.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<ActionProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: PopupMenuButton<String>(
              color: primaryColor,
              icon: SvgPicture.asset(AppIcons.menu),
              onSelected: (value) {
                menuProvider.setSelectedItem(value);

                // Handle the navigation after selection
                if (value == 'Setting') {
                  log('Setting selected');
                  Get.toNamed(RoutesName.settingScreen);
                } else if (value == 'Notification') {
                  log('Notification selected');
                  Get.toNamed(RoutesName.notificationScreen);
                } else if (value == 'Log Out') {
                  menuProvider.logout();
                  log('Log Out selected');
                  // onTap here
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  buildMenuItem(
                      context, 'Setting', AppIcons.setting, menuProvider),
                  buildMenuItem(context, 'Notification', AppIcons.notification,
                      menuProvider),
                  buildMenuItem(
                      context, 'Log Out', AppIcons.exit, menuProvider),
                ];
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: UserProfileCurrentUser(
            userUid: currentUser,
          )),
    );
  }
  // Build a menu item with consistent styling
  PopupMenuItem<String> buildMenuItem(
      BuildContext context,
      String value,
      String icon,
      ActionProvider menuProvider,
      ) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: menuProvider.selectedItem == value
              ? const Color(0xffEDFE19)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              color: menuProvider.selectedItem == value
                  ? Colors.black
                  : Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              value,
              style: TextStyle(
                color: menuProvider.selectedItem == value
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileCurrentUser extends StatelessWidget {
  final String userUid;

  const UserProfileCurrentUser({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserProvider>(context);
    final userData = currentUserProvider.currentUser;

    if (userData == null) {
      return const Center(child: CircularProgressIndicator(color: primaryColor,));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BackgroundImage(profileUrl: userData.bgUrl),
        ProfileImage(profileUrl: userData.profileUrl),
        Transform.translate(
          offset: Offset(0, -7.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: UserDetails(
                      name: userData.name,
                      bio: userData.bio,
                  ),
              ),
              Consumer<CurrentUserProvider>(
               builder: (context, userData, child) {
                 return FollowAndActionButtons(
                   followers: userData.currentUser!.followers,
                   following: userData.currentUser!.following,
                   likes: userData.currentUser!.likes,
                 );
               },
              ),
              const SizedBox(height: 10),
              const ProfileActions(),
              SizedBox(height: 2.h),
              _MediaWrap(userUid: userData.userUid),
            ],
          ),
        ),
      ],
    );
  }
}

class BackgroundImage extends StatelessWidget {
  final String? profileUrl;

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
        child: profileUrl.toString().isNotEmpty
            ? Image.network(profileUrl.toString(), fit: BoxFit.cover)
            : Image.asset(AppAssets.noImage, fit: BoxFit.cover),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String? profileUrl;

  const ProfileImage({required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -10.h),
      child: GestureDetector(
        onTap: () {
      Get.to(ImageDetailScreen(
        imageUrl: profileUrl.toString(),
      ));},
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 3),
            borderRadius: BorderRadius.circular(56),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(56),
              child: CachedShimmerImageWidget(imageUrl: profileUrl.toString())
          ),
        ),
      ),
    );
  }
}

class UserDetails extends StatelessWidget {
  final name, bio;

  const UserDetails({super.key, this.name, this.bio});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextWidget(
          text: name ?? 'Unknown User',
          fontWeight: FontWeight.w600,
          color: primaryColor,
          fontSize: 18,
        ),
        AppTextWidget(
          text: bio ?? 'N/A',
          fontWeight: FontWeight.w400,
          color: AppColors.textGrey,
          fontSize: 16,
          maxLines: 2,
        ),
        SizedBox(height: 1.h),
      ],
    );
  }
}

class FollowAndActionButtons extends StatelessWidget {
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<dynamic>? likes;

  const FollowAndActionButtons({
    Key? key,
    this.followers,
    this.following,
    this.likes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildFollow(
              (followers?.length ?? 0).toString(),
              "Followers",
              onTap: () {
                Get.toNamed(RoutesName.followerScreen,
                  arguments: {
                    'userId': currentUser, // Pass the current user's ID
                  },
                );
              },
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            buildFollow(
              (following?.length ?? 0).toString(),
              "Following",
              onTap: () {
                Get.toNamed(RoutesName.followingScreen,
                  arguments: {
                    'userId': currentUser, // Pass the current user's ID
                  },

                );
              },
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            buildFollow(
              (likes?.length ?? 0).toString(),
              "Likes",
              onTap: () {
                // Handle likes tap
              },
            ),
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

class ProfileActions extends StatelessWidget {
  const ProfileActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButtonWidget(
          prefixIcon: SvgPicture.asset(AppIcons.editProfile),
          onPressed: () {
            Get.toNamed(RoutesName.editProfile);
          },
          text: "Edit Profile",
          radius: 12,
        ),
        SizedBox(width: 2.w),
        AppButtonWidget(
          prefixIcon: SvgPicture.asset(AppIcons.shareProfile),
          onPressed: () {},
          text: "Share Profile",
          radius: 12,
        ),
      ],
    );
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
          if (
          RegExp(r'\.jpe?g$|\.png$',
              caseSensitive: false)
              .hasMatch(url)) {
            return 'image';
          } else if (
          RegExp(r'\.mov|\.avi|\.mp4$',
              caseSensitive: false,
          )
              .hasMatch(url)) {
            return 'video';
          }
          return 'unknown';
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
                 alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 20,
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
                      15,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: mediaType == "image"
                            ? CachedShimmerImageWidget(imageUrl: media.mediaUrl)
                            : VideoThumbnail(videoUrl: media.mediaUrl,)
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class ImageCard extends StatelessWidget {
  final String mediaUrl;

  const ImageCard({super.key, required this.mediaUrl});

  bool _isVideo(String url) {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          if (mediaUrl.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoUrl: mediaUrl),
              ),
            );
          }
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
                : mediaUrl.isNotEmpty // Null check
                    ? Image.network(
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
                      )
                    : const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}


class VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnail({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is displayed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 500,
      color: Colors.black,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}
