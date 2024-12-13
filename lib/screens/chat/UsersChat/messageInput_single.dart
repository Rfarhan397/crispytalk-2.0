import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../model/services/fcm/fcm_services.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';

class MessageInputFieldSingle extends StatefulWidget {
  final TextEditingController controller;
  final String chatId,token;

  const MessageInputFieldSingle({
    Key? key,
    required this.controller,
    required this.chatId, required this.token,
  }) : super(key: key);

  @override
  _MessageInputFieldSingleState createState() => _MessageInputFieldSingleState();
}

class _MessageInputFieldSingleState extends State<MessageInputFieldSingle> {
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        isTextEmpty = widget.controller.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final actionProvider = Provider.of<ActionProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(10),
      color: primaryColor,
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: widget.controller,
              hintText: "Type a message...",
              focusBdColor: Colors.white,
              fillColor: Colors.transparent,
              borderSides: true,
              radius: 50,
              hintColor: Colors.white,
              bdColor: Colors.white,
              enableBorderColor: Colors.white,
              suffixIcon: GestureDetector(
                onTap: () {
                  actionProvider.pickImages2(context, widget.chatId);

                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: SvgPicture.asset(
                    AppIcons.camera,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatProvider>(
            builder: (context, chat, child) {
              return GestureDetector(
                onTap: () {
                  if (!isTextEmpty) {
                    chat.sendTextMessage(
                      chatId: widget.chatId,
                      message: widget.controller.text.trim(),
                    );
                    FCMService().sendNotification(
                        widget.token,
                        'New Notification from CrispyTalk',
                        'You received a message! Click to check',
                        currentUser,
                    );
                    widget.controller.clear();
                  } else {
                    if(!chat.isRecording){
                      chat.startRecording();

                    }
                    if(chat.isRecording){
                      log('recording stop');
                      chat.stopRecording2(chatId: widget.chatId, context: context);
                    }
                    log("Mic icon pressed: Start recording!");
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      isTextEmpty ? AppIcons.mic
                          : AppIcons.share,
                      color:  chat.isRecording ? Colors.red : primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}