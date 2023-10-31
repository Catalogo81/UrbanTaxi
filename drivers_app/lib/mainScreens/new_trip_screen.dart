import 'dart:async';

import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:drivers_app/widgets/fare_amount_collection_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/helper_methods.dart';
import '../helpers/dark_theme_google_map.dart';
import '../widgets/progress_dialog.dart';

class NewTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  const NewTripScreen({
    super.key,
    this.userRideRequestDetails,
  });

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  GoogleMapController? newTripGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;

  Set<Marker> setOfMarkers = <Marker>{};
  Set<Circle> setOfCircle = <Circle>{};
  Set<Polyline> setOfPolyline = <Polyline>{};
  List<LatLng> polyLinePositionCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  double mapPadding = 0;
  BitmapDescriptor? iconAnimatedMarker;
  var geoLocator = Geolocator();
  Position? activeDriverCurrentPosition;

  String rideRequestStatus = "accepted";

  String durationFromOriginToDestination = "";

  bool isRequestDirectionDetails = false;

  Future<void> drawPolyLineFromOriginToDestination(
      LatLng originLatLng, LatLng destinationLatLng) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
        await HelperMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.ePoints);

    polyLinePositionCoordinates.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        polyLinePositionCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    setOfPolyline.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polyLinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      setOfPolyline.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newTripGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destinationCircle);
    });
  }

  @override
  void initState() {
    super.initState();

    saveAssignedDriverDetailsToUserRideRequest();
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatLng = const LatLng(0, 0);

    streamDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      activeDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
        activeDriverCurrentPosition!.latitude,
        activeDriverCurrentPosition!.longitude,
      );

      Marker animatingMarker = Marker(
        markerId: const MarkerId("AnimatedMarker"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: const InfoWindow(title: "This is your Position"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
        newTripGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        setOfMarkers.removeWhere(
            (element) => element.markerId.value == "AnimatedMarker");
        setOfMarkers.add(animatingMarker);
      });

      oldLatLng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();

      Map driverLatLngDataMap = {
        "latitude": activeDriverCurrentPosition!.latitude.toString(),
        "longitude": activeDriverCurrentPosition!.longitude.toString(),
      };
      FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId)
          .child("driverLocation")
          .set(driverLatLngDataMap);
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails == false) {
      isRequestDirectionDetails = true;

      if (activeDriverCurrentPosition == null) {
        return;
      }

      var originLatLng = LatLng(
        activeDriverCurrentPosition!.latitude,
        activeDriverCurrentPosition!.longitude,
      );

      var destinationLatLng;

      if (rideRequestStatus == "accepted") {
        destinationLatLng = widget.userRideRequestDetails!.originLatLng;
      } else {
        destinationLatLng = widget.userRideRequestDetails!.destinationLatLng;
      }

      var directionInformation =
          await HelperMethods.obtainOriginToDestinationDirectionDetails(
              originLatLng, destinationLatLng);

      if (directionInformation != null) {
        setState(() {
          durationFromOriginToDestination = directionInformation.durationText;
        });
      }

      isRequestDirectionDetails = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;

              setState(() {
                mapPadding = 350;
              });

              darkThemeGoogleMap(newTripGoogleMapController);

              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude,
                  driverCurrentPosition!.longitude);

              var userPickUpLatLng =
                  widget.userRideRequestDetails!.originLatLng;

              drawPolyLineFromOriginToDestination(
                  driverCurrentLatLng, userPickUpLatLng);

              getDriversLocationUpdatesAtRealTime();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white30,
                    blurRadius: 18,
                    spreadRadius: .5,
                    offset: Offset(0.6, 0.6),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      durationFromOriginToDestination,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightGreenAccent,
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          widget.userRideRequestDetails!.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "images/origin.png",
                          width: 30,
                          height: 30,
                        ),
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
                    Row(
                      children: [
                        Image.asset(
                          "images/destination.png",
                          width: 30,
                          height: 30,
                        ),
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
                    const SizedBox(
                      height: 24,
                    ),
                    const Divider(
                      thickness: 2,
                      height: 2,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (rideRequestStatus == "accepted") {
                          rideRequestStatus = "arrived";

                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(
                                  widget.userRideRequestDetails!.rideRequestId)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "Let's Go";
                            buttonColor = Colors.lightGreen;
                          });

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext c) => ProgressDialog(
                              message: "Loading...",
                            ),
                          );

                          await drawPolyLineFromOriginToDestination(
                              widget.userRideRequestDetails!.originLatLng,
                              widget.userRideRequestDetails!.destinationLatLng);

                          Navigator.pop(context);
                        } else if (rideRequestStatus == "arrived") {
                          rideRequestStatus = "ontrip";

                          FirebaseDatabase.instance
                              .ref()
                              .child("All Ride Requests")
                              .child(
                                  widget.userRideRequestDetails!.rideRequestId)
                              .child("status")
                              .set(rideRequestStatus);

                          setState(() {
                            buttonTitle = "End Trip";
                            buttonColor = Colors.redAccent;
                          });
                        } else if (rideRequestStatus == "ontrip") {
                          endTripNow();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                      ),
                      icon: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Text(
                        buttonTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  endTripNow() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var currentDriverPositionLatLng = LatLng(
      activeDriverCurrentPosition!.latitude,
      activeDriverCurrentPosition!.longitude,
    );

    var tripDirectionDetails =
        await HelperMethods.obtainOriginToDestinationDirectionDetails(
            currentDriverPositionLatLng,
            widget.userRideRequestDetails!.originLatLng);

    double totalFareAmount =
        HelperMethods.calculateFareAmountFromOriginToDestination(
            tripDirectionDetails!);

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId)
        .child("fareAmount")
        .set(totalFareAmount.toString());

    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId)
        .child("status")
        .set("ended");

    streamDriverLivePosition!.cancel();

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext c) => CollectPaymentDialog(
        totalFareAmount: totalFareAmount,
      ),
    );

    saveFareToDriverEarnings(totalFareAmount);
  }

  saveFareToDriverEarnings(double totalFareAmount) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        double oldEarnings = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalFareAmount + oldEarnings;

        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("earnings")
            .set(driverTotalEarnings.toString());
      } else {
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child("earnings")
            .set(totalFareAmount.toString());
      }
    });
  }

  saveAssignedDriverDetailsToUserRideRequest() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(widget.userRideRequestDetails!.rideRequestId);

    Map driverLocationDataMap = {
      "latitude": driverCurrentPosition!.latitude.toString(),
      "longitude": driverCurrentPosition!.longitude.toString(),
    };
    databaseReference.child("driverLocation").set(driverLocationDataMap);

    databaseReference.child("status").set("accepted");
    databaseReference.child("driverId").set(driverData.id);
    databaseReference.child("driverName").set(driverData.name);
    databaseReference.child("driverPhone").set(driverData.phone);
    databaseReference.child("car_details").set(driverData.carColor.toString() +
        " " +
        driverData.carModel.toString() +
        " " +
        driverData.carNumber.toString());
  }
}
