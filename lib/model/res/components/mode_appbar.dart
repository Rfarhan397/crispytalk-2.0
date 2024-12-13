import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/theme/theme_provider.dart';

class ModeAppbar extends StatelessWidget {
  const ModeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeLanguageProvider>(context);
    return AppBar(
      title: Text('Flutter Theme Provider'),
      actions: [
        Switch(
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }
}
