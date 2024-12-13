import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/theme/theme_provider.dart';
import '../constant/app_colors.dart';

class CustomSwitchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeLanguageProvider>(context);

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 60,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: themeProvider.isDarkMode ? Colors.grey : Colors.black,
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: themeProvider.isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
class CustomSwitchWidgetF extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeLanguageProvider>(context);

    return GestureDetector(
      onTap: () {

        print('object');
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        width: 45,
        height: 24,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: Offset(1, 3),
              blurRadius: 2.0,
            )
          ],
          borderRadius: BorderRadius.circular(15),
          color: themeProvider.isDarkMode ? AppColors.appPurpleColor : AppColors.appPurpleColor,
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: themeProvider.isDarkMode ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 24,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeProvider.isDarkMode ? Colors.white : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
