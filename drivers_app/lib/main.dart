import 'package:drivers_app/firebase_options.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppDataProvider(),
      child: MaterialApp(
        title: 'Drivers App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MySplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
