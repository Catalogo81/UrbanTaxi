// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:drivers_app/helpers/helper_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/push_notifications/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/dark_theme_google_map.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({Key? key}) : super(key: key);

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await HelperMethods.getAddressCoordinates(driverCurrentPosition!, context);

    HelperMethods.readDriverRatings(context);
  }

  readCurrentDriverInformation() async {
    await FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((DatabaseEvent snap) {
      if (snap.snapshot.value != null) {
        driverData.id = (snap.snapshot.value as Map)["id"];
        driverData.name = (snap.snapshot.value as Map)["name"];
        driverData.phone = (snap.snapshot.value as Map)["phone"];
        driverData.email = (snap.snapshot.value as Map)["email"];
        driverData.carColor =
            (snap.snapshot.value as Map)["car_details"]["car_color"];
        driverData.carModel =
            (snap.snapshot.value as Map)["car_details"]["car_model"];
        driverData.carNumber =
            (snap.snapshot.value as Map)["car_details"]["car_number"];

        driverVehicleType = (snap.snapshot.value as Map)["car_details"]["type"];
      }
    });

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initFCM(context);
    pushNotificationSystem.generateAndUploadToken();

    HelperMethods.readDriverEarnings(context);
  }

  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          myLocationEnabled: true,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;

            darkThemeGoogleMap(newGoogleMapController);

            locateDriverPosition();
          },
        ),
        driverStatus != "Now Online"
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.black87,
              )
            : Container(),
        Positioned(
          top: driverStatus != "Now Online"
              ? MediaQuery.of(context).size.height * 0.46
              : 25,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (isDriverActive != true) {
                    driverIsOnlineNow();
                    updateDriversLocationAtRealTime();

                    setState(() {
                      driverStatus = "Now Online";
                      isDriverActive = true;
                      buttonColor = Colors.transparent;
                    });

                    Fluttertoast.showToast(msg: "you are Online Now");
                  } else {
                    driverIsOfflineNow();

                    setState(() {
                      driverStatus = "Now Offline";
                      isDriverActive = false;
                      buttonColor = Colors.grey;
                    });

                    Fluttertoast.showToast(msg: "you are Offline Now");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: driverStatus != "Now Online"
                    ? Text(
                        driverStatus,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  driverIsOnlineNow() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    Geofire.initialize("activeDrivers");

    Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");

    ref.set("idle");
    ref.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      if (isDriverActive == true) {
        Geofire.setLocation(FirebaseAuth.instance.currentUser!.uid,
            driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude,
      );

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  driverIsOfflineNow() {
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    Future.delayed(const Duration(milliseconds: 2000), () {
      //SystemChannels.platform.invokeMethod("SystemNavigator.pop");
      SystemNavigator.pop();
    });
  }
}
