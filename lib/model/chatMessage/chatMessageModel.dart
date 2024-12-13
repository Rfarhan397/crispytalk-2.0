import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageModel {
  final String message;
  final String createdAt;
  final String type;
  final String senderId;
  final String? id;

  MessageModel({
    required this.message,
    required this.createdAt,
    required this.type,
    required this.senderId,
     this.id,
  });

  // factory MessageModel.fromMap(Map<String, dynamic> data) {
  //   String createdAtString = data['createdAt'] ?? '';
  //
  //   // Parse the string into a DateTime object, if possible
  //   DateTime? dateTime;
  //   try {
  //     dateTime = DateTime.parse(createdAtString);
  //   } catch (e) {
  //     dateTime = null; // Handle parsing errors
  //   }
  //
  //   // Format the DateTime object if it's valid, else keep it as an empty string
  //   String formattedCreatedAt =
  //   dateTime != null ? formatTimestamp(dateTime) : '';
  //
  //   return MessageModel(
  //     message: data['message'] ?? '',
  //     createdAt: formattedCreatedAt,
  //     type: data['type'] ?? '',
  //     senderId: data['senderId'] ?? '',
  //     id: data['id'] ?? '',
  //   );
  // }
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String createdAtString = data['createdAt'] ?? '';

    // Parse the string into a DateTime object, if possible
    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(createdAtString);
    } catch (e) {
      dateTime = null; // Handle parsing errors
    }

    // Format the DateTime object if it's valid, else keep it as an empty string
    String formattedCreatedAt =
    dateTime != null ? formatTimestamp(dateTime) : '';
    return MessageModel(
      id: doc.id,
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      senderId: data['senderId'] ?? '',
      createdAt: formattedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'createdAt': createdAt,
      'type': type,
      'senderId': senderId,
    };
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
