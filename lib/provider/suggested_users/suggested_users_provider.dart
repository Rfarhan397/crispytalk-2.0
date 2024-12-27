import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SuggestedUsersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _suggestedUsers = [];
  bool _isLoading = true;
  String? _error;

  List<DocumentSnapshot> get suggestedUsers => _suggestedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuggestedUsers(String currentUserId) async {

    try {
      _isLoading = true;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        _suggestedUsers = [];
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final blockedUserIds = List<String>.from(userData['blocks'] ?? []);
      final followingIds = List<String>.from(userData['following'] ?? []);

      final excludeIds = {...blockedUserIds, ...followingIds, currentUserId};
      final allUsers = await _firestore.collection('users').get();
      
      _suggestedUsers = allUsers.docs
          .where((doc) => !excludeIds.contains(doc.get('userUid') as String))
          .take(10)
          .toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void removeUserFromSuggestions(String userId) {
    suggestedUsers.removeWhere((user) =>
    (user.data() as Map<String, dynamic>)['userUid'] == userId);
    notifyListeners();
  }
} 