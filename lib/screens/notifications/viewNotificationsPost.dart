import 'package:crispy/constant.dart';
import 'package:crispy/main.dart';
import 'package:crispy/model/res/constant/app_assets.dart';
import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/screens/video/videoWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/notification/notificationModel.dart';
import '../../model/user_model/user_model.dart';

class NotificationsPost extends StatefulWidget {
  const NotificationsPost({Key? key}) : super(key: key);

  @override
  State<NotificationsPost> createState() => _NotificationsPostState();
}

class _NotificationsPostState extends State<NotificationsPost> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    final arguments = Get.arguments;
    final post = arguments['post'] as MediaPost;

    // Initialize the video player if the media is a video
    if (post.mediaUrl != null && post.mediaUrl.endsWith('.mp4')) {
      _videoController = VideoPlayerController.network(post.mediaUrl)
        ..initialize().then((_) {
          setState(() {}); // Refresh to show the video player
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose(); // Dispose the video controller
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final notification = arguments['notification'] as NotificationModel;
    final sender = arguments['sender'] as UserModelT;
    final post = arguments['post'] as MediaPost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender information
              ListTile(
                leading: CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: sender.profileUrl.isNotEmpty
                        ? CachedShimmerImageWidget(imageUrl:  sender.profileUrl)
                        : Image.asset(AppAssets.noProfile),)
                ),
                title: Text(sender.name ?? 'Unknown User'),
                subtitle: Text('Posted at: ${notification.timestamp}'),
              ),
              const SizedBox(height: 16),

              // Post details
              AppTextWidget(
                text: post.title ?? 'No caption provided.',
              ),
              const SizedBox(height: 16),
              Container(
                height: 50.h,
                width: 100.w,
                child: Column(
                  children: [
                    AppTextWidget(text: 'text'),
                    if(post.mediaType == 'mp4')...[
                      SizedBox(
                          height: 30.h,
                          width: double.infinity,
                          child: VideoWidget(mediaUrl: customLink+post.mediaUrl, isAutoPlay: false))
                    ]
                    else...[
                      SizedBox(
                        height: 30.h,
                        width: double.infinity,
                        child: CachedShimmerImageWidget(
                          imageUrl: customLink + post.mediaUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
            ],
                    // if (post.mediaUrl != null && post.mediaUrl.isNotEmpty) ...[
                    //   if (post.mediaType == '.mp4')
                    //     _videoController != null && _videoController!.value.isInitialized
                    //         ? AspectRatio(
                    //       aspectRatio: _videoController!.value.aspectRatio,
                    //       child: Stack(
                    //         alignment: Alignment.bottomCenter,
                    //         children: [
                    //           VideoPlayer(_videoController!),
                    //           VideoProgressIndicator(
                    //             _videoController!,
                    //             allowScrubbing: true,
                    //           ),
                    //           IconButton(
                    //             icon: Icon(
                    //               _videoController!.value.isPlaying
                    //                   ? Icons.pause
                    //                   : Icons.play_arrow,
                    //               color: Colors.white,
                    //             ),
                    //             onPressed: () {
                    //               setState(() {
                    //                 if (_videoController!.value.isPlaying) {
                    //                   _videoController!.pause();
                    //                 } else {
                    //                   _videoController!.play();
                    //                 }
                    //               });
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     )
                    //         : const Center(child: CircularProgressIndicator())
                    //   else if (post.mediaType == 'image')
                    //     CachedShimmerImageWidget(
                    //       imageUrl: customLink + post.mediaUrl,
                    //       fit: BoxFit.cover,
                    //     )
                    //   else
                    //     const Text('Unsupported media type.'),
                    // ] else
                    //   const Text('No media available.'),
                ),
              ),
              // Media content (image or video)

            ],
          ),
        ),
      ),
    );
  }

}
