import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../constant.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';

class MessageInputField extends StatefulWidget {
  final TextEditingController controller;
  final String groupID;

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.groupID,
  }) : super(key: key);

  @override
  _MessageInputFieldState createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
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
                  actionProvider.pickImages(context, widget.groupID);

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
                    chat.sendGroupTextMessage(
                      groupID: widget.groupID,
                      message: widget.controller.text.trim(),
                    );
                    widget.controller.clear();
                  } else {
                    if(!chat.isRecording){
                      chat.startRecording();

                    }
                    if(chat.isRecording){
                      log('recording stop');
                      chat.stopRecording(chatId: widget.groupID, context: context);
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




