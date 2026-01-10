import 'package:flutter/material.dart';
import 'package:product_mobile_app/screens/splash_screen.dart';
import 'package:product_mobile_app/screens/home_screen.dart';

class AppRoutes {
    static const String splash = '/splash';
    static const String home = '/home';

    static Route<dynamic> generateRoute(RouteSettings settings) {
        switch (settings.name) {
          case splash:
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case home:
            return MaterialPageRoute(builder: (_) => HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('No route defined for ${settings.name}')),
              ),
            );
        }
    }
}