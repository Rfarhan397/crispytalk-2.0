
import 'package:crispy/model/res/routes/routes_name.dart';
import 'package:get/get.dart';
import '../../../screens/MediaSelection/MediaSelectionScreen.dart';
import '../../../screens/MediaSelection/showMedia.dart';
import '../../../screens/MediaSelection/uploadMedia.dart';
import '../../../screens/chat/UsersChat/singleChat.dart';
import '../../../screens/chat/chatListScreen/chatListScreen.dart';
import '../../../screens/chat/createGroup/createGroup.dart';
import '../../../screens/follow/followersScreen.dart';
import '../../../screens/follow/followingScreen.dart';
import '../../../screens/login/NewPasswordScreen.dart';
import '../../../screens/login/forgetScreen.dart';
import '../../../screens/login/loginScreen.dart';
import '../../../screens/login/signUpScreen.dart';
import '../../../screens/mainScreen/homeScreen.dart';
import '../../../screens/mainScreen/mainScreen.dart';
import '../../../screens/myProfile/editProfile.dart';
import '../../../screens/myProfile/otherUserProfile/otherUserProfile.dart';
import '../../../screens/notifications/notificationScreen.dart';
import '../../../screens/setting/accounts/accountsScreen.dart';
import '../../../screens/setting/blockedUsers/blockedUsersScreen.dart';
import '../../../screens/setting/notificationSetting/notificationSettingScreen.dart';
import '../../../screens/setting/privacy/privacyScreen.dart';
import '../../../screens/setting/settingScreen.dart';
import '../../../screens/setting/termsCondition/termAndConditions.dart';
import '../../../screens/splash/splashScreen.dart';
import '../../../screens/myProfile/userProfile.dart';
import '../../../screens/video/videoScreen.dart';


class Routes {
  static final routes = [
    GetPage(name: RoutesName.splashScreen, page: () => SplashScreen()),
    GetPage(name: RoutesName.loginScreen, page: () => LoginScreen()),
    GetPage(name: RoutesName.signUp, page: () => SignUpScreen()),
    // GetPage(name: RoutesName.code, page: () => CodeScreen()),
    GetPage(name: RoutesName.forget, page: () => ForgetScreen()),
    GetPage(name: RoutesName.newPassword, page: () => NewPasswordScreen()),
    GetPage(name: RoutesName.mainScreen, page: () => MainScreen()),
    GetPage(name: RoutesName.homeScreen, page: () => HomeScreen()),
    GetPage(name: RoutesName.video, page: () => VideoScreen()),
    GetPage(name: RoutesName.userProfile, page: () => UserProfile()),
    // GetPage(name: RoutesName.otherUserProfile, page: () => OtherUserProfile()),
    GetPage(name: RoutesName.notificationScreen, page: () => NotificationScreen()),
    GetPage(name: RoutesName.settingScreen, page: () => SettingsScreen()),
    GetPage(name: RoutesName.accountScreen, page: () => AccountScreen()),
    GetPage(name: RoutesName.notificationSettingScreen, page: () => SettingNotificationScreen()),
    GetPage(name: RoutesName.privacyScreen, page: () => PrivacyScreen()),
    GetPage(name: RoutesName.termAndConditions, page: () => TermAndConditions()),
    GetPage(name: RoutesName.chatListScreen, page: () => ChatListScreen()),
    GetPage(name: RoutesName.chatScreen, page: () => ChatScreen()),
    GetPage(name: RoutesName.createGroup, page: () => CreateGroup()),
    // GetPage(name: RoutesName.editGroup, page: () => EditGroupScreen()),
    GetPage(name: RoutesName.editProfile, page: () => EditProfile()),
    GetPage(name: RoutesName.uploadContentScreen, page: () => MediaUploadScreen()),
    GetPage(name: RoutesName.followerScreen, page: () => FollowersScreen()),
    GetPage(name: RoutesName.followingScreen, page: () => FollowingScreen()),
    GetPage(name: RoutesName.uploadMedia, page: () => UploadMediaScreen(  )),
    GetPage(name: RoutesName.showMedia, page: () => ShowMedia()),
    GetPage(name: RoutesName.blockedUsers, page: () => BlockedUserScreen()),
    // GetPage(name: RoutesName.groupChat, page: () => GroupChatScreen()),

  ];
}
