import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constant.dart';
import '../../../model/chatRoom/chatRoomModel.dart';
import '../../../model/res/constant/app_colors.dart';
import '../chatListScreen/groupChat.dart';
import '../createGroup/createGroup.dart';

class GroupListScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<Group>>(
      stream: StreamDataProvider().getAllGroupsStream(userID), // Pass the current user UID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No groups available.'));
        }

        final groups = snapshot.data!;

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 25,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedShimmerImageWidget(imageUrl: group.groupImage),
                )// No icon if there's an image
              ),
              title: AppTextWidget(text:
                group.groupName,
                textAlign: TextAlign.start,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              subtitle: AppTextWidget(text:
                ' ${group.lastMessage}',
                textAlign: TextAlign.start,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
              onTap: () {
                Get.to(
                    GroupChatScreen(
                      groupName: group.groupName,
                      groupImage: group.groupImage,
                      groupID: group.groupId,
                    ));
              },
            );
          },
        );
      },
    );
  }
}



