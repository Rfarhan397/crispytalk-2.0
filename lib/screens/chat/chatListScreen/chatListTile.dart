import 'dart:developer';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../model/res/components/shimmer.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../provider/chat/chatProvider.dart';

class ChatTileScreen extends StatelessWidget {
  final String chatId;
  final String otherUserId;
  final String lastMessage;
  final String createdAt;

  const ChatTileScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.lastMessage,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context,listen: false);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: BuildChatShimmerEffect());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(
            title: AppTextWidget(
              text: 'Error loading user',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['name'] ?? 'Unknown User';
        final profileImage = userData['profileUrl'];
        final fcmToken = userData['fcmToken'];
        final bool userStatus = userData['isOnline'] ?? false;


        return ListTile(
          splashColor: const Color(0xffFEE3C8),
          onTap: () {

            chat.getChatID(
                friendId: chatId,
                context: context,
                name: username,
                image: profileImage,
                status: userStatus,
                fcmToken: fcmToken
            );
            log('fcm token in chat list is ::${fcmToken}, ${chatId}');

          },
          leading: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CircleAvatar(
                radius: 25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedShimmerImageWidget(imageUrl: profileImage),
              ),
              ),
              Positioned(
                bottom: 2,
                right: 3,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration:  BoxDecoration(
                    color: userStatus ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          title: AppTextWidget(
            text: username,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.start,
          ),
          subtitle: AppTextWidget(
            text: lastMessage,
            fontSize: 10,
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.start,
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppTextWidget(
                text: createdAt,
                fontSize: 10,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 2.2.h),
              // Container(
              //   height: 15,
              //   width: 15,
              //   decoration: BoxDecoration(
              //     color: const Color(0xffFEE3C8),
              //     borderRadius: BorderRadius.circular(50),
              //   ),
              //   child: const Center(
              //     child: AppTextWidget(
              //       text: '3',
              //       color: Colors.white,
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
