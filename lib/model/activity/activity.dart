import 'package:flutter/material.dart';


class Activity {
  final String date;
  final String description;

  Activity({required this.date, required this.description});
}class ActivityForNotifications {
  final String date;
  final String description;
  final String status;
  final String action;

  ActivityForNotifications( {required this.date, required this.description,required this.status, required this.action,});
}
class NotificationItem {
  final String date;
  final String description;
  final String category;
  final Color categoryColor;

  NotificationItem({
    required this.date,
    required this.description,
    required this.category,
    required this.categoryColor,
  });
}