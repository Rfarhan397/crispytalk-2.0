
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/constant/app_utils.dart';
import 'package:crispy/model/res/routes/routes_name.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/model/res/widgets/customDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/chatMessage/chatMessageModel.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/button_widget.dart';
import '../../../model/services/fcm/fcm_services.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';
import '../../../provider/profile/profileProvider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../call/audioCall/audio.dart';
import '../Groups/groupList.dart';
import '../UsersChat/audioMessage.dart';
import '../UsersChat/messageInput.dart';

class GroupChatScreen extends StatelessWidget {
  final String groupName;
  final String groupImage;
  final String groupID;

  GroupChatScreen({super.key, required this.groupName, required this.groupImage, required this.groupID,});
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final action = Provider.of<ActionProvider>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        shadowColor: primaryColor,
        centerTitle: false, 
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(Icons.arrow_back_ios,
                size: 18, color: Colors.white)),
        title: GestureDetector(
          onTap: () async {

            Get.toNamed(RoutesName.editGroupDetails,
            arguments: {
              'groupName': groupName,
              'groupImage': groupImage,
              'groupID': groupID,


            }
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: whiteColor, borderRadius: BorderRadius.circular(50)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: groupImage.isNotEmpty
                      ? Image.network(groupImage)
                      : Image.asset(fit: BoxFit.cover, AppAssets.noProfile)),
            ),
            title: AppTextWidget(
              text: groupName.isNotEmpty ? groupName : 'Unknown',
              textAlign: TextAlign.start,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                audioCall();
              },
              child: SvgPicture.asset(AppIcons.call, height: 18)),
          const SizedBox(width: 16),
          GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(AppIcons.videoCall, height: 18)),
          const SizedBox(width: 16),
          GestureDetector(
              onTap: () {},
              child: SvgPicture.asset(AppIcons.more, height: 18)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(builder: (context, value, child) {
              return StreamBuilder<List<MessageModel>>(
                stream: value.getGroupMessages(groupID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                        ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No Messages available'));
                  }
                  final messages = snapshot.data ?? [];

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      return _buildMessageBubble(context, action, message,
                          isSender: message.senderId == currentUser,
                          time: message.createdAt);
                    },
                    padding: const EdgeInsets.all(8.0),
                  );
                },
              );
            }),
          ),
          MessageInputField(
            controller: messageController,
            groupID: groupID,
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: groupName);
    MyCustomDialog.show(
      title: 'Edit Group Name',
      showTextField: true,
      content: "Change Group Name",
      cancel: "Cancel",
      yes: "Save",
      hintText: 'Enter Group Name',
      color: Colors.black,
      showTitle: true,
      textController: nameController,
      cancelTap: () {
        Get.back();
      },
      yesTap: () async {
        try {
          if (nameController.text.trim().isEmpty) {
            AppUtils().showToast(text: 'Please enter a group name');
            return;
          }

          await FirebaseFirestore.instance
              .collection('groupChats')
              .doc(groupID)
              .update({
            'groupName': nameController.text.trim()
          });

          AppUtils().showToast(text: 'Group name updated successfully');
          Get.back();
        } catch (e) {
          log('Error updating group name: $e');
          AppUtils().showToast(text: 'Error updating group name');
        }
      },
    );
  }

  void _showImagePicker(BuildContext context, ProfileProvider provider) {
    Get.bottomSheet(
      Container(
        width: 100.w,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedShimmerImageWidget(imageUrl: provider.imageUrl.toString()),
              
              ) ,
            ),
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Gallery",
              onClicked: provider.pickProfileImage,
            ),
            const SizedBox(height: 20),
            ButtonWidget(
              height: 5.h,
              width: 40.w,
              fontWeight: FontWeight.w400,
              text: "Camera",
              onClicked: provider.pickProfileImageFromCamera,
            ),
          ],
        ),
      ),
    );
  }


  void _showAddMembersDialog(BuildContext context) {
    // Add implementation for adding members
  }

  void _showRemoveMembersDialog(BuildContext context) {
    // Add implementation for removing members
  }

  // Message Bubble
  Widget _buildMessageBubble(
      context, ActionProvider actionProvider, MessageModel message,
      {required bool isSender, required String time}) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () async {
              bool? deleteConfirmed =
              await actionProvider.showDeleteConfirmationDialog(context);

              if (deleteConfirmed == true) {
                actionProvider.deleteMessage('groupChats',message.id.toString(),groupID);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isSender ? primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: message.type == 'text'
                  ? AppTextWidget(
                text: message.message,
                color: isSender ? Colors.white : Colors.black,
              )
                  : message.type == 'audio'
                  ? ChatItemAudioMessage(
                message: message,
                isUser: isSender,
              )
                  : Container(
                height: 25.h,
                width: 70.w,
                child: Image.network(
                  message.message,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Align(
            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: AppTextWidget(
              text: time,
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  void audioCall() async {
    final id = generateRandomId();
    final user = await StreamDataProvider().getCurrentUser();
    final otherUser = await StreamDataProvider().getGroupMembers(groupID);
    for (var member in otherUser) {
      if (member.userUid == currentUser) {return ;};
      AppUtils().showToast(text: 'Call Started');
      Get.to(
            () => AudioCallScreen(
          callId: id,
          isCaller: true,
          callerImage: groupImage,
          callerName: groupName,
        ),
      );
      FCMService().sendNotification(
        member.fcmToken.toString(),
        'Audio Call Request',
        '${user.name} is group calling you ...',
        user.userUid,
        additionalData: {
          'callID': id,
          'name': user.name,
          'image': user.profileUrl,
          'isVideo': 'false',
          'token': user.fcmToken,
        },
      );
    }}
}
