import 'package:flutter/cupertino.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/trips_history_model.dart';

class AppDataViewModel extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<Trip> allTripsHistoryInformationList = [];

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

  updateOverAllTripsKeys(List<String> tripsKeysList) {
    historyTripsKeysList = tripsKeysList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(Trip eachTripHistory) {
    allTripsHistoryInformationList.add(eachTripHistory);
    notifyListeners();
  }
}
