import 'package:flutter/material.dart';

import '../../../constant.dart';
class AppIconButton extends StatelessWidget {
  final String iconPath;
  double width,height;
  final VoidCallback press;
  var color;
   AppIconButton({super.key,
    required this.iconPath,
    this.width = 25.0,
    this.height = 25.0,
    this.color = whiteColor,
     required this.press
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        width: width,
        height: height,
        child: Image.asset(iconPath,color: color,),
      ),
    );
  }
}
