import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:test_flutter1/controller/update_queue_status_admin.dart';

class ViewTodayQueueAdmin extends StatefulWidget {
  @override
  _ViewTodayQueueAdminState createState() => _ViewTodayQueueAdminState();
}

class _ViewTodayQueueAdminState extends State<ViewTodayQueueAdmin> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todayQueue = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayQueue();
  }

  // Fetch the queue data
  Future<void> _fetchTodayQueue() async {
    List<Map<String, dynamic>> queueData =
    await QueueService().getTodayQueueWithVehicleType();
    setState(() {
      _todayQueue = queueData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F7F1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading and Slogan
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Today\'s Queue',
                  style: TextStyle(
                    fontSize: 20, // Heading font size
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Heading color
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage and track your reservations effortlessly.',
                  style: TextStyle(
                    fontSize: 16, // Slogan font size
                    color: Colors.black54, // Slogan color
                  ),
                ),
              ],
            ),
          ),
          // Queue List
          Expanded(
            child: _todayQueue.isEmpty
                ? Center(
              child: Text(
                'No Reservation for today',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
                : ListView.builder(
              itemCount: _todayQueue.length,
              itemBuilder: (context, index) {
                var queueItem = _todayQueue[index];

                // Dynamic status color
                Color statusColor;
                if (queueItem['status'] == 'completed') {
                  statusColor = Colors.green;
                } else if (queueItem['status'] == 'canceled') {
                  statusColor = Colors.red;
                } else {
                  statusColor = Colors.orange;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Owner Name and Appointment Icon
                        Row(
                          children: [
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${queueItem['first_name']} ${queueItem['last_name']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Contact Info
                        Row(
                          children: [
                            Icon(Icons.call,
                                color: Colors.teal, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Contact Info   :     ${queueItem['contact_no']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Vehicle Details
                        Row(
                          children: [
                            Icon(Icons.directions_car,
                                color: Colors.teal, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Vehicle Type  :     ${queueItem['VehicleType']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.confirmation_number,
                                color: Colors.teal, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Reg No           :     ${queueItem['vehicleRegNo']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.chair,
                                color: Colors.teal, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Position No    :     ${queueItem['positionNo']}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),

                        // Status and Button
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info,
                                    color: statusColor, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Status: ${queueItem['status']}',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            if (queueItem['status'] !=
                                'completed' &&
                                queueItem['status'] != 'canceled')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  // Navigate to UpdateQueueStatusAdmin screen
                                  bool? result =
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateQueueStatusAdmin(
                                            queueData: queueItem,
                                          ),
                                    ),
                                  );

                                  // Refresh data if status is updated
                                  if (result != null && result) {
                                    _fetchTodayQueue();
                                  }
                                },
                                child: Text(
                                  'Update Status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
