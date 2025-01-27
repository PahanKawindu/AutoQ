import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter1/controller/Helper_models/service_history.dart';

class UserServiceHistory extends StatefulWidget {
  @override
  _UserServiceHistoryState createState() => _UserServiceHistoryState();
}

class _UserServiceHistoryState extends State<UserServiceHistory> {
  final ServiceHistory serviceHistory = ServiceHistory();
  Future<List<Map<String, dynamic>>>? serviceHistoryData;

  @override
  void initState() {
    super.initState();
    serviceHistoryData = serviceHistory.getUserServiceHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:Color(0xFFE5E5E5),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: serviceHistoryData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No service history available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            final history = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your Last Services:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final formattedDate = DateFormat('yyyy-MM-dd – kk:mm')
                          .format(item['appointmentDate'].toDate());

                      return Card(
                        elevation: 6, // Adds shadow for a more elevated appearance
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Rounded corners for the card
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0), // Adds padding inside the card
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
                            children: [
                              // Large Icon on the left
                              Icon(
                                Icons.history,
                                color: Colors.grey, // Orange color for the icon
                                size: 50, // Larger size for the icon
                              ),
                              SizedBox(width: 16), // Space between icon and text
                              // Column for Text Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title: Service Package Name
                                    Text(
                                      item['servicePackageName'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8), // Space between title and subtitle
                                    // Subtitle details
                                    Text(
                                      'Date: $formattedDate',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Price: Rs. ${item['price']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Vehicle Type: ${item['vehicleType']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Reg No: ${item['vehicleRegNo']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
