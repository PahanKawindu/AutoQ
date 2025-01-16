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
    List<Map<String, dynamic>> queueData = await QueueService().getTodayQueueWithVehicleType();
    setState(() {
      _todayQueue = queueData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today Queue'),
        backgroundColor: const Color(0xFF46C2AF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _todayQueue.isEmpty
          ? Center(child: Text('No Reservation for today'))
          : ListView.builder(
        itemCount: _todayQueue.length,
        itemBuilder: (context, index) {
          var queueItem = _todayQueue[index];

          // Card color logic based on status
          Color cardColor;
          if (queueItem['status'] == 'completed') {
            cardColor = Colors.green;
          } else if (queueItem['status'] == 'canceled') {
            cardColor = Colors.red;
          } else {
            cardColor = Colors.white;
          }

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reg No: ${queueItem['vehicleRegNo']}'),
                      Text('Type: ${queueItem['VehicleType']}'),
                      Text('Position No: ${queueItem['positionNo']}'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Owner: ${queueItem['first_name']} ${queueItem['last_name']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Contact: ${queueItem['contact_no']}'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Status: ${queueItem['status']}'),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Navigate to UpdateQueueStatusAdmin screen and wait for result
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateQueueStatusAdmin(
                                queueData: queueItem,
                              ),
                            ),
                          );

                          // If result is true, refresh the queue data
                          if (result != null && result) {
                            _fetchTodayQueue(); // Refresh the data
                          }
                        },
                        child: Text('Update Status'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
