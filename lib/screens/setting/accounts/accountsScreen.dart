import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/components/app_button_widget.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/customDialog.dart';
import '../../../provider/action/action_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final action = Provider.of<ActionProvider>(context, listen: false);

    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
        title: const AppTextWidget(text: 'Account',color: primaryColor,fontWeight: FontWeight.w700,fontSize: 18,),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 3.h,),
      AppButtonWidget(
        fontWeight: FontWeight.w600,
        alignment: Alignment.center,
        width: 80.w,
        radius: 8,
        onPressed: () {
          MyCustomDialog.show(
            title: "Log out?",
            content: "Are you sure you want to logout?",
            cancel: "Cancel",
            yes: "Sure",
            showTextField: false,
            showTitle: true,
            cancelTap: () {
              Get.back(); // Dismiss the dialog
            },
            yesTap: () async {
              // Await the logout function to ensure it's completed
              await action.logout();
              Get.back(); // Close the dialog after logout
            },
          );
        }, text: 'Log Out',
      ),
      SizedBox(height: 4.h,),
          AppButtonWidget(
              fontWeight: FontWeight.w600,
              alignment: Alignment.center,
              width: 80.w,
              radius: 8,
              onPressed: () {
                MyCustomDialog.show(
                  title: "Delete Account?",
                  content: "Are you sure you want to Delete your Account",
                  cancel: "Cancel",
                  yes: "Sure",
                  showTextField: false,
                  showTitle: true,
                  cancelTap: () {
                    Get.back();
                  },
                  yesTap: () {
                    action.deleteUser();
                    Get.back();
                  },
                );
              },
              text: "Delete my Account"),
        ],
      )
    );
  }
}
