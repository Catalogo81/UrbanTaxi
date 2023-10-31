import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserRideRequestInformation {
  final LatLng originLatLng;
  final LatLng destinationLatLng;
  final String originAddress;
  final String destinationAddress;
  final String rideRequestId;
  final String userName;
  final String userPhone;

  UserRideRequestInformation({
    required this.originLatLng,
    required this.destinationLatLng,
    required this.originAddress,
    required this.destinationAddress,
    required this.rideRequestId,
    required this.userName,
    required this.userPhone,
  });
}
