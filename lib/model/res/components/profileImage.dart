import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../screens/ImageDetail/image_detail.dart';
import '../../user_model/user_model.dart';
import '../constant/app_colors.dart';
import '../widgets/app_text.dart.dart';
import '../widgets/cachedImage/cachedImage.dart';

class ProfileImage extends StatelessWidget {
  final String profileUrl;
  const ProfileImage({super.key, required this.profileUrl});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -10.h),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(ImageDetailScreen(
                imageUrl: profileUrl,
              ));
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor, width: 3),
                borderRadius: BorderRadius.circular(56),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(56),
                  child: CachedShimmerImageWidget(imageUrl: profileUrl)),
            ),
          ),
        ],
      ),
    );
  }
}

class UserBioScreen extends StatelessWidget {
  final name, bio;
  const UserBioScreen({super.key,  required this.name,required this.bio});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppTextWidget(
            textAlign: TextAlign.center,
            text: name,
            fontWeight: FontWeight.w600,
            color: primaryColor,
            fontSize: 18,
          ),
          AppTextWidget(
            text: bio,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
            fontSize: 15,
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}