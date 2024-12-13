import 'package:flutter/material.dart';

import '../../../constant.dart';
import '../constant/app_colors.dart';
import '../widgets/app_text.dart.dart';

class AppButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final double height, width;
  final FontWeight fontWeight;
  final Alignment alignment;
  final String text;
  final Color? buttonColor, textColor;
  final double? radius, fontSize;
  final bool loader;
  final Widget? prefixIcon; // New parameter for prefix icon

  const AppButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    this.buttonColor,
    this.radius,
    this.loader = false,
    this.textColor,
    this.fontSize,
    this.height = 40,
    this.width = 150,
    this.fontWeight = FontWeight.w400,
    this.alignment = Alignment.centerLeft,
    this.prefixIcon, // Initialize the prefix icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Align(
        alignment: alignment,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 0),
            color: buttonColor ?? primaryColor, // Use buttonColor if provided
          ),
          child: (loader)
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.appBackgroundColor,
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 8), // Spacing between icon and text
              ],
              AppTextWidget(
                text: text,
                fontSize: fontSize ?? 16,
                fontWeight: fontWeight,
                color: textColor ?? AppColors.appWhiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
