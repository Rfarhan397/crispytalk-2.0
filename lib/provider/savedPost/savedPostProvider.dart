import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../../model/user_model/user_model.dart';

class SavedPostsProvider extends ChangeNotifier {
  List<MediaPost> _savedPosts = [];
  bool _isLoading = false;
  String? _error;

  List<MediaPost> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSavedPosts(String userUid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('saves', arrayContains: userUid)
          .get();
      // Fetch saved posts and user details
      List<MediaPost> postsWithDetails = [];
      for (var doc in querySnapshot.docs) {
        final post = MediaPost.fromMap(doc.data());

        // Fetch user details for the post
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(post.userUid)
            .get();
        if (userDoc.exists) {
          final userDetails = UserModelT.fromMap(userDoc.data()!);
          post.userDetails = userDetails;
        }
        postsWithDetails.add(post);
      }
      _savedPosts = postsWithDetails;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> refreshSavedPosts(String userUid) async {
    _savedPosts = [];
    await fetchSavedPosts(userUid);
  }
}
