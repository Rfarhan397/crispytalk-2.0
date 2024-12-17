import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../constant.dart';
import '../../../model/chatRoom/chatRoomModel.dart';
import '../../../model/res/constant/app_icons.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../model/res/widgets/app_text_field.dart';
import '../../../model/user_model/user_model.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/chat/chatProvider.dart';
import '../../../provider/user_provider/user_provider.dart';
import 'chatListTile.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding:  EdgeInsets.only(top: 2.h),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 85.w,
                      decoration: const BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(18),
                              topRight: Radius.circular(18)
                          )
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SvgPicture.asset(AppIcons.search),
                          ),
                          Expanded(
                            child: AppTextField(
                              focusBdColor: Colors.transparent,
                              controller: _searchController,
                              onChanged: (value) {
                                provider.searchUsers(value); // Trigger search
                              },
                              hintText: "Search",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                provider.searchUsers('');
                              },
                              child: SvgPicture.asset(AppIcons.close),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 2.w),
                      child: GestureDetector(
                          onTap: () {Get.toNamed(RoutesName.createGroup);
                          },
                          child: SvgPicture.asset(AppIcons.createGroup)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // User List
              StreamBuilder<List<ChatRoomModel>>(
                stream: chatProvider.getChatRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: AppTextWidget(text: 'Loading...'));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: AppTextWidget(
                          text: 'Something went wrong.. ${snapshot.error}',
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    );
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: AppTextWidget(
                          text: 'No chats available.',
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          fontSize: 15),
                    );
                  }
                  final chats = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final otherUserId = chat.users.firstWhere((id) => id != currentUser);
                      return ChatTileScreen(
                        chatId: chat.users.firstWhere((id) => id != currentUser),
                        otherUserId: otherUserId,
                        lastMessage: chat.lastMessage,
                        createdAt: chat.createdAt,
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> buildMenuItem(BuildContext context, String value, ActionProvider menuProvider) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: menuProvider.selectedItem == value ? const Color(0xffEDFE19) : Colors.transparent,
        ),
        child: Text(
          value,
          style: TextStyle(
            color: menuProvider.selectedItem == value ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}