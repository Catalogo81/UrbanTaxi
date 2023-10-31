import 'dart:io';

import 'package:drivers_app/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/info_design_ui.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //name
            Text(
              driverData.name!,
              style: const TextStyle(
                fontSize: 50.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "$starRating driver",
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                height: 2,
                thickness: 2,
              ),
            ),

            const SizedBox(
              height: 38.0,
            ),

            //phone
            InfoDesignUIWidget(
              textInfo: driverData.phone!,
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: driverData.email!,
              iconData: Icons.email,
            ),

            InfoDesignUIWidget(
              textInfo:
                  "${driverData.carColor!} ${driverData.carModel!} ${driverData.carNumber!}",
              iconData: Icons.car_repair,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                exit(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
