import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MediaPostProvider with ChangeNotifier {
  Map<String, int> _postCounts = {};

  int getPostCount(String userUid) {
    return _postCounts[userUid] ?? 0;
  }

  Future<void> fetchUserPosts(String userUid) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userUid', isEqualTo: userUid)
          .get();

      _postCounts[userUid] = snapshot.docs.length;
      notifyListeners();
    } catch (e) {
      print("Error fetching user posts: $e");
    }
  }
} 