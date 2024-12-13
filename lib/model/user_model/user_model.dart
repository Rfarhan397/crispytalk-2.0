class UserModel {
  final String id;
  final String? username;
  final String? nickname;
  final String? imageUrl;
  final String? message;
  final int? followers;
  bool isFollowing;
  bool isChecked;

  UserModel(  {
    required this.id,
    this.message,
     this.username,
     this.nickname,
     this.imageUrl,
     this.followers,
    this.isFollowing = false,
    this.isChecked = false,
  });
}
class UserModelT {
  bool isChecked;
  final String createdAt;
  final String email;
  final String name;
  final String password;
  final String userType;
  final String profileUrl;
  final String userUid;
  final String bio;
  final List<String> followers;
  final List<String> likes;
  final List<String> following;
  final String bgUrl;
  final String fcmToken;
  final bool isOnline;

  UserModelT({
    this.isChecked = false,
    required this.createdAt,
    required this.email,
    required this.name,
    required this.password,
    required this.userType,
    required this.profileUrl,
    required this.userUid,
    required this.bio,
    required this.followers,
    required this.fcmToken,
    required this.following,
    required this.likes,
    required this.bgUrl,
    required this.isOnline,
  });

  // Factory method to create a UserModel from fireStore data
  factory UserModelT.fromMap(Map<String, dynamic> data) {

    return UserModelT(
      createdAt: data['createdAt'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      password: data['password'] ?? '',
      userType: data['userType'] ?? '',
      userUid: data['userUid'] ?? '',
      profileUrl: data['profileUrl'] ?? '',
      bgUrl: data['bgUrl'] ?? '',
      bio: data['bio'] ?? 'N/A',
      fcmToken: data['fcmToken'] ?? 'N/A',
      isOnline: data['isOnline'] ?? false,
      isChecked: data['isChecked'] ?? false,
      followers: List<String>.from(data['followers'] ?? ['0']),
      likes: List<String>.from(data['likes'] ?? ['0']),
      following: List<String>.from(data['following'] ?? ['0']),


    );
  }
}
class GroupUserModel {
  final String? id;
  final String? userUid;
  final String? fcmToken;
  final String? name;
  final String? profileUrl;

  GroupUserModel(  {
     this.id,
    this.userUid,
    this.fcmToken,
    this.name,
    this.profileUrl,

  });
  factory GroupUserModel.fromMap(Map<String, dynamic> data) {

    return GroupUserModel(

      name: data['name'] ?? '',
      userUid: data['userUid'] ?? '',
      profileUrl: data['profileUrl'] ?? '',
      fcmToken: data['fcmToken'] ?? 'N/A',


    );
  }
}