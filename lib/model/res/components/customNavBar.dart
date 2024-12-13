import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../provider/bottomNavBar/bottomNavBarProvider.dart';
import '../constant/app_icons.dart';
import '../widgets/app_text.dart.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<BottomNavBarProvider>(context);

    return BottomAppBar(
      color: primaryColor,
      height: 85,
      // shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 70.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(context, AppIcons.home, 0,"Home"),
            buildNavItem(context, AppIcons.friends, 1,"Friends"),
            const SizedBox(width: 48), // Space for FAB
            buildNavItem(context, AppIcons.chat, 2,"Chat"),
            buildNavItem(context, AppIcons.profile, 3,"My Profile"),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem(BuildContext context, String icon, int index,text) {
    final provider = Provider.of<BottomNavBarProvider>(context);
    final isSelected = provider.currentIndex == index;

    return GestureDetector(
      onTap: () {
        provider.setIndex(index);
        debugPrint(index.toString());
      },
      child: Column(
        children: [
          SvgPicture.asset(
            icon,
            color: isSelected ? Colors.white : Colors.white,
            height: 28,
          ),
          SizedBox(height: 1.h,),
          AppTextWidget(text: text,color: Colors.white,fontSize: 14,fontWeight: FontWeight.w400,maxLines: 1,),
        ],
      ),
    );
  }
}
