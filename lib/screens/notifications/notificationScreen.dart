import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crispy/model/res/widgets/cachedImage/cachedImage.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../constant.dart';
import '../../model/res/constant/app_assets.dart';
import '../../model/res/widgets/app_text.dart.dart';
import '../../provider/notification/notificationProvider.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

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
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: primaryColor,
                            size: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const AppTextWidget(
                        text: "Notification",
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                // Segmented Control for Tabs
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    return Container(
                      width: 80.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => notificationProvider.updateIndex(0),
                            child: AnimatedContainer(
                              height: 4.h,
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: notificationProvider.selectedIndex == 0
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    color:
                                        notificationProvider.selectedIndex == 0
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
                          GestureDetector(
                            onTap: () => notificationProvider.updateIndex(1),
                            child: AnimatedContainer(
                              height: 4.h,
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                color: notificationProvider.selectedIndex == 1
                                    ? primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Last Week',
                                  style: TextStyle(
                                    color:
                                        notificationProvider.selectedIndex == 1
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
                SizedBox(height: 3.h),
                // Notification List
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser)
                        .collection('notifications')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: AppTextWidget(
                            text: "No notifications yet.",
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        );
                      }

                      final notifications = snapshot.data!;
                      // final todayNotifications = notifications.where((notification) {
                      //   final notificationDate = DateTime.fromMillisecondsSinceEpoch(int.parse(notification['timestamp']));
                      //   return _isToday(notificationDate);
                      // }).toList();

                      // final lastWeekNotifications = notifications.where((notification) {
                      //   final notificationDate = DateTime.fromMillisecondsSinceEpoch(int.parse(notification['timestamp']));
                      //   return !_isToday(notificationDate);
                      // }).toList();
                      //
                      // return Consumer<NotificationProvider>(
                      //   builder: (context, notificationProvider, _) {
                      //     final selectedNotifications = notificationProvider.selectedIndex == 0
                      //         ? todayNotifications
                      //         : lastWeekNotifications;
                      //
                      //     if (selectedNotifications.isEmpty) {
                      //       return const Center(
                      //         child: AppTextWidget(
                      //           text: "No notifications in this category.",
                      //           fontSize: 16,
                      //           color: Colors.grey,
                      //         ),
                      //       );
                      //     }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.docs.length,
                        itemBuilder: (context, index) {
                          final notification = notifications.docs[index];
                          return Text(index.toString());
                        },
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    final now = DateTime.now();

    if (now.difference(dateTime).inMinutes < 60) {
      return '${now.difference(dateTime).inMinutes} min ago';
    } else if (now.difference(dateTime).inHours < 24) {
      return '${now.difference(dateTime).inHours} hours ago';
    } else {
      return '${now.difference(dateTime).inDays} days ago';
    }
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final String actionText;
  final String imageUrl;

  NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.actionText,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedShimmerImageWidget(imageUrl: imageUrl)),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextWidget(
                      text: title,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xff6F6D6D),
                    ),
                    SizedBox(height: 0.5.h),
                    AppTextWidget(
                      text: subtitle,
                      color: const Color(0xff6F6D6D),
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  AppTextWidget(text: time, color: Colors.grey),
                  SizedBox(height: 1.h),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      actionText,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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
