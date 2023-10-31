import 'dart:async';

import 'package:drivers_app/models/driver_data.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamDriverLivePosition;
Position? driverCurrentPosition;
DriverData driverData = DriverData();
String? driverVehicleType = "";
String starRating = "Good";
bool isDriverActive = false;
String driverStatus = "Now Offline";
Color buttonColor = Colors.grey;
