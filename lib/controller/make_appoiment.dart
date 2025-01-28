import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/controller/Helper_models/appointments.dart';

import '../screens/home_screen_user_main.dart';

class MakeAppointment extends StatefulWidget {
  @override
  _MakeAppointmentState createState() => _MakeAppointmentState();
}

class _MakeAppointmentState extends State<MakeAppointment> {
  final AppointmentsService _appointmentsService = AppointmentsService();
  bool _isLoading = true;
  Map<String, dynamic>? _appointmentDetails;

  @override
  void initState() {
    super.initState();
    _processAppointment();
  }

  Future<void> _processAppointment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? uid = prefs.getString('uid');
    String? selectedVehicle = prefs.getString('selectedVehicle');
    int? selectedPackage = prefs.getInt('selectedPackage');
    String? selectedDate = prefs.getString('estimatedQueueTime');
    int selectedQueueNumber = prefs.getInt('selectedQueueNumber') ?? 0;
    String? vehicleRegistration = prefs.getString('vehicle_registration');
    String? chassisNo = prefs.getString('vehicle_chassis');

    if (uid != null && selectedDate != null) {
      DateTime appointmentDate = DateTime.parse(selectedDate);

      bool isApproved = await _appointmentsService.approveWaitingAppointment(
        uid,
        selectedQueueNumber,
        appointmentDate,
      );

      if (isApproved) {
        Map<String, dynamic> appointmentData = {
          'ChassisNo': chassisNo,
          'appointmentDate': appointmentDate,
          'appointmentStatus': 'active',
          'serviceId': selectedPackage,
          'uid': uid,
          'vehicleRegNo': vehicleRegistration,
          'vehicleType': selectedVehicle,
          'positionNo': selectedQueueNumber,
        };

        bool isAdded = await _appointmentsService.addAppointment(appointmentData);

        if (isAdded) {
          Map<String, dynamic> queueData = {
            'appointmentId': appointmentData['appointmentId'], // Use the generated ID
            'positionNo': selectedQueueNumber,
            'queueTime': appointmentDate,
            'status': 'waiting',
          };

          bool isQueueAdded = await _appointmentsService.addToQueue(queueData);

          if (isQueueAdded) {
            setState(() {
              _appointmentDetails = {
                ...appointmentData,
                'queueTime': appointmentDate,
                'status': 'waiting',
              };
              _isLoading = false;
            });
          } else {
            _showError('Failed to add to queue. Please try again.');
          }
        } else {
          _showError('Failed to add appointment. Please try again.');
        }
      } else {
        _showError('Failed to approve appointment. Please try again.');
      }
    } else {
      _showError('Invalid appointment details. Please try again.');
    }
  }

  void _showError(String message) {
    setState(() {
      _isLoading = false;
      _appointmentDetails = {'error': message};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F7F1),
        elevation: 0, // Removing shadow for cleaner look
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _appointmentDetails != null
            ? _appointmentDetails!.containsKey('error')
            ? Text(
          _appointmentDetails!['error'],
          style: TextStyle(fontSize: 18, color: Colors.red),
        )
            : _buildAppointmentSuccess()
            : Text(
          'No appointment details available.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildAppointmentSuccess() {
    return Center(
      child: Card(
        elevation: 5, // Subtle shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Rounded corners for a soft look
          side: BorderSide(
            color: Color(0xFF34A0A4), // Thin green border
            width: 1, // Thin border
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 40), // Adjusted for better balance
        color: Color(0xFFE5E5E5), // Light green background
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Centered icon
              Icon(
                Icons.check_circle_outline,
                color: Colors.green, // Green icon
                size: 60, // Larger size for prominence
              ),
              SizedBox(height: 20),

              // Appointment success title
              Text(
                'Appointment Success!',
                style: TextStyle(
                  fontSize: 26, // Larger font size for prominence
                  fontWeight: FontWeight.bold,
                  color: Colors.green, // Green text for the title
                ),
              ),
              SizedBox(height: 20),

              // Details header
              Text(
                'Appointment Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Soft black for readability
                ),
              ),
              SizedBox(height: 10),

              // Appointment details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vehicle: ${_appointmentDetails!['vehicleType']}',
                        style: TextStyle(color: Colors.black54, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Registration: ${_appointmentDetails!['vehicleRegNo']}',
                        style: TextStyle(color: Colors.black54, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Date: ${_appointmentDetails!['appointmentDate']}',
                        style: TextStyle(color: Colors.black54, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Queue No: ${_appointmentDetails!['positionNo']}',
                        style: TextStyle(color: Colors.black54, fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Home button with theme green color and white text
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreenUser(), // Navigate to HomeScreen
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  child: Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF34A0A4), // Use theme green for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Rounded button corners
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




}
