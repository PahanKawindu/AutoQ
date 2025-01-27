import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format the date
import 'notification_handler.dart'; // Import notification handler
import 'package:test_flutter1/controller/Helper_models/service_history.dart';

class UpdateQueueStatusAdmin extends StatefulWidget {
  final Map<String, dynamic> queueData;

  UpdateQueueStatusAdmin({required this.queueData});

  @override
  _UpdateQueueStatusAdminState createState() => _UpdateQueueStatusAdminState();
}

class _UpdateQueueStatusAdminState extends State<UpdateQueueStatusAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false; // To show loading spinner
  String? _selectedStatus; // Selected status

  @override
  Widget build(BuildContext context) {
    // Format the queue time
    DateTime queueTime = widget.queueData['queueTime'].toDate();
    String formattedQueueTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(queueTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F7F1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Owner', '${widget.queueData['first_name']} ${widget.queueData['last_name']}'),
                    _buildInfoRow('Appointment ID', widget.queueData['appointmentId']),
                    _buildInfoRow('Queue Time', formattedQueueTime),
                    _buildInfoRow('Position No', widget.queueData['positionNo'].toString()),
                    _buildInfoRow('Status', widget.queueData['status'], highlight: true),
                    _buildInfoRow('Vehicle Type', widget.queueData['VehicleType']),
                    _buildInfoRow('Contact No', widget.queueData['contact_no']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select New Status:',
                      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    ..._buildStatusOptions(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF46C2AF),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _selectedStatus == null || _isLoading
                    ? null
                    : () async {
                  await _updateQueueStatus();
                },
                child: Text('Update Status', style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                color: highlight ? Colors.green : Colors.black, // Highlight service status
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusOptions() {
    final statuses = {
      'completed': 'Completed',
      'servicing': 'Servicing',
      'waiting': 'Waiting',
      'canceled': 'Canceled'
    };

    return statuses.entries.map((entry) {
      return RadioListTile<String>(
        title: Text(entry.value, style: TextStyle(fontSize: 16, color: Colors.black54)), // Small font size
        value: entry.key,
        groupValue: _selectedStatus,
        onChanged: (String? value) {
          setState(() {
            _selectedStatus = value;
          });
        },
        activeColor: const Color(0xFF46C2AF),
      );
    }).toList();
  }

  // Method to update the status
  Future<void> _updateQueueStatus() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    try {
      // Update the document with the new status
      await _firestore.collection('queue').doc(widget.queueData['appointmentId']).update({
        'status': _selectedStatus,
      });

      // Fetch UID from the appointment document
      var appointmentDoc = await _firestore.collection('appointments').doc(widget.queueData['appointmentId']).get();
      String uid = appointmentDoc['uid'];

      // Now fetch the user's document using UID
      var userDoc = await _firestore.collection('users').doc(uid).get();
      String deviceToken = userDoc['device_token'];
      String firstName = userDoc['first_name'];
      String lastName = userDoc['last_name'];
      String vehicleType = widget.queueData['VehicleType'];
      String vehicleRegNo = widget.queueData['vehicleRegNo'];

      String message = '';
      String notificationStatus = '';

      // If the status is 'completed', send a completion message
      if (_selectedStatus == 'completed') {
        message = 'Dear $firstName $lastName, your $vehicleType ($vehicleRegNo) service has been completed successfully. You can now collect your vehicle at your earliest convenience. Thank you for choosing our service.';
        notificationStatus = 'Service Completed';

        // Add a new document to the service-history collection
        await _firestore.collection('service-history').doc(widget.queueData['appointmentId']).set({
          'appointmentId': widget.queueData['appointmentId'],
          'status': 'completed',
          'uid': uid,
        });
      }

      // If the status is 'canceled', send a cancellation message
      if (_selectedStatus == 'canceled') {
        message = 'Dear $firstName $lastName, unfortunately, there is a problem with your $vehicleType ($vehicleRegNo) service. Please contact us as soon as possible for further assistance. We apologize for the inconvenience.';
        notificationStatus = 'Service Canceled';
      }

      if (_selectedStatus == 'waiting') {
        message = 'Dear $firstName $lastName, your $vehicleType ($vehicleRegNo) is currently waiting in the queue for service. We will notify you once the service begins. Thank you for your patience.';
        notificationStatus = 'Service Waiting';
      }

      if (_selectedStatus == 'servicing') {
        message = 'Dear $firstName $lastName, the service process for your $vehicleType ($vehicleRegNo) has now started. We will keep you updated on the progress. Thank you for choosing our service.';
        notificationStatus = 'Service In Progress';
      }

      // Check if there's already an active message for the user in the active_messages collection
      var activeMessagesDoc = await _firestore.collection('active_messages').doc(uid).get();

      if (!activeMessagesDoc.exists) {
        // Create new document in the active_messages collection
        await _firestore.collection('active_messages').doc(uid).set({
          'id': uid,
          'message': message,
          'timestamp': Timestamp.now(),
        });
      } else {
        // Update the existing document in the active_messages collection
        await _firestore.collection('active_messages').doc(uid).update({
          'message': message,
          'timestamp': Timestamp.now(),
        });
      }


      // Send notification to the user
      await NotificationHandler.sendNotification(
        deviceToken, // Device token from Firestore
        notificationStatus, // Notification title
        message, // Custom message
      );

      // Add to notification history collection
      await _firestore.collection('notification_history').add({
        'uid': uid,
        'timestamp': Timestamp.now(),
        'status': message,
      });

      // Update service history
      await ServiceHistory.updateServiceHistory(widget.queueData);

      // Show success message
      _showSuccessMessage();

      // After update, return to the previous screen
      Navigator.pop(context, true); // Passing true to indicate data is updated
    } catch (e) {
      // Handle any errors
      setState(() {
        _isLoading = false;
      });
      print('Error updating queue status: $e');
      _showErrorMessage();
    }
  }

  // Method to show success message
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Queue status updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Method to show error message
  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating queue status!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
