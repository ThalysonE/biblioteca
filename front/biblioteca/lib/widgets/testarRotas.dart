import 'package:flutter/material.dart';

class MyRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> routeStack = [];

  @override
  void didPush(Route route, Route? previousRoute) {
    routeStack.add(route);
    _printStack();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    routeStack.remove(route);
    _printStack();
  }

  void _printStack() {
    print('--- Rota Atual ---');
    for (var r in routeStack) {
      print(r.settings.name ?? r.runtimeType.toString());
    }
  }
}
