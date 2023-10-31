import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/helpers/popup_message_helpers.dart';
import 'package:users_app/main.dart';
import 'package:users_app/route_manager.dart';

import '../models/user_model.dart';
import '../widgets/progress_dialog.dart';

class UserHelpers {
  static Future<void> saveUserInfo(BuildContext context, String email,
      String password, String name, String phoneNumber) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Processing, Please wait...",
          );
        });

    (await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((userCredential) async {
      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        Map<String, String> userMap = {
          "id": firebaseUser.uid,
          "name": name,
          "email": email,
          "phone": phoneNumber,
        };

        DatabaseReference reference =
            FirebaseDatabase.instance.ref().child("users");
        await reference.child(firebaseUser.uid).set(userMap).then(
          (value) {
            currentFirebaseUser = firebaseUser;
            Fluttertoast.showToast(msg: "Account has been Created.");
          },
        );

        navigationKey.currentState?.pushNamed(RouteManager.splashScreen);
      } else {
        navigationKey.currentState?.pop();
        Fluttertoast.showToast(msg: "Account has not been Created.");
      }
    }).catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: $msg");
    }));
  }

  static Future<void> checkForLoggedInUser() async {
    if (FirebaseAuth.instance.currentUser != null) {
      currentFirebaseUser = FirebaseAuth.instance.currentUser;
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(FirebaseAuth.instance.currentUser!.uid);

      await userRef
          .once()
          .timeout(const Duration(seconds: 30))
          .then((snap) async {
            if (snap.snapshot.value != null) {
              print(snap.snapshot.value);
              userModelCurrentInfo = AppUser.fromSnapshot(snap.snapshot);
            }
          })
          .then((value) =>
              navigationKey.currentState?.pushNamed(RouteManager.mainScreen))
          .catchError(
            (error, stackTrace) {
              navigationKey.currentState?.pushNamed(RouteManager.loginScreen);
              PopupMessageHelpers.showPopupDialog(
                navigationKey.currentState?.context ??
                    navigationKey.currentContext!,
                "Request failed",
                error.toString(),
              );
              return null;
            },
            test: (error) => error == TimeoutException,
          )
          .catchError((error, stackTrace) {
            navigationKey.currentState?.pushNamed(RouteManager.loginScreen);

            FirebaseAuth.instance.signOut();
            currentFirebaseUser = null;
            PopupMessageHelpers.showPopupDialog(
                navigationKey.currentState?.context ??
                    navigationKey.currentContext!,
                "User not found",
                "User details not found");
            return null;
          });
    } else {
      Future.delayed(
          const Duration(seconds: 3),
          () =>
              navigationKey.currentState?.pushNamed(RouteManager.loginScreen));
    }
  }

  static Future<void> loginUser(String email, String password) async {
    showDialog(
        context: navigationKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(
            message: "Processing, Please wait...",
          );
        });

    //Move this to view model
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((userCredential) {
      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        DatabaseReference driversRef =
            FirebaseDatabase.instance.ref().child("users");
        driversRef.child(firebaseUser.uid).once().then(
          (driverKey) {
            final snap = driverKey.snapshot;
            if (snap.value != null) {
              currentFirebaseUser = firebaseUser;
              Fluttertoast.showToast(msg: "Login Successful.");
              navigationKey.currentState?.pushNamed(RouteManager.splashScreen);
            } else {
              FirebaseAuth.instance.signOut();
              PopupMessageHelpers.showPopupDialog(
                  navigationKey.currentContext!,
                  "User not found",
                  "No user found with this email. Please register for an account");

              navigationKey.currentState?.pushNamed(RouteManager.splashScreen);
            }
          },
        );
      } else {
        navigationKey.currentState?.pop();
        Fluttertoast.showToast(msg: "Error Occurred during Login.");
      }
    }).catchError((msg) {
      navigationKey.currentState?.pop();
      PopupMessageHelpers.showPopupDialog(
          navigationKey.currentContext!, "Error", msg.toString());
    });
  }
}
