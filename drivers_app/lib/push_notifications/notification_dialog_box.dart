import 'package:drivers_app/helpers/helper_methods.dart';

import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({super.key, this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14,
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              "New Ride Request",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.grey),
            ),

            const SizedBox(height: 14.0),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //addresses origin destination
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails!.originAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20.0),

                  //destination location with icon
                  Row(
                    children: [
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails!.destinationAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 3,
              thickness: 3,
            ),

            //buttons cancel accept
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      //cancel the rideRequest
                      FirebaseDatabase.instance
                          .ref()
                          .child("All Ride Requests")
                          .child(widget.userRideRequestDetails!.rideRequestId)
                          .remove()
                          .then((value) {
                        FirebaseDatabase.instance
                            .ref()
                            .child("drivers")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .child("newRideStatus")
                            .set("idle");
                      }).then((value) {
                        FirebaseDatabase.instance
                            .ref()
                            .child("drivers")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .child("tripsHistory")
                            .child(widget.userRideRequestDetails!.rideRequestId)
                            .remove();
                      }).then((value) {
                        Fluttertoast.showToast(
                            msg:
                                "Ride Request has been Cancelled, Successfully. Restart App Now.");
                      });

                      Future.delayed(const Duration(milliseconds: 3000), () {
                        SystemNavigator.pop();
                      });
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      acceptRideRequest(context);
                    },
                    child: const Text(
                      "ACCEPT",
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = "";
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then(
      (snap) {
        if (snap.snapshot.value != null) {
          getRideRequestId = snap.snapshot.value.toString();
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog.adaptive(
              content: Text("This ride request do not exists."),
            ),
          );
        }

        if (getRideRequestId == widget.userRideRequestDetails!.rideRequestId) {
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child("newRideStatus")
              .set("accepted");

          HelperMethods.pauseLiveLocationUpdates();

          //trip started now - send driver to new tripScreen
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => NewTripScreen(
                        userRideRequestDetails: widget.userRideRequestDetails,
                      )));
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog.adaptive(
              content: Text("Ride Request Not Found"),
            ),
          );
        }
      },
    );
  }
}
