// // custom_sidebar.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
//
// import '../../../constant.dart';
// import '../../../provider/constant/action_provider.dart';
// import '../constant/app_icons.dart';
// import '../widgets/app_text.dart.dart';
//
// class CustomSidebar extends StatelessWidget {
//   final List<Map<String, dynamic>> menuItems = [
//     {'icon': AppIcons.ic_menu, 'title': 'Menu'},
//     {'icon': AppIcons.ic_profile, 'title': 'View Profile'},
//     {'icon': AppIcons.ic_order, 'title': 'Orders'},
//     {'icon': AppIcons.ic_subscription, 'title': 'Subscription'},
//     {'icon': AppIcons.ic_business, 'title': 'Maze Khana for Maiz Khana'},
//     {'icon': AppIcons.ic_invite, 'title': 'Invite Friends'},
//     {'icon': AppIcons.ic_setting, 'title': 'Setting'},
//     {'icon': AppIcons.ic_helpcenter, 'title': 'Help Centre'},
//   ];
//
//   final screens = [
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//     // SettingScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final menuProvider = Provider.of<ActionProvider>(context);
//
//     return Drawer(
//       child: Container(
//         color: Colors.purple,
//         child: Column(
//           children: [
//
//            const UserAccountsDrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.purple,
//               ),
//               accountName: Text('Rehman', style: TextStyle(fontSize: 24)),
//               currentAccountPicture: CircleAvatar(
//                 backgroundImage: NetworkImage('https://i.sstatic.net/l60Hf.png'), // Replace with your image URL
//               ), accountEmail: Text(""),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: menuItems.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading: Image.asset(menuItems[index]['icon'], color: Colors.white,width: 24.0,height: 24.0,),
//                     title: Text(menuItems[index]['title'], style: TextStyle(color: Colors.white)),
//                     selected: menuProvider.selectedIndex == index,
//                     onTap: () {
//                       menuProvider.selectMenu(index);
//                       Navigator.pop(context); // Close the drawer
//                       // Navigate to the respective screen
//
//                       Get.to(screens[index]);
//                       // Navigator.push(
//                       //   context,
//                       //   MaterialPageRoute(builder: (context) => MenuScreen(index: index)),
//                       // );
//                     },
//                   );
//                 },
//               ),
//             ),
//             Align(
//               alignment: AlignmentDirectional.center,
//               child: Container(
//                 width: Get.width,
//                 padding: EdgeInsets.all(20.0),
//                 margin: EdgeInsets.all(Get.width * 0.15),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Stack(
//                   children: [
//                     SizedBox(width: Get.width * 0.063),
//                     Image.asset(
//                       AppIcons.ic_logout,
//                       color: primaryColor,
//                       width: 24.0,
//                       height: 24.0,
//                     ),
//                    const Align(
//                         alignment: AlignmentDirectional.center,
//                         child: AppTextWidget(
//                             text: "Log Out",
//                           fontSize: 18.0,
//                           color: primaryColor,
//                           fontWeight: FontWeight.bold,
//                         )),
//
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
