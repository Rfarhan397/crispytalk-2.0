// lib/widgets/video/overlay/interaction_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../model/res/widgets/app_text.dart.dart';

class InteractionButton extends StatelessWidget {
  final String icon;
  final String? label;
  final VoidCallback? onTap;

  const InteractionButton({
    Key? key,
    required this.icon,
    this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            height: 22,
          ),
          if (label != null)
            AppTextWidget(
              text: label!,
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
