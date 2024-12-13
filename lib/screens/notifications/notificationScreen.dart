
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constant.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/constant/app_colors.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/notification/notificationProvider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 25.h,
            decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16))),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar

                 Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.white
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(

                                top: 2.0,
                              left: 8,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: primaryColor,size: 15,),
                          ),
                        ),
                      ),
                      // AppBackButton(color: Colors.white,buttonColor: primaryColor,),
                      SizedBox(width: 16),
                      AppTextWidget(text:
                        "Notification",
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h,),
                // Segmented Control for "Today" and "Last Week"
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    return Container(
                      width: 80.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              notificationProvider.updateIndex(0);
                            },
                            child: AnimatedContainer(
                              height: 4.h,
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: notificationProvider.selectedIndex == 0
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:  EdgeInsets.symmetric(
                               // vertical: 10,
                                horizontal: 10.w,
                              ),
                              child: Center(
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    color: notificationProvider.selectedIndex == 0
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Custom Button for "Last Week"
                          GestureDetector(
                            onTap: () {
                              notificationProvider.updateIndex(1);
                            },
                            child: AnimatedContainer(
                              height: 4.h,
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: notificationProvider.selectedIndex == 1
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),

                              ),
                              padding:  EdgeInsets.symmetric(
                                //vertical: 10,
                                horizontal: 10.w,
                              ),
                              child: Center(
                                child: Text(
                                  'Last Week',
                                  style: TextStyle(
                                    color: notificationProvider.selectedIndex == 1
                                        ? Colors.white
                                        : primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                 SizedBox(height: 5.h),

                // Notification List
                Expanded(
                  child: Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, _) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (notificationProvider.selectedIndex == 0) ...[
                            // Section: Earlier this Day (for "Today")
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppTextWidget(text:
                                  'Earlier this Day',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                ),
                                AppTextWidget(text:
                                  'See all',
                                    color: primaryColor,
                                    fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            NotificationCard(
                              title: 'Reminder',
                              subtitle: 'Started Following you',
                              time: '1 min ago',
                              actionText: 'Follow Back',
                            ),
                            NotificationCard(
                              title: 'Alexa',
                              subtitle: 'Liked your video',
                              time: '1 min ago',
                              actionText: 'Follow Back',
                            ),
                          ] else ...[
                            // Section: Last Week (for "Last Week")
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Last Week',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'See all',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            NotificationCard(
                              title: 'Reminder',
                              subtitle: 'Started Following you',
                              time: '1 min ago',
                              actionText: 'Follow Back',
                            ),
                          ]
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String actionText;

  NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Colors.white,
        shadowColor: AppColors.textGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                height: 24,
                width: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(AppAssets.lady,fit: BoxFit.cover,)),
              ),
               SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextWidget(text:
                      title,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      color: Color(0xff6F6D6D),
                    ),
                     SizedBox(height: 0.5.h),
                    AppTextWidget(
                      text: subtitle,
                      color: Color(0xff6F6D6D),
                      fontSize: 12,),
                  ],
                ),
              ),
              Column(
                children: [
                  AppTextWidget(text: time, color: Colors.grey),
                  SizedBox(height: 1.h,),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: 80,  // Set the desired width
                    height: 30,
                    decoration: BoxDecoration(
                        color:  primaryColor,
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Center(
                      child: Text(actionText,style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
