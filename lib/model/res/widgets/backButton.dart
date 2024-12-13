import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constant.dart';
import '../constant/app_assets.dart';

class AppBackButton extends StatelessWidget {
  final Color? color,buttonColor;
  const AppBackButton({super.key, this.color, this.buttonColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        height: 5,
        width: 5,
        decoration: BoxDecoration(
          color: color ?? primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: SvgPicture.asset(AppAssets.backButton,color: buttonColor?? whiteColor,),
      ),
    );;
  }
}
