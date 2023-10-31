import 'package:drivers_app/helpers/request_assistant.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/global/map_key.dart';
import 'package:drivers_app/providers/app_info.dart';
import 'package:drivers_app/models/direction_details_info.dart';
import 'package:drivers_app/models/directions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/trips_history_model.dart';

class HelperMethods {
  static Future<String> getAddressCoordinates(
      Position position, BuildContext context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/"
        "json?latlng=${position.latitude},${position.longitude}"
        "&key=$mapKey";

    var requestResponse = await RequestHelpers.processRequest(apiUrl);

    if (requestResponse !=
        "Unexpected Error Occurred. Please Try Again Later") {
      Directions userPickUpAddress = Directions(
          humanReadableAddress: requestResponse["results"][0]
              ["formatted_address"],
          locationLatitude: position.latitude,
          locationLongitude: position.longitude);

      // ignore: use_build_context_synchronously
      context
          .read<AppDataProvider>()
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return requestResponse["results"][0]["formatted_address"];
  }

  static Future<DirectionDetails?> obtainOriginToDestinationDirectionDetails(
      LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var data = await RequestHelpers.processRequest(
        urlOriginToDestinationDirectionDetails);

    if (data == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetails directionDetailsInfo = DirectionDetails(
        distanceText: data["routes"][0]["legs"][0]["duration"]["value"],
        duration: data["routes"][0]["legs"][0]["duration"]["text"],
        ePoints: data["routes"][0]["overview_polyline"]["points"],
        distance: data["routes"][0]["legs"][0]["distance"]["value"],
        durationText: data["routes"][0]["legs"][0]["distance"]["text"]);

    return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates() {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);
  }

  static resumeLiveLocationUpdates() {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetails directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    if (driverVehicleType == "bike") {
      double resultFareAmount = (totalFareAmount.truncate()) / 2.0;
      return resultFareAmount;
    } else if (driverVehicleType == "goCar") {
      return totalFareAmount.truncate().toDouble();
    } else if (driverVehicleType == "normalCar") {
      double resultFareAmount = (totalFareAmount.truncate()) * 2.0;
      return resultFareAmount;
    } else {
      return totalFareAmount.truncate().toDouble();
    }
  }

  //retrieve the trips KEYS for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineDriver(context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        context
            .read<AppDataProvider>()
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        context.read<AppDataProvider>().updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys = context.read<AppDataProvider>().historyTripKeys;

    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = Trip.fromSnapshot(snap.snapshot);

        if ((snap.snapshot.value as Map)["status"] == "ended") {
          //update-add each history to OverAllTrips History Data List
          context
              .read<AppDataProvider>()
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

  //readDriverEarnings
  static void readDriverEarnings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverEarnings = snap.snapshot.value.toString();
        context
            .read<AppDataProvider>()
            .updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripsKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        String driverRatings = snap.snapshot.value.toString();

        context
            .read<AppDataProvider>()
            .updateDriverAverageRatings(driverRatings);
      }
    });
  }
}
