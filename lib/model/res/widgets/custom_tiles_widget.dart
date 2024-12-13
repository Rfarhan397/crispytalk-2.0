
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant.dart';
import 'app_text.dart.dart';

class CustomTilesWidget extends StatelessWidget {
  Widget? prefix,suffix;
  FontWeight? titleWeight,subtitleWeight;
  Color? tilesColor,titleColor,subTitleColor;
  double? radius,titleSize,subtitleSize,paddingHorizontal,paddingVertical;
   String? title,subTitle;
  VoidCallback? press;
   CustomTilesWidget({super.key,
    this.prefix,
    this.suffix,
     this.tilesColor = primaryColor,
     this.radius,
     this.titleWeight,
     this.press,
     this.subTitle,
     this.subtitleWeight,
     this.subtitleSize,
     this.subTitleColor,
     this.paddingHorizontal,
     this.paddingVertical,
     required this.title,

  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press ?? (){},
      child: Container(
        padding:  EdgeInsets.symmetric(
            horizontal: paddingHorizontal ?? Get.width * 0.030,
            vertical: paddingVertical ?? Get.width * 0.040
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Get.width * 0.030),
          color: tilesColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                prefix?? SizedBox.shrink(),
                prefix !=null ? SizedBox(width: Get.width * 0.034,) : SizedBox.shrink(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextWidget(
                      text: title ?? "",
                      color: titleColor ?? Colors.white,
                      fontSize: titleSize ?? 14.0,
                      fontWeight: titleWeight ?? FontWeight.normal,
                    ),
                    if(subTitle != null)
                      AppTextWidget(
                        text: subTitle ?? "",
                        color: subTitleColor ?? Colors.white,
                        fontSize: subtitleSize ?? 12.0,
                        fontWeight: subtitleWeight ?? FontWeight.normal,
                      ),
                  ],
                ),
              ],
            ),
            suffix?? SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

