import 'package:intl/intl.dart';

import '../user_model/user_model.dart';

class ChatRoomModel {
  final String docId;
  final List<String> users;
  final String lastMessage;
  final String createdAt;
  int unreadMessageCount;

  ChatRoomModel({
    required this.docId,
    required this.users,
    required this.lastMessage,
    required this.createdAt,
    this.unreadMessageCount = 0,
  });



  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'lastMessage': lastMessage,
      'createdAt': createdAt,
      'unreadMessageCount': unreadMessageCount,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> data, String docId) {
    String createdAt = data['createdAt'] ?? '';

    // Parse the string into a DateTime object
    DateTime dateTime = DateTime.parse(createdAt);

    // Format the DateTime object
    createdAt = formatTimestamp(dateTime);

    return ChatRoomModel(
      docId: docId,
      users: List<String>.from(data['users']),
      lastMessage: data['lastMessage'] ?? '',
      createdAt: createdAt,
      unreadMessageCount: 0,
    );
  }



  static String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    if (dateTime.isAfter(today) && dateTime.isBefore(tomorrow)) {
      return DateFormat.jm().format(dateTime);
    } else if (dateTime.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('d MMM, h:mm a').format(dateTime).toLowerCase();
    }
  }
}
class ChatWithUser {
  final ChatRoomModel chatRoomModel;
  final UserModelT user;

  ChatWithUser({required this.chatRoomModel, required this.user});
}

class Group {
  final String admin;
  final String createdAt;
  final String groupId;
  final String groupImage;
  final String groupName;
  final String lastMessage;
  final List<String> members; // List of member UIDs

  Group({
    required this.admin,
    required this.createdAt,
    required this.groupId,
    required this.groupImage,
    required this.groupName,
    required this.lastMessage,
    required this.members,
  });

  // Factory method to create a Group object from Firestore data
  factory Group.fromFirestore(Map<String, dynamic> firestoreData) {
    return Group(
      admin: firestoreData['admin'] ?? '',
      createdAt: firestoreData['createdAt'] ?? '',
      groupId: firestoreData['groupId'] ?? '',
      groupImage: firestoreData['groupImage'] ?? '',
      groupName: firestoreData['groupName'] ?? '',
      lastMessage: firestoreData['lastMessage'] ?? '',
      members: List<String>.from(firestoreData['members'] ?? []), // Safely converting members field
    );
  }

  // Method to convert Group object to a Map
  Map<String, dynamic> toMap() {
    return {
      'admin': admin,
      'createdAt': createdAt,
      'groupId': groupId,
      'groupImage': groupImage,
      'groupName': groupName,
      'lastMessage': lastMessage,
      'members': members, // Storing the members list
    };
  }
}