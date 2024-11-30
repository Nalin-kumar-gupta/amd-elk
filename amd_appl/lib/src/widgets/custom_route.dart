import 'package:flutter/material.dart';

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required WidgetBuilder builder, required RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // If navigating to "SplashPage", skip animations
    if (settings.name == "SplashPage") {
      return child;
    }
    // Apply fade transition for other routes
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
