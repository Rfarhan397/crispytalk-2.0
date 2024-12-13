import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../../anum/user_type.dart';
import '../../../constant.dart';
import '../../../model/res/components/app_button_widget.dart';
import '../../../model/res/components/shimmer.dart';
import '../../../model/res/constant/app_assets.dart';
import '../../../model/res/routes/routes_name.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../provider/action/action_provider.dart';
import '../../../provider/stream/streamProvider.dart';
import '../../myProfile/otherUserProfile/otherUserProfile.dart';

class SuggestedUsers extends StatefulWidget {
  final String currentUserId; // Pass the current user's ID

  const SuggestedUsers({required this.currentUserId, super.key});

  @override
  _SuggestedUsersState createState() => _SuggestedUsersState();
}

class _SuggestedUsersState extends State<SuggestedUsers> {
  bool isSuggestionVisible = true;

  @override
  Widget build(BuildContext context) {
    log('build 1');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSuggestionVisible)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: const AppTextWidget(
                  text: 'Suggested for you',
                  color: primaryColor,
                  fontSize: 18,
                ),
              ),
              Container(
                height: 160,
                color: const Color(0xffD9D9D9),
                child: Stack(
                  children: [
                    SuggestionList(currentUserId: widget.currentUserId),
                    Positioned(
                      top: 3,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isSuggestionVisible = false;
                          });
                        },
                        child: Icon(Icons.close, color: primaryColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class SuggestionList extends StatelessWidget {
  final String currentUserId;

  SuggestionList({required this.currentUserId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('No suggestions available.'));
        }

        // Get the list of blocked user IDs
        final currentUserData = userSnapshot.data!.data() as Map<String, dynamic>;
        final blockedUserIds = List<String>.from(currentUserData['blocks'] ?? []);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SuggestionCardShimmer();
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No suggestions available.'));
            }

            // Filter out the current user and blocked users
            final users = snapshot.data!.docs.where((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              final uid = userData['userUid'] ?? '';
              return uid != currentUserId && !blockedUserIds.contains(uid);
            }).toList();

            if (users.isEmpty) {
              return const Center(child: Text('No suggestions available.'));
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Get.to(OtherUserProfile(
                      userID: user['userUid'],
                      userName: user['name'],
                    ));
                  },
                  child: SuggestionCard(
                    profileImage: user['profileUrl'] ?? '', // Use empty string as fallback
                    username: user['name'] ?? 'Unknown User',
                    email: user['email'] ?? 'Unknown Email',
                    userId: user['userUid'], // Pass the unique user ID
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class SuggestionCard extends StatelessWidget {
  final String profileImage;
  final String username;
  final String email;
  final String userId;

  const SuggestionCard({
    required this.profileImage,
    required this.username,
    required this.email,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = currentUser;
    final firestore = FirebaseFirestore.instance;

    return Container(
      width: 25.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedShimmerImageWidget(imageUrl: profileImage),
            )
          ),
          SizedBox(height: 0.5.h),
          AppTextWidget(
            text: username,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            maxLines: 1,
          ),
          AppTextWidget(
            text: email,
            fontSize: 11,
            color: const Color(0xff6F6D6D),
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          FutureBuilder<DocumentSnapshot>(
            future: firestore.collection('users').doc(userId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildAppButtonWidget(true,context,'');
              }
              if (snapshot.hasError) {
                return const Text("Error");
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Text("User not found");
              }

              final userDoc = snapshot.data!;

              final followers = List<String>.from(userDoc['followers'] ?? []);
              final isFollowed = followers.contains(currentUserId);

              return buildAppButtonWidget(isFollowed, context, currentUserId);
            },
          ),
        ],
      ),
    );
  }

  AppButtonWidget buildAppButtonWidget(bool isFollowed, BuildContext context, String currentUserId) {
    return AppButtonWidget(
              width: 20.w,
              alignment: Alignment.center,
              height: 3.h,
              radius: 100,
              buttonColor: isFollowed ? Colors.grey : primaryColor,
              textColor: Colors.white,
              onPressed: () async {
                final action = Provider.of<ActionProvider>(context, listen: false);
                await action.toggleFollow(currentUserId, userId);
              },
              fontSize: 13,
              fontWeight: FontWeight.w500,
              text: isFollowed ? 'Following' : 'Follow',
            );
  }
}
