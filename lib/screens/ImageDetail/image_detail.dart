import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/res/constant/app_colors.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;

  const ImageDetailScreen({required this.imageUrl, Key? key}) : super(key: key);

  void shareVideo(String mediaUrl) {
    if (mediaUrl.isNotEmpty) {
      Share.share(mediaUrl, subject: "Check out this image!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.textGrey,
        title: Text('Image Detail',style: TextStyle(color: AppColors.textGrey),),
        actions: [
          IconButton(
            icon: Icon(Icons.share,color: AppColors.textGrey),
            onPressed: () {
              shareVideo(imageUrl);
            },
          ),
        ],
      ),
      body: Container(
        height: Get.height,
        width: Get.width,
        color: AppColors.appBlackColor,
        child: Center(
            child: CachedShimmerImageWidget(
              imageUrl:
          imageUrl,
          fit: BoxFit.cover,
          height: Get.height,
          width: Get.width,
        )),
      ),
    );
  }
}
