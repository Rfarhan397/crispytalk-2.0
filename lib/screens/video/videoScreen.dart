import 'dart:developer';

import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/model/res/widgets/customDialog.dart';
import 'package:crispy/screens/video/videoWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart';
import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/components/shimmer.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/current_user/current_user_provider.dart';
import '../../provider/stream/streamProvider.dart';
import '../../provider/user_provider/user_provider.dart';
import '../../provider/video/videoProvider.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';
import 'mediaViewerScreen.dart';

class VideoScreen extends StatelessWidget {

  final TextEditingController commentController = TextEditingController();
  final GlobalKey<VideoWidgetState> videoKey = GlobalKey<VideoWidgetState>();


  final int? index;
  final String? imagePath;
  final bool hasBackBtn;
  VideoScreen({super.key, this.index, this.imagePath,this.hasBackBtn = false});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: index ?? 0);
    return Scaffold(
      backgroundColor: Colors.black,
      body: ChangeNotifierProvider(
        create: (_) => VideoProvider(),

        child: Consumer2<VideoProvider,CurrentUserProvider>(
            builder: (context, videoProvider, currentUserProvider, _) {
              if (currentUserProvider.currentUser == null) {
                currentUserProvider.fetchCurrentUserDetails();
                return const Center(child: CircularProgressIndicator(color: primaryColor,));
              }

              final currentUser = currentUserProvider.currentUser?.userUid;
              if (currentUser == null) {
                return const Center(child: Text("Unable to load user data", style: TextStyle(color: Colors.white)));
              }

              return Stack(
                children: [
                  StreamBuilder(
                    stream: StreamDataProvider().getPostsWithUserDetails(
                        audience: 'Everyone',
                        currentUserId: currentUser,
                        includeCurrentUser: false
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ) {
                        return const VideoPostShimmerWidget();
                      }

                      final videos = snapshot.data;
                      if (videos == null || videos.isEmpty) {
                        return const Center(
                          child: Text("No videos available",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final videoItems = videos.where((video) {
                        final mediaUrl = video.mediaUrl.toString();
                        final isVideo = mediaUrl.endsWith('.mp4') ||
                            mediaUrl.endsWith('.mov') ||
                            mediaUrl.endsWith('.avi');
                        return isVideo;
                      }).toList();

                      return PageView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: videoItems.length,
                        controller: pageController,
                        onPageChanged: (index) {
                          videoProvider.setSelectedIndex(index);
                        },
                        itemBuilder: (context, index) {
                          final video = videoItems[index];
                          final mediaUrl = video.mediaUrl.toString();

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: VideoPlayerScreen(
                                  videoUrl: mediaUrl,
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 8.h,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (video.userDetails?.userUid != null) {
                                          Get.to(
                                            OtherUserProfile(
                                              userID: video.userDetails!.userUid,
                                              userName: video.userDetails?.name ?? 'Unknown',
                                            ),
                                          );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: ClipRRect(
                                                borderRadius: BorderRadius.circular(100),
                                                child: CachedShimmerImageWidget(imageUrl: video.userDetails?.profileUrl ?? '')
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 2.h),

                                    // Heart Icon
                                    GestureDetector(
                                      onTap: () {
                                        if (video.userDetails?.fcmToken != null) {
                                          Provider.of<ActionProvider>(context, listen: false)
                                              .toggleLike(video.timeStamp,
                                            video.likes,
                                            currentUserProvider.currentUser?.name ?? 'N/A'        ,
                                            video.userDetails!.fcmToken,
                                            video.userUid,
                                            'Like your Post',
                                          );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            Provider.of<ActionProvider>(context).isPostLiked(
                                              video.timeStamp,
                                              video.likes,

                                            )
                                                ? AppIcons.like
                                                : AppIcons.notLike,
                                            height: 22,
                                          ),
                                          AppTextWidget(
                                            text: video.likes.length.toString(),
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Comment Icon
                                    GestureDetector(
                                      onTap: () {
                                        Get.bottomSheet(
                                          BuildBottomSheet(context, video.timeStamp,
                                            video.userDetails?.fcmToken,
                                            currentUserProvider.currentUser?.name,
                                            video.userUid,

                                          ),
                                          isScrollControlled: true,
                                        );
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.message,
                                            height: 22,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Share Icon
                                    GestureDetector(
                                      onTap: () {
                                        shareVideo(video.mediaUrl.toString());
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            AppIcons.share,
                                            height: 22,
                                          ),
                                          const AppTextWidget(
                                            text: 'Share',
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Favorite Icon
                                    GestureDetector(
                                      onTap: () {
                                        Provider.of<ActionProvider>(context, listen: false)
                                            .toggleSave(video.timeStamp, video.saves);
                                      },
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            Provider.of<ActionProvider>(context).isPostSaved(
                                                video.timeStamp, video.saves)
                                                ? AppIcons.saveP
                                                : AppIcons.save,
                                            height: 22,
                                          ),
                                          const AppTextWidget(
                                            text: 'Favourite',
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 10,
                                child: SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppTextWidget(
                                        text: video.userDetails?.name.capitalizeFirst ?? "N/A",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                      const SizedBox(height: 5),

                                      AppTextWidget(
                                        text: video.title.isNotEmpty ? video.title : "N/A",
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                    },
                  ),
                  hasBackBtn? Positioned(top: 5.h, left: 3.w, child: const AppBackButton()):const SizedBox.shrink(),

                  Positioned(
                    top: 7.h,
                    left: MediaQuery.of(context).size.width * 0.4,
                    child: const AppTextWidget(
                        text: "Followings", color: Colors.grey, fontSize: 18),
                  ),

                  // Profile, Name, and Description at the Bottom
                ],
              );
            }
        ),
      ),
    );
  }

  Widget BuildBottomSheet(context, postId,token,currentUserName,postOwnerUid) {
    final action = Provider.of<ActionProvider>(context, listen: false);
    final currentUserProvider = Provider.of<CurrentUserProvider>(context, listen: false).currentUser;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppTextWidget(
                text: 'Comments',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: StreamDataProvider().getCommentsWithUserDetails(postId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CommentShimmerWidget();
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "No Comments on this post yet",
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final comments = snapshot.data ?? [];
                    return ListView.builder(
                      controller: scrollController, // Attach the scroll controller
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onLongPress: () {
                              final currentUserId = currentUserProvider?.userUid;

                              if (comment.user.userUid == currentUserId || postOwnerUid == currentUserId) {
                                MyCustomDialog.show(
                                  title: "Delete Comment",
                                  content: "Are you sure you want to delete this comment?",
                                  cancel: "Cancel",
                                  yes: "Delete",
                                  showTextField: false,
                                  showTitle: true,
                                  cancelTap: () {
                                    Navigator.pop(context);
                                  },
                                  yesTap: () async {
                                    await action.removeComment(postId, comment.comment.commentId);
                                   Navigator.pop(context);
                                  },
                                );
                              }
                            },

                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: primaryColor,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[500],
                                    child: CachedShimmerImageWidget(imageUrl: comment.user.profileUrl),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AppTextWidget(
                                              textAlign: TextAlign.start,
                                              text: comment.user.name,
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            AppTextWidget(
                                              textAlign: TextAlign.start,
                                              text: getTimeAgo(comment.comment.timestamp), // Pass the string timestamp here
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        AppTextWidget(
                                          textAlign: TextAlign.start,
                                          text: comment.comment.content,
                                          overflow: TextOverflow.visible,
                                          maxLines: null,
                                          softWrap: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            style: BorderStyle.solid,
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (commentController.text.isNotEmpty) {
                                await Provider.of<ActionProvider>(context, listen: false)
                                    .addComment(
                                    postId,
                                    commentController.text,
                                    token,
                                    currentUserName,
                                    postOwnerUid,
                                    'commented on your video'
                                );
                                commentController.clear();
                              }
                            },
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: SvgPicture.asset(
                                AppIcons.share,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }


  String getTimeAgo(String timestampString) {
    // Parse the string to an integer
    int timestampMillis = int.parse(timestampString);

    // Convert to DateTime
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestampMillis);
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} d';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime); // Return formatted date for older timestamps
    }
  }

  // Share function to handle sharing the video URL
  void shareVideo(String mediaUrl) {
    if (mediaUrl.isNotEmpty) {
      Share.share(mediaUrl, subject: "Check out this video!");
    }
  }
  Widget BuildShareBottomSheet(profileImage, profileName) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppTextWidget(
              text: 'Share Video', fontSize: 15, fontWeight: FontWeight.w500),
          const SizedBox(height: 10),
          SizedBox(
              height: 100,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 54,
                                width: 54,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    profileImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: AppTextWidget(
                                    text: profileName,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
