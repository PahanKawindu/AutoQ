import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/controller/Helper_models/appointment_limits.dart';
import 'package:test_flutter1/controller/Helper_models/appointments.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:table_calendar/table_calendar.dart';

import 'vehical_details.dart';

class SelectDate extends StatefulWidget {
  @override
  _SelectDateState createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  final AppointmentLimitsService _appointmentLimitsService =
  AppointmentLimitsService();
  final AppointmentsService _appointmentsService = AppointmentsService();
  final QueueService _queueService = QueueService();

  DateTime _selectedDate = DateTime.now();
  int? _appointmentLimit;
  int? _appointmentsCount;
  int? _nextQueueNumber;
  String? _estimatedQueueTime;
  bool _isAppointmentAvailable = true;

  // Fetch the appointment limit for the selected date
  Future<void> _fetchAndLogLimit() async {
    int limit = await _appointmentLimitsService.getAppointmentLimit(_selectedDate);
    setState(() {
      _appointmentLimit = limit;
    });
  }

  // Fetch the number of appointments already booked for the selected date
  Future<void> _fetchAndLogAppointmentsCount() async {
    int appointmentsCount =
    await _appointmentsService.getAppointmentsCount(_selectedDate);
    setState(() {
      _appointmentsCount = appointmentsCount;

      // Check if the appointment count is less than the limit, or if the limit is 0
      if (_appointmentLimit == 0 || _appointmentsCount != _appointmentLimit) {
        _isAppointmentAvailable = true;
      } else {
        _isAppointmentAvailable = false;
      }
    });
  }

  // Fetch the next queue number and the estimated queue time for the selected date
  Future<void> _fetchAndLogNextQueueAndTime() async {
    var result = await _queueService.getNextQueueAndTime(_selectedDate);
    setState(() {
      _nextQueueNumber = result['nextQueueNumber'];
      _estimatedQueueTime = result['estimatedQueueTime'];
    });
  }

  // Save selected date, next queue number, and estimated queue time to shared preferences
  Future<void> _saveSelectedDateAndQueueDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'selectedDate', DateFormat('yyyy-MM-dd').format(_selectedDate));
    if (_nextQueueNumber != null) {
      prefs.setInt('selectedQueueNumber', _nextQueueNumber!);
    }
    if (_estimatedQueueTime != null) {
      prefs.setString('estimatedQueueTime', _estimatedQueueTime!);
    }
  }

  // Remove selected date, queue number, and estimated queue time from shared preferences
  Future<void> _removeSelectedDateAndQueueDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('selectedDate');
    prefs.remove('selectedQueueNumber');
    prefs.remove('estimatedQueueTime');
  }

  @override
  void dispose() {
    _removeSelectedDateAndQueueDetails();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAndLogLimit();
    _fetchAndLogAppointmentsCount();
    _fetchAndLogNextQueueAndTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 24, // Increased font size
                fontWeight: FontWeight.bold, // Bold for emphasis
              ),
            ),
            SizedBox(height: 20),
            TableCalendar(
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _fetchAndLogLimit();
                _fetchAndLogAppointmentsCount();
                _fetchAndLogNextQueueAndTime();
              },
              firstDay: DateTime(2025),
              lastDay: DateTime(2030),
            ),
            SizedBox(height: 20),
            if (_isAppointmentAvailable) ...[
              if (_nextQueueNumber != null && _estimatedQueueTime != null) ...[
                Text(
                  'Next Queue Number: $_nextQueueNumber',
                  style: TextStyle(
                    fontSize: 18, // Increased font size
                    fontWeight: FontWeight.w500, // Medium weight
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Estimated Queue Time: $_estimatedQueueTime',
                  style: TextStyle(
                    fontSize: 14, // Increased font size
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'Appointments for this date are already reserved.',
                style: TextStyle(
                  fontSize: 16, // Slightly smaller but readable
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAppointmentAvailable
                  ? () async {
                await _saveSelectedDateAndQueueDetails();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VehicleDetails()),
                );
              }
                  : null, // Disable button if no appointments are available
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 16), // Larger button text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
