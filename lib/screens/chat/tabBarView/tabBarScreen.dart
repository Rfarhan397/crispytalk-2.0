import 'package:crispy/constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Groups/groupList.dart';
import '../chatListScreen/chatListScreen.dart';


class TabViewScreen extends StatelessWidget {
  const TabViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          title: const TabBar(
            dividerColor: secondaryColor,
            indicatorColor: secondaryColor,
            labelColor: secondaryColor,
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Groups'),
            ],
          ),
        ),
        body:  TabBarView(
          children: [
            ChatListScreen(),
            GroupListScreen(),
          ],
        ),
      ),
    );
  }
}


