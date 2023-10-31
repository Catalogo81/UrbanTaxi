import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../global/global.dart';

class PushNotificationService with ChangeNotifier {
  // PushNotificationService() {
  //   initPlatformState();
  // }

  // Future<void> initPlatformState() async {
  //   //Remove this method to stop OneSignal Debugging
  //   await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  //   OneSignal.initialize(oneSignalAppID);

  //   //The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt.
  //   //We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  //   await OneSignal.Notifications.requestPermission(true);
  //   await OneSignal.login(currentFirebaseUser!.email!);
  //   OneSignal.User
  //     ..pushSubscription.optIn()
  //     ..addEmail(currentFirebaseUser!.email!)
  //     ..addTagWithKey("user", "rider")
  //     ..addTagWithKey(
  //         "user_id", FirebaseAuth.instance.currentUser?.email ?? "null");
  // }
}
