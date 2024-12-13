import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Groups/groupList.dart';
import '../chatListScreen/chatListScreen.dart';


class TabViewScreen extends StatelessWidget {
  const TabViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs (Chats and Groups)
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const TabBar(
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


