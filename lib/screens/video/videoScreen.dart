import 'dart:developer';

import 'package:crispy/model/res/components/commentBottomSheet.dart';
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

  VideoScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            StreamBuilder(
              stream: StreamDataProvider().getFriendsPostsStream(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const VideoPostShimmerWidget();
                }

                final videos = snapshot.data;

                if (videos == null || videos.isEmpty) {
                  return const Center(
                    child: Text(
                      "No videos available",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final videoItems = videos.where((video) {
                  final isVideo = video.mediaType == 'mp4';
                  return isVideo;
                }).toList();

                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: videoItems.length,
                  controller: pageController,
                  onPageChanged: (index) {},
                  itemBuilder: (context, index) {
                    final video = videoItems[index];

                    return Stack(
                      children: [
                        Positioned(
                          child: VideoPlayerScreen(
                            videoUrl: customLink + video.mediaUrl,
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
                                        userName: video.userDetails?.name ??
                                            'Unknown',
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
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: CachedShimmerImageWidget(
                                              imageUrl: video.userDetails
                                                      ?.profileUrl ??
                                                  '')),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),

                              // Heart Icon
                              GestureDetector(
                                onTap: () {
                                  final actionProvider = Provider.of<ActionProvider>(context, listen: false);
                                  final isLiked = actionProvider.isPostLiked(video.timeStamp, video.likes);
                                  if (isLiked) {
                                    actionProvider.toggleLike(video.timeStamp, video.likes);
                                  } else {
                                    actionProvider.toggleLike(video.timeStamp, video.likes);
                                  }
                                },
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                                       Provider.of<ActionProvider>(context, listen: false).isPostLiked(video.timeStamp, video.likes)
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
                                    CommentBottomSheet(
                                      postId: video.timeStamp,
                                      token: video.userDetails!.fcmToken,
                                      postOwnerUid: video.userUid,
                                    ),
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    enableDrag: true,
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

                                  final actionProvider = Provider.of<ActionProvider>(context, listen: false);
                                  final isSaved = actionProvider.isPostLiked(video.timeStamp, video.saves);
                                  if (isSaved) {
                                    actionProvider.toggleSave(video.timeStamp, video.saves);
                                  } else {
                                    actionProvider.toggleSave(video.timeStamp, video.saves);
                                  }
                                },
                                child: Column(
                                  children: [
                                    SvgPicture.asset(
                    Provider.of<ActionProvider>(context,listen: false).isPostSaved(video.timeStamp, video.saves)
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
                                  text:
                                      video.userDetails?.name.capitalizeFirst ??
                                          "N/A",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                                const SizedBox(height: 5),
                                AppTextWidget(
                                  text: video.title.isNotEmpty
                                      ? video.title
                                      : "N/A",
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
            Positioned(
              top: 7.h,
              left: MediaQuery.of(context).size.width * 0.4,
              child: const AppTextWidget(
                  text: "Followings", color: Colors.grey, fontSize: 18),
            ),
          ],
        ));
  }
  // Share function to handle sharing the video URL
}
