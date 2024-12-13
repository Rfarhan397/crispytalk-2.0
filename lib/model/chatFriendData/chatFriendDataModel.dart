class ChatFriendData {
  final String fullName;
  final String image;
  final bool isOnline;

  ChatFriendData({
    required this.fullName,
    required this.image,
    required this.isOnline,
  });

  // Factory method to create an instance from Firestore document data
  factory ChatFriendData.fromFirestore(Map<String, dynamic>? data) {
    return ChatFriendData(
      fullName: data?['fullName'] ?? 'Unknown',
      image: (data?['images'] as List).isNotEmpty ? data!['images'][0] : '',
      isOnline: data?['isOnline'] ?? false,
    );
  }
}