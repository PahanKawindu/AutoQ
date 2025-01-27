import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/controller/Helper_models/appointments.dart';
import 'package:test_flutter1/controller/payment_controller.dart';

class VehicleDetails extends StatefulWidget {
  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  final _registrationController = TextEditingController();
  final _chassisController = TextEditingController();
  bool _isFormValid = false;

  // Save the vehicle details to shared preferences
  Future<void> _saveVehicleDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('vehicle_registration', _registrationController.text);
    prefs.setString('vehicle_chassis', _chassisController.text);
  }

  // Remove vehicle details from shared preferences
  Future<void> _removeVehicleDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('vehicle_registration');
    prefs.remove('vehicle_chassis');
  }

  // Validate the form inputs
  void _validateForm() {
    setState(() {
      _isFormValid =
          _registrationController.text.isNotEmpty && _chassisController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Remove data from shared preferences when leaving the page
    _removeVehicleDetails();
    super.dispose();
  }

  // New method to check for approved appointment
  Future<bool> _checkApprovedAppointment(DateTime selectedDate, int positionNo) async {
    AppointmentsService appointmentsService = AppointmentsService();
    try {
      // Check if there's any approved appointment for the selected date and position number
      bool isApproved = await appointmentsService.checkApprovedAppointment(selectedDate, positionNo);
      return isApproved;
    } catch (e) {
      print('Error checking approved appointment: $e');
      return false;
    }
  }

  // New method to create an appointment if no approved appointment exists
  Future<void> _makeAppointment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectedDate = prefs.getString('selectedDate') ?? '';

    int selectedQueueNumber = prefs.getInt('selectedQueueNumber') ?? 0;
    String estimatedQueueTime =
        prefs.getString('estimatedQueueTime') ?? '2025-01-17 08:00:00'; // Default if not found
    print('estimatedQueueTime : $estimatedQueueTime');
    String uid = prefs.getString('uid') ?? '';

    DateTime appointmentDate = DateTime.parse(selectedDate);
    print('appointmentDate : $appointmentDate');
    bool appointmentExists =
    await _checkApprovedAppointment(appointmentDate, selectedQueueNumber);
    print('appointmentExists : $appointmentExists');
    if (appointmentExists) {
      // Show message if an approved appointment exists for the selected position and date
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Appointment Already Reserved'),
          content: Text(
              'Your position is already reserved. Please check again later. Please approve your appointment by making payment.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Navigate back to the previous screen (SelectDate)
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

      // Remove saved vehicle details
      await _removeVehicleDetails();
    } else {
      // If no approved appointment exists, create a new waiting appointment
      await _createWaitingAppointment(
          appointmentDate, selectedQueueNumber, uid, estimatedQueueTime);
    }
  }

  // Method to create a waiting appointment
  Future<void> _createWaitingAppointment(
      DateTime appointmentDate, int positionNo, String uid, String estimatedQueueTime) async {
    try {
      // Parse the full estimatedQueueTime string into a DateTime object
      DateTime parsedQueueTime = DateTime.parse(estimatedQueueTime);

      // Combine the appointment date with the time from estimatedQueueTime
      DateTime combinedAppointmentDate = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        parsedQueueTime.hour,
        parsedQueueTime.minute,
        parsedQueueTime.second,
      );

      // Create a new waiting appointment document in Firestore
      await FirebaseFirestore.instance.collection('waiting_appointments').add({
        'Status': 'pending',
        'appointmentDate': Timestamp.fromDate(combinedAppointmentDate), // Store both date and time
        'positionNo': positionNo,
        'serviceId': 3,
        'uid': uid,
      });

      // Save vehicle details after successful appointment
      await _saveVehicleDetails();

      // Navigate to the PaymentController screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentController()),
      );

      // Show confirmation message
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Matches the rounded corners in your theme
            side: BorderSide(
              color: Color(0xFFFFA726), // Orange border color
              width: 1.5, // Thin border width
            ),
          ),
          backgroundColor: Color(0xFFFFF7E8), // Light yellow background color
          titlePadding: EdgeInsets.zero, // Removes default padding
          contentPadding: EdgeInsets.all(16),
          title: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFF7E8), // White background for the title section
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Color(0xFFFFA726)), // Orange info icon
                SizedBox(width: 8),
                Text(
                  'Notice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333), // Dark gray text color
                  ),
                ),
              ],
            ),
          ),
          content: Text(
            'The system has temporarily reserved your queue position. Please complete the payment promptly to confirm your appointment.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF333333), // Dark gray text color
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFFFA726), // Orange button text color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

    } catch (e) {
      print('Error creating waiting appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F7F1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              'Vehicle Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Please enter your vehicle registration and chassis details.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _registrationController,
              decoration: InputDecoration(
                labelText: 'Vehicle Registration No.',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _validateForm(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _chassisController,
              decoration: InputDecoration(
                labelText: 'Vehicle Chassis No.',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _validateForm(),
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 200, // Standard button width
                height: 50, // Standard button height
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () async {
                    await _saveVehicleDetails();
                    _makeAppointment(); // Make appointment logic
                  }
                      : null, // Disable button if form is not valid
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF46C2AF), // White text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(500.0), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Make Appointment',
                    style: TextStyle(
                      fontSize: 16, // Font size for readability
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
