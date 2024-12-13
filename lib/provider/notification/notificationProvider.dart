import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  int _selectedIndex = 0; // 0 for "Today", 1 for "Last Week"

  int get selectedIndex => _selectedIndex;

  void updateIndex(int newIndex) {
    _selectedIndex = newIndex;
    notifyListeners(); // Notify UI to rebuild
  }





  ///////toggle Button////////
  bool _isSwitched = false;

  bool get isSwitched => _isSwitched;

  void toggleSwitch() {
    _isSwitched = !_isSwitched;
    notifyListeners();
  }
}
