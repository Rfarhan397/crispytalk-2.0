class NotificationModel {
  final String id;
  final String message;
  final String postId;
  final String recipientId;
  final String senderId;
  final String type;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.message,
    required this.postId,
    required this.recipientId,
    required this.senderId,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'postId': postId,
      'recipientId': recipientId,
      'senderId': senderId,
      'type': type,
      'timestamp': timestamp,
    };
  }

  // Create a NotificationModel object from a Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id : map['id'],
      message: map['message'] as String,
      postId: map['postId'] as String,
      recipientId: map['recipientId'] as String,
      senderId: map['senderId'] as String,
      type: map['type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
