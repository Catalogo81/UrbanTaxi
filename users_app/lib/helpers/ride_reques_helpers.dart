import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users_app/helpers/popup_message_helpers.dart';
import 'package:users_app/helpers/push_notification_helpers.dart';
import 'package:users_app/main.dart';

import '../global/global.dart';
import '../screens/select_nearest_active_driver_screen.dart';

retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
  for (int i = 0; i < onlineNearestDriversList.length; i++) {
    await ref
        .child(onlineNearestDriversList[i].driverId.toString())
        .once()
        .then((dataSnapshot) {
      var driverKeyInfo = dataSnapshot.snapshot.value;
      dList.add(driverKeyInfo);
    });
  }
}

searchNearestOnlineDrivers(
    var onlineNearByAvailableDriversList,
    DatabaseReference referenceRideRequest,
    Function() showUIForAssignedDriverInfo,
    Function(Function()) setState,
    Function() setStateContent,
    void Function() showWaitingResponseFromDriverUI) async {
  //no active driver available
  if (onlineNearByAvailableDriversList.length == 0) {
    //cancel/delete the RideRequest Information
    referenceRideRequest.remove();/*removed the ! referenceRideRequest!.remove()*/

    setState((setStateContent));

    PopupMessageHelpers.showPopupDialog(
      navigationKey.currentContext!,
      "No Active Driver Available",
      "No Search Again after some time, Restarting App Now.",
    ).then((value) => navigationKey.currentState?.pop());
  }

  //active driver available
  await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

  var response = await navigationKey.currentState?.push(MaterialPageRoute(
      builder: (c) => SelectNearestActiveDriversScreen(
          referenceRideRequest: referenceRideRequest)));

  if (response == "driverChoosed") {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chosenDriverId!)
        .once()
        .then((snap) async {
      if (snap.snapshot.value != null) {
        //send notification to that specific driver
        await sendNotificationToDriverNow(
            chosenDriverId!, referenceRideRequest); /* removed the '!' referenceRideRequest! */

        //Display Waiting Response UI from a Driver
        showWaitingResponseFromDriverUI();

        //Response from a Driver
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(chosenDriverId!)
            .child("newRideStatus")
            .onValue
            .listen((eventSnapshot) {
          //1. driver has cancel the rideRequest :: Push Notification
          // (newRideStatus = idle)
          if (eventSnapshot.snapshot.value == "idle") {
            Fluttertoast.showToast(
                msg:
                    "The driver has cancelled your request. Please choose another driver.");

            Future.delayed(const Duration(milliseconds: 3000), () {
              Fluttertoast.showToast(msg: "Please Restart App Now.");

              navigationKey.currentState?.pop();
            });
          }

          //2. driver has accept the rideRequest :: Push Notification
          // (newRideStatus = accepted)
          if (eventSnapshot.snapshot.value == "accepted") {
            //design and display ui for displaying assigned driver information
            setState(
              () {
                showUIForAssignedDriverInfo();
              },
            );
          }
        });
      } else {
        Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
      }
    });
  }
}
