import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/action/action_provider.dart';

class ToastWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final toastProvider = Provider.of<ActionProvider>(context);

    if (!toastProvider.isVisible) {
      return SizedBox.shrink();
    }

    return Positioned(
      top: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            toastProvider.message ?? '',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
