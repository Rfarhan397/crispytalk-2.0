import 'package:flutter/material.dart';
import '../../model/user_model/user_model.dart';
import '../../provider/stream/streamProvider.dart';

class CurrentUserProvider extends ChangeNotifier {
  UserModelT? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModelT? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCurrentUserDetails() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final StreamDataProvider streamProvider = StreamDataProvider();
      _currentUser = await streamProvider.getCurrentUser();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void updateCurrentUser(UserModelT user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }
}