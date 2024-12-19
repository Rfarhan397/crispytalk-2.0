import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/app_text.dart.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../model/chatRoom/chatRoomModel.dart';
import '../../../model/res/constant/app_colors.dart';
import '../../../provider/chat/chatProvider.dart';
import '../chatListScreen/groupChat.dart';
import '../createGroup/createGroup.dart';

class GroupListScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    final userID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<List<Group>>(
      stream: StreamDataProvider().getAllGroupsStream(userID), // Pass the current user UID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups available.'));
        }

        final groups = snapshot.data!;

        return ListView.separated(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Dismissible(
              key: Key(group.groupId),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                chatProvider.deleteChat('groupChats',group.groupId);
              },
              child: ListTile(
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
                        admin: group.admin,
                      ),
                  );
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Divider(color: primaryColor.withOpacity(0.4),),
            );

        },
        );
      },
    );
  }
}
