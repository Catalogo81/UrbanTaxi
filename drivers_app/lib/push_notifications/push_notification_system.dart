import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/push_notifications/notification_dialog_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initFCM(BuildContext context) async {
    await FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        getUserRideRequest(remoteMessage.data["rideRequestId"], context);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      getUserRideRequest(remoteMessage!.data["rideRequestId"], context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      getUserRideRequest(remoteMessage!.data["rideRequestId"], context);
    });
  }

  getUserRideRequest(String userRideRequestId, BuildContext context) async {
    await FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(userRideRequestId)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        UserRideRequestInformation userRideRequestDetails =
            UserRideRequestInformation(
          originLatLng: LatLng(
              double.parse(
                  (snapData.snapshot.value! as Map)["origin"]["latitude"]),
              double.parse(
                  (snapData.snapshot.value! as Map)["origin"]["longitude"])),
          destinationLatLng: LatLng(
              double.parse(
                  (snapData.snapshot.value! as Map)["destination"]["latitude"]),
              double.parse((snapData.snapshot.value! as Map)["destination"]
                  ["longitude"])),
          originAddress: (snapData.snapshot.value! as Map)["originAddress"],
          destinationAddress:
              (snapData.snapshot.value! as Map)["destinationAddress"],
          rideRequestId: snapData.snapshot.key!,
          userName: (snapData.snapshot.value! as Map)["userName"],
          userPhone: (snapData.snapshot.value! as Map)["userPhone"],
        );

        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => const AlertDialog.adaptive(
                  content: Text("Ride not found."),
                ));
      }
    });
  }

  Future<void> generateAndUploadToken() async {
    String? registrationToken = await messaging.getToken();
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("token")
        .set(registrationToken);
    FirebaseMessaging.instance.subscribeToTopic("allDrivers");
    FirebaseMessaging.instance.subscribeToTopic("allUsers");
  }
}
