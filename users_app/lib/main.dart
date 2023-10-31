import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/services/push_notification_service.dart';
import 'package:users_app/view_models/app_data_view_model.dart';
import 'package:users_app/route_manager.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppDataViewModel()),
        ChangeNotifierProvider(create: (context) => PushNotificationService()),
      ],
      child: MaterialApp(
        navigatorKey: navigationKey,
        title: 'Drivers App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: RouteManager.splashScreen,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}
