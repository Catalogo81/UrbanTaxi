import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/user_model.dart';

User? currentFirebaseUser;
AppUser? userModelCurrentInfo;
List dList = []; //online-active drivers Information List
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String cloudMessagingServerToken = "key=AAAAvfqdITE:APA91bH4dpylpyjMqfXyr"
    "PiSjhS1gGiNHgmKZwGDxMkB6EdMg0Ya5tpBDIJ"
    "taDlYKgjSDvVaQtkrE8SUYkgI3YSePx9T6dn_3n"
    "3f6dX_sjzWAAUCA9zpGcrmms8S-36w9Ky1_Vk0Hxr2";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleStarsRating = "";
String oneSignalAppID = "97c93102-1817-4adc-9aa3-b40ce9776640";


//97c93102-1817-4adc-9aa3-b40ce9776640
//OneSignal App ID
