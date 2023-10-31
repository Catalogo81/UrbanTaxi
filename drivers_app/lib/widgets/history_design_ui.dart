import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trips_history_model.dart';

class TripWidget extends StatefulWidget {
  final Trip? tripsHistoryModel;

  const TripWidget({super.key, required this.tripsHistoryModel});

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);

    String formattedDatetime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDatetime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    "User : ${widget.tripsHistoryModel!.userName!}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  "R ${widget.tripsHistoryModel!.fareAmount!}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 2,
            ),

            Row(
              children: [
                const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.black,
                  size: 28,
                ),
                const SizedBox(
                  width: 12,
                ),
                Text(
                  widget.tripsHistoryModel!.userPhone!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Image.asset(
                  "images/origin.png",
                  height: 26,
                  width: 26,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    widget.tripsHistoryModel!.originAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            //icon + dropOff
            Row(
              children: [
                Image.asset(
                  "images/destination.png",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    widget.tripsHistoryModel!.destinationAddress!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(""),
                Text(
                  formatDateAndTime(widget.tripsHistoryModel!.time!),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
