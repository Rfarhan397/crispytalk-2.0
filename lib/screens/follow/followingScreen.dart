import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';
import '../../model/res/components/app_back_button.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/user_provider/user_provider.dart';

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context); // Access UserProvider
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
                        child: Image.asset(AppAssets.lady,fit: BoxFit.cover,)),
                  ),
                ),
                AppTextWidget(text: 'Samia',color: primaryColor,fontSize: 22,fontWeight: FontWeight.w600,),
                AppTextWidget(text: 'Samia234',color: AppColors.textGrey,fontSize: 10,fontWeight: FontWeight.w400,),
              ],
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: provider.users.length,
              itemBuilder: (context, index) {
                final user = provider.users[index];

                return ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(user.imageUrl.toString()),
                    ),
                    title: AppTextWidget(text:user.username.toString(),fontSize: 16,textAlign: TextAlign.start,fontWeight: FontWeight.w500,),
                    subtitle: AppTextWidget(text: '${user.nickname} \n${user.followers} Followers',fontSize: 12,textAlign: TextAlign.start,fontWeight: FontWeight.w300,),
                    trailing: GestureDetector(
                      onTap: () {
                        provider.toggleFollowStatus(user);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                            color: user.isFollowing ? Colors.grey : primaryColor,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Center(
                          child: Text(user.isFollowing ? 'Following' : 'Follow back',style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),),
                        ),
                      ),
                    ));
              })
        ],
      ),
    );
  }
}
