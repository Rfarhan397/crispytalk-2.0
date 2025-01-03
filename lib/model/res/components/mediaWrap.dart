import 'package:crispy/constant.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:crispy/screens/sampleVideo/tiktokVIdeoPlayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../provider/action/action_provider.dart';
import '../../../screens/myProfile/userProfile.dart';
import '../../mediaPost/mediaPost_model.dart';
import '../widgets/cachedImage/cachedImage.dart';


class MediaWrap extends StatelessWidget {
  final String userUid;

  const MediaWrap({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MediaPost>>(
      stream: StreamDataProvider().getSinglePostsWithUserDetails(),
      builder: (context, snapshot) {
        final post = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No media uploaded yet."));
        }


        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 5,
            runSpacing: 20,
            children: post.map((media) {
              return GestureDetector(
                onTap: () {
                    context.read<ActionProvider>().saveModel(post);
                    final index= post.indexOf(media);
                    Get.to(
                      // VideoPlayerScreen(videoUrl: customLink+media.mediaUrl),
                    VideoFeedScreen(initialIndex: index),
                    );
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
                      child: media.mediaType == "image"
                          ? CachedShimmerImageWidget(imageUrl: customLink+media.mediaUrl)
                          : VideoThumbnail(
                        videoUrl: customLink+media.mediaUrl,
                      )),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
