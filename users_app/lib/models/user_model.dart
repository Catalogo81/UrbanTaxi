import 'package:firebase_database/firebase_database.dart';

class AppUser {
  final String phone;
  final String name;
  final String id;
  final String email;

  AppUser({
    required this.phone,
    required this.name,
    required this.id,
    required this.email,
  });

  factory AppUser.fromSnapshot(DataSnapshot snap) => AppUser(
        id: snap.key ?? "",
        phone: (snap.value as dynamic)["phone"],
        name: (snap.value as dynamic)["name"],
        email: (snap.value as dynamic)["email"],
      );
}
