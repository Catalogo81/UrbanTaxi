import 'package:flutter/material.dart';
import 'package:users_app/screens/login_screen.dart';
import 'package:users_app/screens/signup_screen.dart';
import 'package:users_app/screens/profile_screen.dart';
import 'package:users_app/screens/search_places_screen.dart';
import 'package:users_app/screens/select_nearest_active_driver_screen.dart';
import 'package:users_app/screens/trips_history_screen.dart';
import 'package:users_app/splashScreen/splash_screen.dart';

import 'screens/main_screen.dart';
import 'screens/rate_driver_screen.dart';

class RouteManager {
  static const splashScreen = "/";

  static const loginScreen = "/loginScreen";
  static const signUpScreen = "/signUpScreen";
  static const mainScreen = "/mainScreen";
  static const profileScreen = "/profileScreen";
  static const rateDriverScreen = "/rateDriverScreen";
  static const searchPlacesScreen = "SearchPlacesScreen";
  static const selectNearestActiveDriversScreen =
      "selectNearestActiveDriversScreen";
  static const tripsHistoryScreen = "/tripsHistoryScreen";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (context) => const MySplashScreen());
      case loginScreen:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case signUpScreen:
        return MaterialPageRoute(builder: (context) => SignUpScreen());
      case mainScreen:
        return MaterialPageRoute(builder: (context) => MainScreen());
      case profileScreen:
        return MaterialPageRoute(builder: (context) => ProfileScreen());

      case rateDriverScreen:
        return MaterialPageRoute(builder: (context) => RateDriverScreen());
      case searchPlacesScreen:
        return MaterialPageRoute(builder: (context) => SearchPlacesScreen());
      case selectNearestActiveDriversScreen:
        return MaterialPageRoute(
            builder: (context) => SelectNearestActiveDriversScreen());
      case tripsHistoryScreen:
        return MaterialPageRoute(builder: (context) => TripsHistoryScreen());

      default:
        throw Exception("Invalid route: ${settings.name}");
    }
  }
}
