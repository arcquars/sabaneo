import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sabaneo_2/providers/user_provider.dart';

class SessionObserver extends NavigatorObserver {
  final GlobalKey<NavigatorState> navigatorKey;

  SessionObserver(this.navigatorKey);

  @override
  void didPush(Route route, Route? previousRoute) {
    _checkSession();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _checkSession();
    super.didPop(route, previousRoute);
  }

  void _checkSession() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.loadUserSession().then((res) {
      if (!userProvider.isLoggedIn) {
        debugPrint("_checkSession::: ${userProvider.isLoggedIn}");
        navigatorKey.currentState?.pushReplacementNamed('/login');
      }
    });

  }
}
