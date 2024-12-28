import 'dart:developer';

import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../constant.dart';
import '../../../model/chatMessage/chatMessageModel.dart';
import '../../../model/chatRoom/chatRoomModel.dart';
import '../../../model/res/components/fullImagePreview.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../../model/services/fcm/fcm_services.dart';
import '../../../model/services/fcm/rehman_fcm.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';
import '../../../provider/question/questionProvider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../call/audioCall/audio.dart';
import '../../call/videoCall/video.dart';
import 'audioMessage.dart';
import 'messageInput.dart';
import 'messageInput_single.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  TextEditingController messageController = TextEditingController();
  final String name = Get.arguments['name'];
  final String image = Get.arguments['image'];
  final String fcmToken = Get.arguments['fcmToken'] ?? "null";
  final bool status = Get.arguments['isOnline'] ?? false;
  final ChatRoomModel chat = Get.arguments['chat'];
  @override
  Widget build(BuildContext context) {
    final action = Provider.of<ActionProvider>(context, listen: false);
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
        title: ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
                color: whiteColor, borderRadius: BorderRadius.circular(50),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: image.isNotEmpty ? CachedShimmerImageWidget(imageUrl: image):Image.asset(AppAssets.noProfile),
            ),
          ),
          title: AppTextWidget(
            text: name.isNotEmpty ? name : 'Unknown',
            textAlign: TextAlign.start,
            color: Colors.white,
            fontSize: 15,
          ),
          subtitle: AppTextWidget(
              text: status == true ? 'Online' : 'Offline',
              textAlign: TextAlign.start,
              color: Colors.white),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                log('click video icon');
                audioCall(context);
              },
              child: SvgPicture.asset(AppIcons.call, height: 18)),
          const SizedBox(width: 16),
          GestureDetector(
              onTap: () {
                sendCallRequest(context);
              },
              child: SvgPicture.asset(AppIcons.videoCall, height: 18)),
          const SizedBox(width: 16),
          GestureDetector(
              onTap: () => Get.back(),
              child: SvgPicture.asset(AppIcons.more, height: 18)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(builder: (context, value, child) {
              return StreamBuilder<List<MessageModel>>(
                stream: value.getMessages(chat.docId),
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
          // ),
          MessageInputFieldSingle(
            controller: messageController,
            chatId: chat.docId,
            token: fcmToken,
          ),
        ],
      ),
    );
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
                  actionProvider.deleteMessage(
                      'chats', message.id.toString(), chat.docId);
                }
              },
              child: message.type == 'text'
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isSender ? primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppTextWidget(
                        text: message.message,
                        color: isSender ? Colors.white : Colors.black,
                      ),
                    )
                  : message.type == 'audio'
                      ? Container(
                          width: 60.w,
                          decoration: BoxDecoration(
                            color: isSender ? primaryColor : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ChatItemAudioMessage(
                            message: message,
                            isUser: isSender,
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Get.to(FullImagePreview(
                              image: message.message,
                            ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSender ? primaryColor : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.network(
                              message.message,
                              fit: BoxFit.cover,
                              // width: 50.w,
                              height: 20.h,
                            ),
                          ),
                        )
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

  void audioCall(context) async {
    final id = generateRandomId();
    final  user = Provider.of<CurrentUserProvider>(context,listen: false).currentUser;

    Get.to(
      () => AudioCallScreen(
        callId: id,
        isCaller: true,
        callerImage: user!.profileUrl,
        callerName: user.name,
      ),
    );

    FCMServiceR().sendNotification(
      fcmToken,
      'Audio Call Request',
      '${user!.name} is calling you ...',
      user.userUid,
      additionalData: {
        'callID': id,
        'name': user.name,
        'image': user.profileUrl,
        'isVideo': 'false',
        'token': user.fcmToken
      },
    );
  }

  void sendCallRequest(BuildContext context) async {
    final id = generateRandomId();
    final user = Provider.of<CurrentUserProvider>(context,listen: false).currentUser;

    Get.to(
      () => VideoCallScreen(
        callId: id,
        isCaller: true,
        callerImage: user!.profileUrl,
        callerName: user.name,
      ),
    );
    FCMServiceR().sendNotification(
      fcmToken,
      'Video Call Request',
      '${user?.name} is calling you ...',
      user!.userUid,
      additionalData: {
        'callID': id,
        'name': user.name,
        'image': user.profileUrl,
        'isVideo': 'true',
        'token': user.fcmToken
      },
    );
  }
}
