import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../user_model/user_model.dart';
import '../constant/app_assets.dart';
import '../constant/app_utils.dart';
import '../widgets/app_text.dart.dart';

class SocialLinksScreen extends StatelessWidget {
  final UserModelT userModel;
  const SocialLinksScreen({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildSocialLink(
          'Facebook',
          AppAssets.fb,
          40.0,
          40.0,
          onTap: () {
            if (userModel.facebook != null) {
              launchUrl(Uri.parse(userModel.facebook!));
            }else {
              AppUtils().showToast(text: 'Error');
            }
          },
        ),
        buildSocialLink(
          'Instagram',
          AppAssets.insta,
          25.0,
          25.0,
          onTap: () {
            if (userModel.instagram != null) {
              launchUrl(Uri.parse(userModel.instagram!));
            }else {
              AppUtils().showToast(text: 'Error');
            }
          },
        ),
      ],
    );
  }
  Widget buildSocialLink(String title, String image,double height,width,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(image,height: height,width: width,fit: BoxFit.cover,),

          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AppTextWidget(
              text: title,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
