import 'package:flutter/cupertino.dart';

import '../models/directions.dart';
import '../models/trips_history_model.dart';

class AppDataProvider extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  String driverTotalEarnings = "0";
  String averageDriverRating = "0";
  List<String> historyTripKeys = [];
  List<Trip> tripHistory = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAllTripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripKeys) {
    historyTripKeys = tripKeys;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(Trip trip) {
    tripHistory.add(trip);
    notifyListeners();
  }

  updateDriverTotalEarnings(String driverEarnings) {
    driverTotalEarnings = driverEarnings;
  }

  updateDriverAverageRatings(String driverRating) {
    averageDriverRating = driverRating;
  }
}
