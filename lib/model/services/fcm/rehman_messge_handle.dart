import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isMuted = prefs.getBool('mute_notifications') ?? false;

  if (!isMuted) {
    RemoteNotification? notification = message.notification;
    if (notification != null && notification.title!.contains('Hello')) {
      await prefs.setString('last_notification_title', notification.title ?? '');
      await prefs.setString('last_notification_body', notification.body ?? '');
      log('Notification saved in SharedPreferences');
    }
  }
  await Firebase.initializeApp();

}