import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/user_model/user_model.dart';
import '../../provider/action/action_provider.dart';

class FollowersScreen extends StatelessWidget {
  const FollowersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentU = Provider.of<CurrentUserProvider>(context, listen: false);
    final action = Provider.of<ActionProvider>(context, listen: false);
    final arguments = Get.arguments as Map<String, dynamic>;
    final String userId = arguments['userId'];

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
          StreamBuilder<List<UserModelT>>(
            stream: userId == currentU.currentUser?.userUid ? 
              StreamDataProvider().fetchCurrentUserFollowers(currentU.currentUser!.userUid, 'followers') :
              StreamDataProvider().fetchCurrentUserFollowers(userId, 'followers'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No Followers Found."));
              }

              final followerList = snapshot.data ?? [];

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: followerList.length,
                  itemBuilder: (context, index) {
                    final user = followerList[index];

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedShimmerImageWidget(imageUrl: user.profileUrl),
                        ),
                      ),
                      title: AppTextWidget(
                        text: user.name ?? "Unknown",
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
                      trailing: userId == currentU.currentUser?.userUid ? 
                        GestureDetector(
                          onTap: () async {
                            await action.removeUser(currentU.currentUser!.userUid, user.userUid);
                            await currentU.fetchCurrentUserDetails();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                "Unfollow",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ) : null,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
