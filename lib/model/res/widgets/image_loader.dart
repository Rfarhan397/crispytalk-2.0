import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constant/app_icons.dart';

class ImageLoaderWidget extends StatelessWidget {
  final String imageUrl;
  const ImageLoaderWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl.isNotEmpty ? imageUrl : "https://img.freepik.com/free-vector/blue-circle-with-white-user_78370-4707.jpg?size=338&ext=jpg&ga=GA1.1.2008272138.1728259200&semt=ais_hybrid",
      placeholder: (context, url) => SvgPicture.asset(AppIcons.person), // Path to your placeholder image
      errorWidget: (context, url, error) => SvgPicture.asset(AppIcons.person), // Display an error icon if the image fails to load
      fit: BoxFit.cover,
    );
  }
}