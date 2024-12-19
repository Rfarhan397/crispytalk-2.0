import 'dart:async';

import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../model/mediaPost/mediaPost_model.dart';
import '../stream/streamProvider.dart';

class PostCacheProvider with ChangeNotifier {
  List<MediaPost>? _cachedPosts;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _postsSubscription;

  List<MediaPost>? get cachedPosts => _cachedPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
          (posts) => setCachedPosts(posts),
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  void setCachedPosts(List<MediaPost> posts) {
    _cachedPosts = posts;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> initializePosts() async {
    try {
      // Convert stream to Future to cache the first result
      final posts = await StreamDataProvider()
          .getPostsWithUserDetails(
        audience: 'Everyone',
        userStatus: 'true',
        currentUserId: currentUser,
        includeCurrentUser: false,
      )
          .first;

      _cachedPosts = posts;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCache() {
    _cachedPosts = null;
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
}