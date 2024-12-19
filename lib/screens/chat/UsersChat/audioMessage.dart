

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../../../constant.dart';
import '../../../model/chatMessage/chatMessageModel.dart';
import '../../../model/res/constant/app_colors.dart';
import '../../../model/res/widgets/app_text.dart.dart';

class ChatItemAudioMessage extends StatelessWidget {
  final bool isUser;
  final MessageModel message;

  const ChatItemAudioMessage({
    super.key,
    required this.isUser,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : const Color(0xffE7E9E8),
          borderRadius: isUser
              ? const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          )
              : const BorderRadius.only(
            bottomRight: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 60.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VoiceMessageView(
                playPauseButtonLoadingColor:
                isUser ?primaryColor : const Color(0xffA1A1BC),
                counterTextStyle: TextStyle(
                    color: isUser ? whiteColor : const Color(0xffA1A1BC),
                    fontSize: 11),
                circlesColor: whiteColor,
                circlesTextStyle: TextStyle(
                    color: isUser ? primaryColor : const Color(0xffA1A1BC),
                    fontSize: 10),
                activeSliderColor: isUser ? whiteColor : const Color(0xffA1A1BC),
                pauseIcon: Icon(
                  Icons.pause,
                  color: isUser ? primaryColor : const Color(0xffA1A1BC),
                ),
                playPauseButtonDecoration: const BoxDecoration(
                    color: whiteColor, shape: BoxShape.circle),
                backgroundColor:
                isUser ? primaryColor : const Color(0xffE7E9E8),
                playIcon: Icon(
                  Icons.play_arrow,
                  color: isUser ? primaryColor : const Color(0xffA1A1BC),
                ),
                cornerRadius: 8,
                controller: VoiceController(
                  audioSrc: message.message,
                  onComplete: () {},
                  onPause: () {},
                  onPlaying: () {},
                  onError: (err) {},
                  maxDuration:  const Duration(seconds: 20),
                  isFile: false,
                ),
                innerPadding: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}