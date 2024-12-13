
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constant.dart';
import '../../../provider/theme/theme_provider.dart';
import '../components/responsive.dart';
import '../constant/app_colors.dart';

class AppTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final int? maxLines;
  final FontWeight fontWeight;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final bool softWrap;
  final Color color;
  final Color underlinecolor;
  final TextDecoration textDecoration;
  final List<Shadow>? shadows;  // Add a shadow parameter

  const AppTextWidget({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.color = AppColors.appBlackColor,
    this.textAlign = TextAlign.center,
    this.textDecoration = TextDecoration.none,
    this.fontSize = 12,
    this.softWrap = true,
     this.maxLines ,
    this.underlinecolor = primaryColor,
    this.overflow = TextOverflow.clip,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDarkMode = Provider.of<ThemeLanguageProvider>(context).isDarkMode;
    return Text(
      // maxFontSize: fontSize,
      // minFontSize: 10.0,
      //AppLocalizations.of(context)?.translate(text) ?? text,
      text,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
        shadows: shadows,
        decoration: textDecoration,
          decorationColor: underlinecolor,
          fontWeight: fontWeight,
          fontSize: fontSize,
          color: isDarkMode ? Colors.white : color,
      ),
    );
  }
}

