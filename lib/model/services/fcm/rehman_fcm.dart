import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant.dart';
import '../../../screens/call/audioCall/audio.dart';
import '../../../screens/call/videoCall/video.dart';

class FCMServiceR {
  List<Color> getPredefinedColors() {
    return [
      Colors.blue,
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.brown,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
      Colors.pink,
      Colors.deepPurple,
      Colors.lightGreen,
      Colors.lightBlue,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
      Colors.cyanAccent,
      Colors.indigoAccent,
      Colors.pinkAccent,
      Colors.deepOrangeAccent,
      Colors.deepPurpleAccent,
      Colors.lightGreenAccent,
      Colors.lightBlueAccent,
    ];
  }

  static final FCMServiceR _instance = FCMServiceR._internal();
  factory FCMServiceR() => _instance;
  FCMServiceR._internal();

  late final FirebaseMessaging _firebaseMessaging;
  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const DarwinNotificationDetails _iOSNotificationDetails =
  DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // Key for storing mute status in SharedPreferences
  static const String _muteNotificationsKey = "mute_notifications";

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await setupFlutterNotifications();
    await requestNotificationPermissions();
    configureFirebaseListeners();
  }

  // Set the mute status
  Future<void> setMuteStatus(bool isMuted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_muteNotificationsKey, isMuted);
  }

  // Get the mute status
  Future<bool> getMuteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_muteNotificationsKey) ?? false;
  }

  // Function to toggle mute status (optional)
  Future<void> toggleMuteStatus() async {
    bool currentStatus = await getMuteStatus();
    await setMuteStatus(!currentStatus);
  }

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToChatScreen({
    required String receiverImage,
    required String senderImage,
    required String token,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String comingFrom,
    required String userType,
    required String status,
  }) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
    //     builder: (context) => MyAppointmentScreen(),
    //   ));
    // });
  }

  static void navigateToDoctorAppointmentScreen() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
    //     builder: (context) => MyAppointmentScreen(),
    //   ));
    // });
  }

  static void navigateToTalkToSpecialistScreen() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   navigatorKey.currentState?.pushReplacement(MaterialPageRoute(
    //     builder: (context) => MyAppointmentScreen(),
    //   ));
    // });
  }

  Future<void> setupFlutterNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // android: AndroidInitializationSettings('launch_background'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveBackgroundNotificationResponse:
      _backgroundNotificationResponse,
      onDidReceiveNotificationResponse: _foregroundNotificationResponse,
    );
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((message) async{
      bool isMuted = await getMuteStatus();
      print("Notification :: $isMuted");
      if (!isMuted) {
        showNotification(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }

  void handleMessage(RemoteMessage message) async {
    final additionalData = message.data;
    if (additionalData.isNotEmpty) {
      if (additionalData['isVideo'] == 'true') {
        Get.to(
              () => VideoCallScreen(
            callId: additionalData['callID'],
            isCaller: false,
            callerImage: additionalData['image'],
            callerName: additionalData['name'],
          ),
        );
      } else if (additionalData['isVideo'] == 'false') {
        Get.to(
              () => AudioCallScreen(
            callId: additionalData['callID'],
            isCaller: false,
            callerImage: additionalData['image'],
            callerName: additionalData['name'],
          ),
        );
      }
    }




  }

  void showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: _iOSNotificationDetails,
          ),
          payload: jsonEncode(message.data)
      );

      // Check if the dialog should be shown
      if (notification.title!.contains('Hello')) {
        // Ensure the context is valid
        final BuildContext? dialogContext =
            navigatorKey.currentState?.overlay?.context;
        if (dialogContext != null) {
          showDialog(
            context: dialogContext,
            builder: (BuildContext context) {
              List<Color> predefinedColors = getPredefinedColors();
              Color randomColor =
              predefinedColors[Random().nextInt(predefinedColors.length)];
              return AlertDialog(
                backgroundColor: randomColor,
                title: Text(
                  notification.title ?? 'Notification',
                  style: const TextStyle(
                      color: Colors.white
                  ),
                ),
                content: Text(
                  notification.body ?? 'You have a new notification.',
                  style: const TextStyle(
                      color: Colors.white),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Close',
                      style: TextStyle(
                          color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          if (kDebugMode) {
            print('Dialog context is null');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('Received notification is null');
      }
    }
  }

  Future<String> _getAccessToken() async {
    final String jsonString =
    // await rootBundle.loadString('android/app/push_messaing.json');
    await rootBundle.loadString('android/app/messaging_services.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final serviceAccount = ServiceAccountCredentials.fromJson(jsonData);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(serviceAccount, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  Future<void> sendNotification(
      String token, String title, String body, String senderId,
      {Map<String, dynamic>? additionalData}) async {
    final accessToken = await _getAccessToken();
    final projectId = await _getProjectId();

    // Add any screen-specific data you need here
    // Map<String, dynamic> data = {
    //   'screen': 'ChatScreen',  // Name of the screen to navigate to
    //   'receiverImage': 'receiverImage_url',
    //   'senderImage': 'senderImage_url',
    //   'token': token,
    //   'senderId': senderId,
    //   'senderName': 'Sender Name',
    //   'receiverId': 'Receiver Id',
    //   'receiverName': 'Receiver Name',
    //   'comingFrom': 'appointment',
    //   'userType': 'patient', // or 'doctor', depending on context
    //   'status': 'active', // for example
    // };

    Map<String, dynamic> data = {
      'screen': 'Appointment',
      'token': token,
      'senderId': senderId,
    };

    // Merge with any additional data passed
    if (additionalData != null) {
      data.addAll(additionalData);
    }


    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': additionalData,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      debugPrint("Notification Send");
      // saveNotificationInFirebase(
      //     title: title, subTitle: body, senderId: senderId);
    } else {}
  }

  Future<String> _getProjectId() async {
    final String jsonString =
    await rootBundle.loadString('android/app/messaging_services.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData['project_id'];
  }

  @pragma('vm:entry-point')
  static void _backgroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FCMServiceR().handleMessage(message);
      });
    }
  }

  void _foregroundNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final message = RemoteMessage.fromMap(jsonDecode(response.payload!));
      handleMessage(message);
    }
  }

  Future<void> saveNotificationInFirebase(
      {required String title,
        required String subTitle,
        required String type,
        String? uid
      }) async{
    // Format the current date as dd-MM-yyyy

    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid ?? auth.currentUser?.uid)
        .collection("notifications")
        .doc(id).set({
      'title': title,
      'subtitle': subTitle,
      "read" : false,
      "type" : type,
      'date': id.toString(),
    });
  }

  Future<String?> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Device Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting device token: $e");
      return null;
    }
  }

}