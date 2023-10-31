import 'package:flutter/material.dart';
import 'package:users_app/helpers/user_helper.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  @override
  void initState() {
    super.initState();
    UserHelpers.checkForLoggedInUser();
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
