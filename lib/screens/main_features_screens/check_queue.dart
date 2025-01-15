import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';


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
        future: queueService.getTodayQueueInfo(), // Call the new method here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          // Ensure values are non-null and default to false if null
          bool isReservationForToday = data['hasReservation'] ?? false;
          bool isServiced = data['isServiced'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Positions Today: ${data['totalPositionsToday']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Current Servicing Position: ${data['currentServicingPosition']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Is there a reservation for today? ${isReservationForToday ? 'Yes' : 'No'}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Your Position: ${data['userPosition'] ?? 'Not found'}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Is your vehicle serviced? ${isServiced ? 'Yes' : 'No'}', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
