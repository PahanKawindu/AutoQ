// Import the necessary files
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // To format the date
import 'package:test_flutter1/controller/Helper_models/service_history.dart';
import 'notification_handler.dart'; // Import notification handler

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

      // If the status is 'completed', call additional methods
      if (_selectedStatus == 'completed') {
        await NotificationHandler.notifyServiceStatus(widget.queueData); // Notify service status
        await ServiceHistory.updateServiceHistory(widget.queueData); // Update service history
      }

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
