import 'package:flutter/material.dart';

class InfoDesignUIWidget extends StatelessWidget {
  final String textInfo;
  final IconData iconData;

  const InfoDesignUIWidget({
    super.key,
    required this.textInfo,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white54,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Colors.black,
        ),
        title: Text(
          textInfo,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
