
import 'package:flutter/material.dart';

class TextColorProvider with ChangeNotifier{
  int _hoveredIndex = -1;
  int _activeIndex = 0;

  Color _textColor = Colors.white;

  Color get textColor => _textColor;
  int get hoveredIndex => _hoveredIndex;
  int get activeIndex => _activeIndex;

  void setHoveredIndex(int index) {
    _hoveredIndex = index;
    notifyListeners();
  }

  void setActiveIndex(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  void changeTextColor(Color newColor) {
    _textColor = newColor;
    notifyListeners();
  }
}