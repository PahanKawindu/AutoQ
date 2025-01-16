import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_bottom.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_middle.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_top.dart';


class CheckQueue extends StatelessWidget {
  final QueueService queueService = QueueService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Queue'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: queueService.getTodayQueueInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContentTop(
                  totalPositionsToday: data['totalPositionsToday'] ?? 0,
                  currentServicingPosition: int.tryParse(data['currentServicingPosition']?.toString() ?? '0') ?? 0,
                ),
                SizedBox(height: 10),
                ContentMiddle(
                  totalPositionsToday: data['totalPositionsToday'] ?? 0,
                  //hasReservation: data['hasReservation'] ?? false,
                  userPosition: (data['userPosition']?.toString() ?? 'Not found'),

                ),
                SizedBox(height: 10),
                ContentBottom(
                  hasReservation: data['hasReservation'] ?? false,
                  isServiced: data['isServiced'] ?? false,
                  currentServicingPosition: int.tryParse(data['currentServicingPosition']?.toString() ?? '0') ?? 0,
                  userPosition: (data['userPosition']?.toString() ?? 'Not found'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
