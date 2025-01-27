import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_bottom.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_middle.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/check_queue_content/content_top.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckQueue extends StatefulWidget {
  @override
  _CheckQueueState createState() => _CheckQueueState();
}

class _CheckQueueState extends State<CheckQueue> {
  final QueueService queueService = QueueService();
  Future<Map<String, dynamic>>? queueData;

  @override
  void initState() {
    super.initState();
    queueData = queueService.getTodayQueueInfo();

    // Listen for changes in the 'queue' collection
    FirebaseFirestore.instance
        .collection('queue')
        .snapshots()
        .listen((snapshot) {
      // Trigger a refresh when there's a change in the 'queue' collection
      _refreshQueueData();
    });
  }

  Future<void> _refreshQueueData() async {
    setState(() {
      queueData = queueService.getTodayQueueInfo();
    });
    await queueData; // Wait for the data to refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F7F1),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshQueueData,
        child: FutureBuilder<Map<String, dynamic>>(
          future: queueData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContentTop(
                      totalPositionsToday: data['totalPositionsToday'] ?? 0,
                      currentServicingPosition: int.tryParse(data['currentServicingPosition']?.toString() ?? '0') ?? 0,
                      userPosition: (data['userPosition']?.toString() ?? 'Not found'),
                    ),
                    SizedBox(height: 10),
                    ContentMiddle(
                      totalPositionsToday: data['totalPositionsToday'] ?? 0,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
