import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessage = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessage.requestPermission();
    final fcmToken = await _firebaseMessage.getToken();
    log("Token is: $fcmToken");
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    log("Title: ${message.notification?.title}");
    log("body: ${message.notification?.body}");
    log("payLoad: ${message.data}");
  }
}