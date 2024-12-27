import 'package:crispy/model/res/components/app_back_button.dart';
import 'package:crispy/model/res/constant/app_assets.dart';
import 'package:crispy/model/services/enum/toastType.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import '../../constant.dart';
import '../../model/res/components/commentBottomSheet.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../provider/action/action_provider.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';

class VideoFeedScreen extends StatefulWidget {
  final int initialIndex;

  const VideoFeedScreen({
    super.key,
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
      context.read<ActionProvider>().posts.length,
      (index) => VideoPlayerController.network(
          customLink + context.read<ActionProvider>().posts[index].mediaUrl)
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
    final actionP = Provider.of<ActionProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: actionP.posts.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final post = actionP.posts[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  if (post.mediaType == 'mp4') {
                    if (_controllers[index].value.isPlaying) {
                      _controllers[index].pause();
                    } else {
                      _controllers[index].play();
                    }
                  }
                  setState(() {});
                },
                child: Center(
                  child: post.mediaType == 'mp4'
                      ? _controllers[index].value.isInitialized
                          ? AspectRatio(
                              aspectRatio:
                                  _controllers[index].value.aspectRatio,
                              child: VideoPlayer(_controllers[index]),
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            )
                      : CachedShimmerImageWidget(
                          imageUrl: "$customLink${post.mediaUrl}",
                          fit: BoxFit.contain,
                        ),
                ),
              ),

              // User Info Overlay
              Positioned(
                top: 4.h,
                left: 2.w,
                child: const AppBackButton(),
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
                                child: post.userDetails!.profileUrl.isNotEmpty
                                    ? CachedShimmerImageWidget(
                                        imageUrl:
                                            "$customLink${post.userDetails?.profileUrl}")
                                    : Image.asset(AppAssets.noProfile)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Consumer<ActionProvider>(
                      builder: (context, value, child) {
                        return GestureDetector(
                          onTap: () {
                            if (post.userDetails?.fcmToken != null) {
                              actionP.toggleListCheck(index,
                                  type: ToggleType.like, context: context);
                            }
                          },
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                post.likes.contains(currentUser)
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
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Get.bottomSheet(
                          CommentBottomSheet(
                            postId: post.timeStamp,
                            token: post.userDetails!.fcmToken,
                            postOwnerUid: post.userUid,
                          ),
                          isScrollControlled: true,
                          isDismissible: true,
                          enableDrag: true,
                          ignoreSafeArea: false,
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
                        shareVideo(customLink + post.mediaUrl.toString());
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
                        actionP.toggleListCheck(index,
                            type: ToggleType.save, context: context);
                      },
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            post.saves.contains(currentUser)
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
              post.mediaType == 'mp4'
                  ? Positioned(
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
                    )
                  : const SizedBox.shrink(),
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
