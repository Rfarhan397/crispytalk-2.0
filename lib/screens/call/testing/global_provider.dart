import 'package:crispy/screens/call/testing/provider/webrtc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GlobalProviderAccess {

  static WebrtcProvider? get callProvider {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return Provider.of<WebrtcProvider>(context, listen: false);
    }
    return null;
  }


}