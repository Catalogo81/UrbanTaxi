class Directions {
  final String humanReadableAddress;
  String? locationName;
  String? locationId;
  final double locationLatitude;
  final double locationLongitude;

  Directions({
    this.locationId,
    this.locationName,
    required this.humanReadableAddress,
    required this.locationLatitude,
    required this.locationLongitude,
  });
}
