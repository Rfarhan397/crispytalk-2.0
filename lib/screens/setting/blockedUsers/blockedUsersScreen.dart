import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/res/components/app_back_button.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_utils.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/button_widget.dart';
import '../../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../../model/user_model/user_model.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../myProfile/otherUserProfile/otherUserProfile.dart';

class BlockedUserScreen extends StatelessWidget {
  const BlockedUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: AppBackButton(),
          title: AppTextWidget(text: 'Blocked User',fontSize: 18,),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<List<UserModelT>>(
              stream: StreamDataProvider().getBlockedUsers(currentUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: AppTextWidget(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 16,
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: AppTextWidget(
                      text: 'No blocked users found',
                      fontSize: 16,
                    ),
                  );
                }
                List<UserModelT> users = snapshot.data!;
                print("Users Data :users");
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    UserModelT user = users[index];
                    return buildBlockUsers(context,user);
                  },
                );
              },
            ),
          ],
        )
    );
  }

  Widget buildBlockUsers(context,UserModelT user) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: customGrey
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {

                Get.to(OtherUserProfile(
                        userID: user.userUid,
                        userName: user.name));
              },
              child: Row(
                children: [
                  CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedShimmerImageWidget(
                    imageUrl: user.profileUrl,
                    ),
                  ),
                  ),
                  SizedBox(width: 2.w,),
                  Column(
                    children: [
                      AppTextWidget(text: user.name,fontSize: 16,),
                    ],
                  ),
                ],
              ),
            ),
            ButtonWidget(
                text: 'Unblock',
                onClicked: () {
                  unBlockUser(currentUser,user.userUid,user.name);
                  Navigator.pop(context);
                },
                width: 20.w,
                height: 4.h,
                radius: 8,
                fontWeight: FontWeight.w400)
          ],
        ),
      ),
    );
  }
  Future<void> unBlockUser(String currentUserId, String userId, String name) async {
    try {
      // Remove the userId from the current user's blocks list
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'blocks': FieldValue.arrayRemove([userId]),
      });

      AppUtils().showToast(
        text: 'You Unblocked $name',
        bgColor: primaryColor,
      );

      log("User $userId successfully unblocked by $currentUserId");
    } catch (e) {
      log("Error unblocking user $userId: $e");
    }
  }
}