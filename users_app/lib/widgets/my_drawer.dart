import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_app/main.dart';
import 'package:users_app/route_manager.dart';
//import 'package:users_app/screens/about_screen.dart';
import 'package:users_app/screens/trips_history_screen.dart';

class MyDrawer extends StatefulWidget {
  final String name;
  final String email;

  const MyDrawer({super.key, required this.name, required this.email});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        children: [
          Container(
            height: 165,
            color: Colors.grey,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.email.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 12.0,
          ),

          //drawer body
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
            },
            child: const ListTile(
              leading: Icon(
                Icons.history,
                color: Colors.white54,
              ),
              title: Text(
                "History",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              navigationKey.currentState
                  ?.popAndPushNamed(RouteManager.profileScreen);
            },
            child: const ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.white54,
              ),
              title: Text(
                "Profile",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              navigationKey.currentState
                  ?.popAndPushNamed(RouteManager.splashScreen);
            },
            child: const ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white54,
              ),
              title: Text(
                "Sign Out",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
