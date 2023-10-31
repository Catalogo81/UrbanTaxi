import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/helpers/assistant_methods.dart';

Future<void> sendNotificationToDriverNow(
    String driverID, DatabaseReference rideRef) async {
  //assign/SET rideRequestId to newRideStatus in
  // Drivers Parent node for that specific choosen driver
  FirebaseDatabase.instance
      .ref()
      .child("drivers")
      .child(driverID)
      .child("newRideStatus")
      .set(rideRef.key);

  //automate the push notification service
  FirebaseDatabase.instance
      .ref()
      .child("drivers")
      .child(driverID)
      .child("token")
      .once()
      .then((snap) async {
    if (snap.snapshot.value != null) {
      String deviceRegistrationToken = snap.snapshot.value.toString();

      //send Notification Now
      await HelperMethods.sendNotificationToDriverNow(
        deviceRegistrationToken,
        rideRef.key.toString(),
        driverID as BuildContext, //added
      );

      Fluttertoast.showToast(msg: "Notification sent Successfully.");
    } else {
      Fluttertoast.showToast(msg: "Please choose another driver.");
      return;
    }
  });
}
