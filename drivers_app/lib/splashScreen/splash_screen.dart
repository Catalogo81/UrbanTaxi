import 'dart:async';

import 'package:drivers_app/authentication/login_screen.dart';
import 'package:drivers_app/mainScreens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Urban\nTaxi",
                  style: TextStyle(color: Colors.white, fontSize: 72),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CircularProgressIndicator()
            ],
          ),
        ),
      ),
    );
  }
}
