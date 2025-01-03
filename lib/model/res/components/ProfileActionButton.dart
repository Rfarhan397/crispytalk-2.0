import 'dart:developer';

import 'package:crispy/model/services/fcm/rehman_fcm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';
import '../../user_model/user_model.dart';
import '../constant/app_icons.dart';
import '../routes/routes_name.dart';
import 'app_button_widget.dart';

class OtherActionButton extends StatelessWidget {
  final UserModelT postData;

  const OtherActionButton(this.postData, {super.key});

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context, listen: false);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<ActionProvider>(
            builder: (context, actionProvider, _) {
              return AppButtonWidget(
                radius: 8,
                onPressed: () {
                  actionProvider.toggleFollow(currentUser, postData.userUid);
                },
                text: actionProvider.isFollowed(
                    postData.userUid,
                    postData.followers
                ) ? "Following" : "Follow",
              );
            }
        ),
        const SizedBox(width: 5),
        AppButtonWidget(
          radius: 8,
          onPressed: () => _handleMessagePress(chat, context),
          text: "Message",
        ),
      ],
    );
  }

  void _handleMessagePress(ChatProvider chat, BuildContext context) {
    log('friendId ${postData.userUid}');
    chat.getChatID(
        friendId: postData.userUid,
        context: context,
        name: postData.name,
        image: postData.profileUrl,
        fcmToken: postData.fcmToken,
        status: postData.isOnline);
  }
}

////current user profile


class ProfileActions extends StatelessWidget {
  const ProfileActions(this.profile, {super.key});
  final String profile;
  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButtonWidget(
          prefixIcon: SvgPicture.asset(AppIcons.editProfile),
          onPressed: () async {
            Get.toNamed(RoutesName.editProfile);
          },
          text: "Edit Profile",
          radius: 12,
        ),
        SizedBox(width: 2.w),
        AppButtonWidget(
          prefixIcon: SvgPicture.asset(AppIcons.shareProfile),
          onPressed: () {
            share(profile);
          },
          text: "Share Profile",
          radius: 12,
        ),
      ],
    );
  }

  void share(String mediaUrl) {
    if (mediaUrl.isNotEmpty) {
      Share.share(mediaUrl, subject: "Check out this profile!");
    }
  }
}
