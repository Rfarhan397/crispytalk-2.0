import 'package:crispy/model/res/components/app_back_button.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/res/components/commentBottomSheet.dart';
import '../../model/res/components/shimmer.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../model/res/widgets/customDialog.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/stream/streamProvider.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';

class VideoFeedScreen extends StatefulWidget {
  final List<MediaPost> posts;
  final int initialIndex;

  const VideoFeedScreen({
    super.key,
    required this.posts,
    required this.initialIndex,
  });

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late PageController _pageController;
  late List<VideoPlayerController> _controllers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize controllers for current, previous and next videos
    _controllers = List.generate(
      widget.posts.length,
      (index) => VideoPlayerController.network(widget.posts[index].mediaUrl)
        ..initialize().then((_) {
          if (index == _currentIndex) {
            _controllers[index].play();
          }
          setState(() {});
        }),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // Pause previous video
    _controllers[_currentIndex].pause();
    // Play current video
    _controllers[index].play();
    setState(() => _currentIndex = index);
  }

  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUserProvider =
        Provider.of<CurrentUserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  if (_controllers[index].value.isPlaying) {
                    _controllers[index].pause();
                  } else {
                    _controllers[index].play();
                  }
                  setState(() {});
                },
                child: VideoPlayer(_controllers[index]),
              ),
              // User Info Overlay
              const Positioned(
                top: 40,
                left: 16,
                child: Row(
                  children: [AppBackButton()],
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 16,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (post.userDetails?.userUid != null) {
                          Get.to(
                            OtherUserProfile(
                              userID: post.userDetails!.userUid,
                              userName: post.userDetails?.name ?? 'Unknown',
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
                                child: CachedShimmerImageWidget(
                                    imageUrl:
                                        post.userDetails?.profileUrl ?? '')),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () {
                        if (post.userDetails?.fcmToken != null) {
                          Provider.of<ActionProvider>(context, listen: false)
                              .toggleLike(
                            post.timeStamp,
                            post.likes,
                            currentUserProvider.currentUser?.name ?? 'N/A',
                            post.userDetails!.fcmToken,
                            post.userUid,
                            'Like your Post',
                          );
                        }
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            Provider.of<ActionProvider>(context).isPostLiked(
                              post.timeStamp,
                              post.likes,
                            )
                                ? AppIcons.like
                                : AppIcons.notLike,
                            height: 22,
                          ),
                          AppTextWidget(
                            text: post.likes.length.toString(),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          CommentBottomSheet(
                          postId:   post.timeStamp,
                           token:  post.userDetails!.fcmToken,
                           currentUserName:  currentUserProvider.currentUser!.name,
                           postOwnerUid:  post.userUid,
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
                        shareVideo(post.mediaUrl.toString());
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
                            .toggleSave(post.timeStamp, post.saves);
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            Provider.of<ActionProvider>(context)
                                    .isPostSaved(post.timeStamp, post.saves)
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
                bottom: 20,
                left: 10,
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(
                        text: post.userDetails?.name.capitalizeFirst ?? "N/A",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      const SizedBox(height: 5),
                      AppTextWidget(
                        text: post.title.isNotEmpty ? post.title : "N/A",
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
              ),
              // Video Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controllers[index],
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: primaryColor,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  // Share function to handle sharing the video URL
  void shareVideo(String mediaUrl) {
    if (mediaUrl.isNotEmpty) {
      Share.share(mediaUrl, subject: "Check out this video!");
    }
  }
}
