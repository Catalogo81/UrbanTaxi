import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/app_info.dart';
import '../widgets/history_design_ui.dart';

class TripsHistoryScreen extends StatefulWidget {
  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Trips History"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i) => const Divider(
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
        itemBuilder: (context, i) {
          return Card(
            color: Colors.white54,
            child: TripWidget(
              tripsHistoryModel: context.read<AppDataProvider>().tripHistory[i],
            ),
          );
        },
        itemCount: context.read<AppDataProvider>().tripHistory.length,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
