import '../models/active_nearbydriver.dart';

class GeoFireHelper {
  static List<ActiveNearbyDriver> activeNearbyDriversList = [];

  static void deleteOfflineDriverFromList(String driverId) {
    int indexNumber = activeNearbyDriversList
        .indexWhere((element) => element.driverId == driverId);
    activeNearbyDriversList.removeAt(indexNumber);
  }

  static void updateActiveNearbyAvailableDriverLocation(
      ActiveNearbyDriver driverWhoMove) {
    int indexNumber = activeNearbyDriversList.indexWhere(
      (driver) => driver.driverId == driverWhoMove.driverId,
    );

    activeNearbyDriversList[indexNumber].locationLatitude =
        driverWhoMove.locationLatitude;
    activeNearbyDriversList[indexNumber].locationLongitude =
        driverWhoMove.locationLongitude;
  }
}
