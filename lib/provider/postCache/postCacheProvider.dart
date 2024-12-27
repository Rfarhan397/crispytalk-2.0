import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../stream/streamProvider.dart';

class PostCacheProvider with ChangeNotifier {
  List<MediaPost>? _cachedPosts;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _postsSubscription;
  bool _isInitialized = false;

  List<MediaPost>? get cachedPosts => _cachedPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> initializePosts() async {
    if (_isInitialized && _cachedPosts != null) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      // Get initial data
      final posts = await StreamDataProvider()
          .getPostsWithUserDetails(
            audience: 'Everyone',
            userStatus: 'true',
            currentUserId: currentUser,
            includeCurrentUser: false,
          )
          .first;

      _cachedPosts = List<MediaPost>.from(posts);
      _isLoading = false;
      _error = null;
      _isInitialized = true;
      
      // Start listening to updates
      initializePostsStream();
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void initializePostsStream() {
    _postsSubscription?.cancel();

    _postsSubscription = StreamDataProvider()
        .getPostsWithUserDetails(
          audience: 'Everyone',
          userStatus: 'true',
          currentUserId: currentUser,
          includeCurrentUser: false,
        )
        .listen(
          (posts) {
            if (!listEquals(_cachedPosts, posts)) {
              _cachedPosts = List<MediaPost>.from(posts);
              _isLoading = false;
              _error = null;
              notifyListeners();
            }
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  void setCachedPosts(List<MediaPost> posts) {
    if (!listEquals(_cachedPosts, posts)) {
      _cachedPosts = List<MediaPost>.from(posts);
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  void clearCache() {
    _cachedPosts = null;
    _isLoading = true;
    _error = null;
    _isInitialized = false;
    _postsSubscription?.cancel();
    notifyListeners();
  }
}