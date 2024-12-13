import '../user_model/user_model.dart';

class MediaPost {
  final String audience;
  final bool isLiked;
  final bool isSaved;
  final List<String> likes;
  final List<String> saves;
  final String mediaType;
  final String mediaUrl;
  final String timeStamp;
  final String title;
  final String userUid;
  UserModelT? userDetails;


  MediaPost({
    required this.audience,
    required this.isLiked,
    required this.isSaved,
    required this.likes,
    required this.saves,
    required this.mediaType,
    required this.mediaUrl,
    required this.timeStamp,
    required this.title,
    required this.userUid,
     this.userDetails,
  });

  // Factory constructor to create an instance from a Firestore document
  factory MediaPost.fromMap(Map<String, dynamic> data) {
    return MediaPost(
      audience: data['audience'] ?? 'Everyone',
      isLiked: data['isLiked'] ?? false,
      isSaved: data['isSaved'] ?? false,
      likes: List<String>.from(data['likes']?? []),
      saves: List<String>.from(data['saves']?? []),
      // likes: data['likes'] ?? [],
      mediaType: data['mediaType'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      timeStamp: data['timeStamp'] ?? '',
      title: data['title'] ?? '',
      userUid: data['userUid'] ?? '',

    );
  }
}

class CommentModel {
  String commentId;
  String userId;
  String content;
  String timestamp;

  CommentModel({
    required this.commentId,
    required this.userId,
    required this.content,
    required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'userId': userId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> data) {
    return CommentModel(
      commentId: data['commentId'],
      userId: data['userId'],
      content: data['content'],
      timestamp: data['timestamp'] ,
    );
  }
}
class CommentWithUser {
  final CommentModel comment;
  final UserModelT user;

  CommentWithUser({required this.comment, required this.user});
}
