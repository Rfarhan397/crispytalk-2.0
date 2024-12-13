import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:flutter/material.dart';

class FullImagePreview extends StatelessWidget {
  final String image;
  const FullImagePreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.network(image,
    height: double.infinity,
    width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder:(context, error, stackTrace) {
        return AppTextWidget(text: 'Error: ' );
      },

    );
  }
}
