import 'package:flutter/material.dart';
import 'package:AMD/src/pages/splash_screen.dart';
import 'package:AMD/src/pages/home_page.dart';
// import 'package:healthaxis_mob/src/widgets/custom_route.dart';
// Uncomment or ensure the following imports exist
// import 'package:healthaxis_mob/src/pages/detail_page.dart';
// import 'package:healthaxis_mob/src/pages/doctor_consultant_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getRoute() {
    return <String, WidgetBuilder>{
      '/': (_) => SplashScreen(),
      '/HomePage': (_) => HomePage(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Validate route name
    if (settings.name == null) {
      return _errorRoute();
    }

    final List<String> pathElements = settings.name!.split('/');
    if (pathElements.isEmpty || pathElements[0] != '' || pathElements.length < 2) {
      return _errorRoute();
    }

    switch (pathElements[1]) {
      // case "DetailPage":
      //   return CustomRoute<bool>(
      //     builder: (BuildContext context) => DetailPage(
      //       doctor: settings.arguments,
      //     ),
      //     settings: settings,
      //   );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Page not found")),
      ),
    );
  }
}
