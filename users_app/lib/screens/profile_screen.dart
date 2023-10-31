import 'package:flutter/material.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/widgets/info_design_ui.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
              userModelCurrentInfo?.name ?? "User",
              style: const TextStyle(
                fontSize: 50.0,
                color: Colors.white,
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
              textInfo: userModelCurrentInfo?.phone ?? "(000) - 000 - 0000",
              iconData: Icons.phone_iphone,
            ),

            //email
            InfoDesignUIWidget(
              textInfo: userModelCurrentInfo?.email ?? "notfound@example.com",
              iconData: Icons.email,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white54,
              ),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
