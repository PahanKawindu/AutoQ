import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String? _uid;  // Declare _uid as nullable

  // Load the UID from SharedPreferences
  Future<void> _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _uid = prefs.getString('uid');  // Get UID from SharedPreferences
    });
  }

  // Fetch notification history from Firestore
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    if (_uid == null) {
      return []; // If UID is not available, return an empty list
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notification_history')
        .where('uid', isEqualTo: _uid)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> notifications = [];
    for (var doc in snapshot.docs) {
      notifications.add({
        'status': doc['status'],
        'timestamp': doc['timestamp'].toDate(),
      });
    }
    return notifications;
  }

  @override
  void initState() {
    super.initState();
    _loadUid();  // Load UID when the screen is initialized
  }

  // Format the timestamp to a more user-friendly format
  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute}:${timestamp.second}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
      ),
      body: Container(
        color: const Color(0xFFE5E5E5), // Set the body background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notification History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            // Notification list section
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _uid != null ? _fetchNotifications() : Future.value([]),  // Only fetch notifications if UID is loaded
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No notifications available.'));
                  } else {
                    List<Map<String, dynamic>> notifications = snapshot.data!;
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        var notification = notifications[index];
                        var timestamp = notification['timestamp'];
                        var formattedTime = _formatTimestamp(timestamp);

                        return Card(
                          color: const Color(0xFFE5F7F1),
                          elevation: 5,  // Adds shadow for visual effect
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),  // Rounded corners for the card
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Notification Status
                                Text(
                                  notification['status'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Notification Timestamp
                                Text(
                                  "Received on: $formattedTime",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}