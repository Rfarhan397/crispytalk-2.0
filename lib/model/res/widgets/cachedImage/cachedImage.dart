import 'package:crispy/model/res/constant/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class CachedShimmerImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final bool showErrorIcon;

  const CachedShimmerImageWidget({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = double.infinity,
    this.fit = BoxFit.cover,
    this.showErrorIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: showErrorIcon
              ? Image.network('https://res.cloudinary.com/dtwnx4xvs/image/upload/v1733988062/noPerson_rnlki6.jpg')
              : SizedBox.shrink()),
    //     errorWidget: (context, url, error) => Container(
          // width: width,
          // height: height,
          // color: Colors.grey[300],
          // child: showErrorIcon
          //     ? Icon(
          //   Icons.error,
          //   color: Colors.red,
          // )
          //     : SizedBox.shrink()),
    );
  }
}