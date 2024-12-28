import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import '../../../constant.dart';
import '../../../model/res/components/app_button_widget.dart';
import '../../../model/res/components/shimmer.dart';
import '../../../model/res/widgets/app_text.dart.dart';
import '../../../provider/action/action_provider.dart';
import '../../myProfile/otherUserProfile/otherUserProfile.dart';
import '../../../provider/suggested_users/suggested_users_provider.dart';

class SuggestedUsers extends StatefulWidget {
  final String currentUserId;

  const SuggestedUsers({required this.currentUserId, super.key});

  @override
  _SuggestedUsersState createState() => _SuggestedUsersState();
}

class _SuggestedUsersState extends State<SuggestedUsers> {
  bool isSuggestionVisible = true;

  @override
  void initState() {
    super.initState();
    // Fetch suggested users when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SuggestedUsersProvider>(context, listen: false)
          .fetchSuggestedUsers(widget.currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                height: 16.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffD9D9D9),
                ),
                child: Stack(
                  children: [
                    SuggestionList(currentUserId: widget.currentUserId),
                    Positioned(
                      top: 3,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: primaryColor, size: 20),
                        onPressed: () =>
                            setState(() => isSuggestionVisible = false),
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

  const SuggestionList({required this.currentUserId, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestedUsersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SuggestionCardShimmer();
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final users = provider.suggestedUsers;
        if (users.isEmpty) {
          return const Center(child: Text('No suggestions available.'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            return GestureDetector(
              onTap: () => Get.to(() => OtherUserProfile(
                    userID: userData['userUid'],
                    userName: userData['name'],
                  )),
              child: SuggestionCard(
                profileImage: userData['profileUrl'] ?? '',
                username: userData['name'] ?? 'Unknown User',
                // email: userData['email'] ?? 'Unknown Email',
                userId: userData['userUid'],
              ),
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
  // final String email;
  final String userId;

  const SuggestionCard({
    required this.profileImage,
    required this.username,
    // required this.email,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<CurrentUserProvider>(context, listen: false);

    return Container(
      width: 25.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedShimmerImageWidget(imageUrl: profileImage),
              )),
          SizedBox(height: 0.5.h),
          AppTextWidget(
            text: username.capitalizeFirst.toString(),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            maxLines: 1,
          ),
          // AppTextWidget(
          //   text: email,
          //   fontSize: 11,
          //   color: const Color(0xff6F6D6D),
          //   fontWeight: FontWeight.w500,
          //   overflow: TextOverflow.ellipsis,
          // ),
          SizedBox(height: 1.h),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }

              final isFollowed = snapshot.hasData &&
                  snapshot.data!.exists &&
                  (snapshot.data!.data() as Map<String, dynamic>)['followers']
                          ?.contains(currentUser) ==
                      true;

              return AppButtonWidget(
                width: 20.w,
                alignment: Alignment.center,
                height: 3.h,
                radius: 100,
                buttonColor: isFollowed ? primaryColor : Colors.grey,
                textColor: Colors.white,
                onPressed: () =>
                    Provider.of<ActionProvider>(context, listen: false)
                        .toggleFollow(currentUser, userId)
                        .then((_) {
                  current.fetchCurrentUserDetails();
                }),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                text: isFollowed ? 'Following' : 'Follow',
              );
            },
          ),
        ],
      ),
    );
  }
}
