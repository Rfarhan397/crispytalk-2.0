import 'dart:developer';
import 'package:crispy/provider/action/action_provider.dart';
import 'package:crispy/provider/appLifeCycle/appLifeCycleProvider.dart';
import 'package:crispy/provider/bottomNavBar/bottomNavBarProvider.dart';
import 'package:crispy/provider/callProvider/audioCallProvider.dart';
import 'package:crispy/provider/callProvider/videoCallProvider.dart';
import 'package:crispy/provider/chat/chatProvider.dart';
import 'package:crispy/provider/cloudinary/cloudinary_provider.dart';
import 'package:crispy/provider/current_user/current_user_provider.dart';
import 'package:crispy/provider/mediaSelection/mediaSelectionProvider.dart';
import 'package:crispy/provider/notification/notificationProvider.dart';
import 'package:crispy/provider/otherUserData/otherUserDataProvider.dart';
import 'package:crispy/provider/passwpordVisibility/passwordVisibilityProvider.dart';
import 'package:crispy/provider/profile/profileProvider.dart';
import 'package:crispy/provider/question/questionProvider.dart';
import 'package:crispy/provider/stream/streamProvider.dart';
import 'package:crispy/provider/theme/theme_provider.dart';
import 'package:crispy/provider/user_provider/user_provider.dart';
import 'package:crispy/provider/video/videoProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';
import 'model/res/routes/routes.dart';
import 'model/res/routes/routes_name.dart';
import 'model/services/fcm/fcm_services.dart';
import 'model/services/sharedpreference/sp_service.dart';



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling background message: ${message.messageId}");
  final fcmService = FCMService();
  await SharedPreferencesService.getInstance();
  fcmService.handleMessage(message);
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmService = FCMService();
  await fcmService.initialize();

  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // Get.to(() => AudioCallScreen(
    //
    //       message: initialMessage,
    //     ));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeLanguageProvider()),
        ChangeNotifierProvider(create: (_) => PasswordVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavBarProvider()),
        ChangeNotifierProvider(create: (_) => ActionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => MediaSelectionProvider()),
        ChangeNotifierProvider(create: (_) => CloudinaryProvider()),
        ChangeNotifierProvider(create: (_) => QuestionsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OtherUSerDataProvider()),
        ChangeNotifierProvider(create: (_) => StreamDataProvider()),
        ChangeNotifierProvider(create: (_) => AppLifeCycleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider2()),
        ChangeNotifierProvider(create: (_) => AudioCallProvider()),
        ChangeNotifierProvider(create: (_) => VideoCallProvider()),
        ChangeNotifierProvider(create: (_) => CurrentUserProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Consumer<AppLifeCycleProvider>(
          builder: (context,provider,child) {
            return Sizer(
                builder: (context, orientation, deviceType) {
                  return  GetMaterialApp(
                    theme: ThemeData(
                        scaffoldBackgroundColor: Colors.white
                    ),
                    debugShowCheckedModeBanner: false,
                    title: 'Crispy Talk',
                    initialRoute: RoutesName.splashScreen,
                    getPages: Routes.routes,
                  );
                }
            );
          }
      ),
    );
  }
}

