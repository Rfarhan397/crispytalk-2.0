import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/constant.dart';
import 'package:crispy/model/res/components/fullImagePreview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../screens/myProfile/userProfile.dart';
import '../../../screens/video/mediaViewerScreen.dart';
import '../../mediaPost/mediaPost_model.dart';
import '../widgets/cachedImage/cachedImage.dart';

class MediaWrap extends StatelessWidget {
  final String userUid;

  const MediaWrap({required this.userUid});

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
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 5,
            runSpacing: 20,
            children: mediaList.map((media) {
              return GestureDetector(
                onTap: () {
                  if (media.mediaType =='mp4') {
                    Get.to(
                            VideoPlayerScreen(videoUrl: customLink+media.mediaUrl),
                    );
                  }else{
                   Get.to(FullImagePreview(image: customLink+media.mediaUrl));
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
