import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/user_model/user_model.dart';
import '../../provider/action/action_provider.dart';
import '../../provider/user_provider/user_provider.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> followers = Get.arguments ?? [];
    final provider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: const AppBackButton(),
        centerTitle: true,
        title: const AppTextWidget(
          text: 'Followers',
          color: primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Align(
          //   alignment: Alignment.center,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Container(
          //         height: 50,
          //         width: 50,
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(50),
          //           color: primaryColor,
          //         ),
          //         child: Padding(
          //           padding: const EdgeInsets.all(2.0),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(50),
          //             child: Image.asset(AppAssets.lady, fit: BoxFit.cover),
          //           ),
          //         ),
          //       ),
          //       const AppTextWidget(
          //         text: 'Samia',
          //         color: primaryColor,
          //         fontSize: 22,
          //         fontWeight: FontWeight.w600,
          //       ),
          //       const AppTextWidget(
          //         text: 'Samia234',
          //         color: AppColors.textGrey,
          //         fontSize: 10,
          //         fontWeight: FontWeight.w400,
          //       ),
          //     ],
          //   ),
          // ),
          FutureBuilder<List<UserModelT>>(
            future: fetchFollowerDetails(followers), // Fetch user details based on the followers' UIDs
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final followerList = snapshot.data ?? [];

              return ListView.builder(
                shrinkWrap: true,
                itemCount: followerList.length,
                itemBuilder: (context, index) {
                  final user = followerList[index];

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage:user.profileUrl.isNotEmpty? NetworkImage(user.profileUrl  ): AssetImage(AppAssets.noProfile), // Default image if null
                    ),
                    title: AppTextWidget(
                      text: user.name ?? "Unknown", // Show user name if available
                      fontSize: 16,
                      textAlign: TextAlign.start,
                      fontWeight: FontWeight.w500,
                    ),
                    subtitle: AppTextWidget(
                      text: user.email ?? "No nickname",
                      fontSize: 12,
                      textAlign: TextAlign.start,
                      fontWeight: FontWeight.w300,
                    ),
                    trailing: Consumer<ActionProvider>(
                     builder: (context, value, child) {
                       final isFollowed = value.isFollowed(user.userUid);

                       return GestureDetector(
                         onTap: () {
                         value.toggleFolloww(currentUser, user.userUid);
                           },
                         child: Container(
                           padding: const EdgeInsets.all(5),
                           width: 80,
                           height: 30,
                           decoration: BoxDecoration(
                             color:  primaryColor,
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Center(
                             child: Text(
                               isFollowed ? 'Follow ' : "Follow back",
                               style: const TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.w500,
                                 color: Colors.white,
                               ),
                             ),
                           ),
                         ),
                       );
                     },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<UserModelT>> fetchFollowerDetails(List<String> followerIds) async {
    final List<UserModelT> followers = [];
    for (String uid in followerIds) {
      final user = await fetchUserFromFirestore(uid);
      followers.add(user);
    }
    return followers;
  }

  Future<UserModelT> fetchUserFromFirestore(String uid) async {
    // Fetch user details from Firestore using the UID
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return UserModelT.fromMap(doc.data()!); // Assuming the UserModelT.fromMap method maps Firestore data to UserModelT
  }
}
