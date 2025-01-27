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
                        margin:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(item['servicePackageName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: $formattedDate'),
                              Text('Price: \$${item['price']}'),
                              Text('Vehicle Type: ${item['vehicleType']}'),
                              Text('Reg No: ${item['vehicleRegNo']}'),
                            ],
                          ),
                          trailing: Icon(Icons.history),
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
