
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../constant.dart';
import '../../model/res/components/customNavBar.dart';
import '../../model/res/constant/app_icons.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/bottomNavBar/bottomNavBarProvider.dart';
import '../chat/chatListScreen/chatListScreen.dart';
import '../chat/tabBarView/tabBarScreen.dart';
import '../myProfile/userProfile.dart';
import '../video/videoScreen.dart';
import 'homeScreen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BottomNavBarProvider>(
        builder: (context, value, child) {
          return IndexedStack(
            index: value.currentIndex,
            children: [
              HomeScreen(),
              VideoScreen(index: 0,),
              TabViewScreen(),
              UserProfile(),
            ],
          );
        },),
      bottomNavigationBar: const CustomBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: "Home",
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        onPressed: () {
          ActionProvider().pickMedia(context);
          //Get.toNamed(RoutesName.uploadContentScreen);
        },
        backgroundColor: primaryColor,
        child: Consumer<BottomNavBarProvider>(
          builder: (context, value, child) {
            return  SvgPicture.asset(
              AppIcons.add,
              height: 80,
            );
          },),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
    );
  }
}
