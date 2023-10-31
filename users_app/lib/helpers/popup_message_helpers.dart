import 'package:flutter/material.dart';

class PopupMessageHelpers {
  static void showSnackBar(BuildContext context, String message) {
    showSnackBar(context, message);
  }

  static Future<dynamic> showPopupDialog(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
