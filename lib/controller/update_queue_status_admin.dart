// Import the necessary files
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
        title: Text('Update Queue Status'),
        backgroundColor: const Color(0xFF46C2AF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: ${widget.queueData['first_name']} ${widget.queueData['last_name']}'),
            SizedBox(height: 10),
            Text('Appointment ID: ${widget.queueData['appointmentId']}'),
            SizedBox(height: 10),
            Text('Queue Time: $formattedQueueTime'),
            SizedBox(height: 10),
            Text('Position No: ${widget.queueData['positionNo']}'),
            SizedBox(height: 10),
            Text('Status: ${widget.queueData['status']}'),
            SizedBox(height: 10),
            Text('Vehicle Type: ${widget.queueData['VehicleType']}'),
            SizedBox(height: 10),
            Text('Contact No: ${widget.queueData['contact_no']}'),
            SizedBox(height: 20),
            Text('Select New Status:'),
            RadioListTile<String>(
              title: Text('Completed'),
              value: 'completed',
              groupValue: _selectedStatus,
              onChanged: (String? value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Servicing'),
              value: 'servicing',
              groupValue: _selectedStatus,
              onChanged: (String? value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Waiting'),
              value: 'waiting',
              groupValue: _selectedStatus,
              onChanged: (String? value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text('Canceled'),
              value: 'canceled',
              groupValue: _selectedStatus,
              onChanged: (String? value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator()) // Show spinner while loading
                : Center(
              child: ElevatedButton(
                onPressed: _selectedStatus == null || _isLoading
                    ? null
                    : () async {
                  await _updateQueueStatus();
                },
                child: Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
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
