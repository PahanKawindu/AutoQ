import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/controller/Helper_models/appointments.dart';

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
        title: Text('Make Appointment'),
        backgroundColor: Color(0xFF34A0A4),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Appointment Success!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        SizedBox(height: 20),
        Text(
          'Details:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('Vehicle: ${_appointmentDetails!['vehicleType']}'),
        Text('Registration: ${_appointmentDetails!['vehicleRegNo']}'),
        Text('Date: ${_appointmentDetails!['appointmentDate']}'),
        Text('Queue No: ${_appointmentDetails!['positionNo']}'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            //Navigator.of(context).pushReplacementNamed('/home');
          },
          child: Text('Home'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF34A0A4)),
        ),
      ],
    );
  }
}
