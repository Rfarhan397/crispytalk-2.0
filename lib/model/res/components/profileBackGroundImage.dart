import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../constant/app_assets.dart';

class ProfileBackgroundImage extends StatelessWidget {
  final String? profileUrl;

  const ProfileBackgroundImage({super.key,required this.profileUrl});

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
            ? CachedShimmerImageWidget(imageUrl: profileUrl.toString(), fit: BoxFit.cover)
            : Image.asset(AppAssets.noImage, fit: BoxFit.cover),
      ),
    );
  }
}
