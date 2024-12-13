import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/constant/app_icons.dart';
import '../../model/res/routes/routes_name.dart';
import '../../model/res/widgets/app_text.dart.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 2.h,
            ),
            const AppTextWidget(
              text: 'Settings',
              color: Colors.orange,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(
              height: 2.h,
            ),
            _buildSettingsTile(
              image: AppIcons.person,
              title: 'Account',
              onTap: () {
                Get.toNamed(RoutesName.accountScreen);
                // Add navigation or action here
              },
            ),
            _buildSettingsTile(
              image: AppIcons.person,
              title: 'Blocked Users',
              onTap: () {
                Get.toNamed(RoutesName.blockedUsers);
                // Add navigation or action here
              },
            ),
            _buildSettingsTile(
              image: AppIcons.notification,
              title: 'Notification',
              onTap: () {
                Get.toNamed(RoutesName.notificationSettingScreen);

                // Add navigation or action here
              },
            ),
            _buildSettingsTile(
              image: AppIcons.profile,
              title: 'Profile Setting',
              onTap: () {
                Get.toNamed(RoutesName.editProfile);

                // Add navigation or action here
              },
            ),
            _buildSettingsTile(
              image: AppIcons.share,
              title: 'Privacy Policy',
              onTap: () {
                Get.toNamed(RoutesName.privacyScreen);

                // Add navigation or action here
              },
            ),
            _buildSettingsTile(
              image: AppIcons.share,
              title: 'Term and Conditions',
              onTap: () {
                Get.toNamed(RoutesName.termAndConditions);

                // Add navigation or action here
              },
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each settings tile
  Widget _buildSettingsTile(
      {required String image,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: primaryColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  image,
                  height: 30,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: 4.w,
            ),
            AppTextWidget(
              text: title,
              color: AppColors.textGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            Spacer(),
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: primaryColor),
              child: Center(
                child: const Icon(
                  Icons.chevron_right,
                  color: whiteColor,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
