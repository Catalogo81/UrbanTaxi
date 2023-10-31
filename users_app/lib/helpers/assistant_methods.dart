import 'package:firebase_cloud_messaging_flutter/firebase_cloud_messaging_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/helpers/request_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/view_models/app_data_view_model.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/trips_history_model.dart';

class HelperMethods {
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, BuildContext context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    print(requestResponse);

    if (requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      context
          .read<AppDataViewModel>()
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?> getDirections(
      LatLng origionPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origionPosition.latitude},${origionPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred, Failed. No Response.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.duration_value! / 1000) * 0.1;

    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

  static Future<void> sendNotificationToDriverWithFCM(
      String deviceRegistrationToken,
      String userRideRequestId,
      String driverID,
      context) async {
    final mapCred = {
      "type": "service_account",
      "project_id": "urbantaxi-b8ffc",
      "private_key_id": "21a666aa4cb45014f4596bd9a405345f8be93bce",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCrZ5u8J4j5T3UL\nCciqyTcBwpLP50ROk8xfpalYxbWDrzOObjPB6aQF/6Us0COI5HTYTVyGymLL2FiT\nojDeOr4Qs6Cqerxokkje53Xz4DQ96C1/615kGmXQj9hlqA5DlSCJaeOuYzVqEqAS\nQKMbTqemvsgPPM0POsZPI3Ixecenpl3z9Q1ULCS+edCwY5VAnQScUXc4gi4pR0yF\n45I8RlGS4NMSYQiYs4KrdUwgtnu0HqWmUnRk7ygYNNl/nYUNEDYsmwqjg4eEg2aV\nqZZLU8dkrX5UuUZw+T9zBI+lzuOPXZlo/xYm7bDKYg50Cwg0MQzhom2ML+S9KCRv\nWQfMJfw5AgMBAAECggEAD2Mm25BrhyEbU2U6lN1pMSDh6+TZsJmrV1tQfXoLQmH6\nNYM+ZX43Zbv2XLRnOkDzHd9tCuM0lRLsGb3N2AdrPGXZyrAnxZX7UXpzL/Rs0DFt\nkz4inEcz5HIjZbXdaPMEZ52gTU2V9BqtsNHJarhIC+u020xUptU6jAx1MgyaEDpU\n272niBH3yNu8gwa7Gm72MM+0U9iQRgRYLDXapxGPHa7jRbiuIq/zTUqZ/swgi+Bj\nsxi6vYHtF2ogzAa8IBXcIdSWWbva0U97WlVEYmNKwlHKI+me5AnfTRUSlplgbRG0\nUPfM3Pu3tKd3NmwIhAOwta8oSbumrk9q/0rb5eiocQKBgQDwtRAFhWdpvFaNTkKU\nCqziaQK3bTUhGFH//ZeFFm/OrHlTaiGkx9OWZAUjagTaLRSbY1hmOPIBevpQGKqG\nnoZ8PFhvwiDHv1F3IrExPFwYSe7LCSkRsgvpQaO39LUkDoy7VYu0IR0bgEe3nzAN\ntuwAbzxwdfzRjl/pJpBNAAETEQKBgQC2S2M5+of4wS8DBFlby+PTNqV1P+yr1Y2b\nIp+n1RuS6FGUyePmfVJW4ogSrdKohDriinL00iqgvoRaEJTADbv9c16zYr1CF/9A\nqCSIu19Ykzvz4tKspfYVkASVU+5cEDSY+IGJh9IsjLqy/uZDBF3sK+n9gT4lq/lZ\nZCYX+R4GqQKBgQDpW6Acuih3qc9/Ts/dFjxlg8jOa2GGpD1bIE81B3t9slgtNkdH\nqTLIKk+Q9ceefPXtb3LUJ4D3TnI+FKu9txJKf3Z9YobFIAWqqkd+pDXklkibLlZS\ngXpquOgv/11dh32IYHcAOtotP0BIFFxR73T9NtoxbTGdN5pkPq7G96oTAQKBgHne\nOk7XazFkzO4CaU7SJtPcM48IFkvmL43n/r4v3QhAYdHLip1baMGHHhsGs89O3yL2\nFdYP7smZtFeVwCwIwoW1LDlWqFnYOx/ZiNsUELDhdXIdUGR1aueNaVL/Ulmfx9oA\nQHFWKK75whLKD9v7vmKWFQ8R6R88Mi2No13hgC5JAoGBAMGBZWyj3FcxBOkpQPj/\nPPO8FyZnFH5UlYJZGsAOUKvOWjaKqtPFOf9GD9D/QVNNZT8axc9UsGvuFfKIMBTv\nhcPxxXcXEHJ5acvlZK/bECLzys+B2L3wZ6uWlX4zm/g9B3wJbNHFVvRyeqXG70nA\ne22zn82fkXUq98KV7hBnkLeF\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-3w98k@urbantaxi-b8ffc.iam.gserviceaccount.com",
      "client_id": "104716737467576030967",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-3w98k%40urbantaxi-b8ffc.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    String destinationAddress = userDropOffAddress;

    Map<String, String> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    FirebaseCloudMessagingServer server = FirebaseCloudMessagingServer(mapCred);

    var result = await server.send(
      FirebaseSend(
        validateOnly: false,
        message: FirebaseMessage(
          topic: "allDrivers",
          notification: FirebaseNotification(
            title: 'New Trip Request',
            body: "Destination Address: \n$destinationAddress.",
          ),
          android: FirebaseAndroidConfig(
            data: dataMap,
            ttl: '0',
            notification: const FirebaseAndroidNotification(
              notificationPriority: NotificationPriority.PRIORITY_HIGH,
            ),
          ),
          token: deviceRegistrationToken,
        ),
      ),
    );
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken,
      String userRideRequestId, context) async {}

  //retrieve the trips KEYS for online user
  //trip key = ride request key
  static void readTripKeys(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo?.name)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        context
            .read<AppDataViewModel>()
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        context.read<AppDataViewModel>().updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(BuildContext context) {
    var tripsAllKeys = context.read<AppDataViewModel>().historyTripsKeysList;

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
              .read<AppDataViewModel>()
              .updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }
}
