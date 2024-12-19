import 'package:crispy/main.dart';
import 'package:crispy/provider/action/action_provider.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../model/res/widgets/cachedImage/cachedImage.dart';
import '../../model/user_model/user_model.dart';
import '../../provider/user_provider/user_provider.dart';
import '../myProfile/otherUserProfile/otherUserProfile.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CurrentUserProvider>(context,listen: false);
    final action = Provider.of<ActionProvider>(context,listen: false);
    final arguments = Get.arguments as Map<String, dynamic>;
    final String userId = arguments['userId'];
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        leading: AppBackButton(),
        centerTitle: true,
        title: AppTextWidget(text: 'Following',color: primaryColor,fontWeight: FontWeight.w700,fontSize: 18,),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center  ,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: primaryColor,

                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedShimmerImageWidget(imageUrl: provider.currentUser!.profileUrl )),
                  ),
                ),
                AppTextWidget(text: provider.currentUser!.name,color: primaryColor,fontSize: 22,fontWeight: FontWeight.w600,),
                AppTextWidget(text: provider.currentUser!.bio,color: AppColors.textGrey,fontSize: 10,fontWeight: FontWeight.w400,),
              ],
            ),
          ),
          StreamBuilder<List<UserModelT>>(
            stream: userId == provider.currentUser?.userUid ?
            StreamDataProvider().fetchCurrentUserFollowers(provider.currentUser?.userUid,'following'):
            StreamDataProvider().fetchCurrentUserFollowers(userId,'following'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primaryColor,));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No Followers Found."));
              }

              final followerList = snapshot.data ?? [];
            return ListView.builder(
                shrinkWrap: true,
                itemCount: followerList.length,
                itemBuilder: (context, index) {
                  final user = followerList[index];

                  return ListTile(
                      leading: GestureDetector(
                        onTap: () {
                         Get.to(OtherUserProfile(
                           userID: user.userUid,
                           userName: user.name,
                         ));
                        },
                        child: CircleAvatar(
                          radius: 25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedShimmerImageWidget(imageUrl: user.profileUrl),
                          ),
                        ),
                      ),
                      title: AppTextWidget(text:user.name.toString(),fontSize: 16,textAlign: TextAlign.start,fontWeight: FontWeight.w500,),
                      subtitle: AppTextWidget(text: '${user.followers.length} Followers',fontSize: 12,textAlign: TextAlign.start,fontWeight: FontWeight.w300,),
                      trailing:
                      userId == provider.currentUser?.userUid ?
                      GestureDetector(
                        onTap: () {
                          action.unFollowUser(currentUser, user.userUid);
                          provider.fetchCurrentUserDetails();
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: 80,
                          height: 30,
                          decoration: BoxDecoration(
                              color:  primaryColor,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Center(
                            child: Text( 'Remove',style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),),
                          ),
                        ),
                      ):null  );
                });  
            },
            
          )
        ],
      ),
    );
  }
}
