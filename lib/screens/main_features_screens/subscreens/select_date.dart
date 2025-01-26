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
  final AppointmentLimitsService _appointmentLimitsService = AppointmentLimitsService();
  final AppointmentsService _appointmentsService = AppointmentsService();
  final QueueService _queueService = QueueService();

  DateTime _selectedDate = DateTime.now();
  int? _appointmentLimit;
  int? _appointmentsCount;
  int? _nextQueueNumber;
  String? _estimatedQueueTime;
  bool _isAppointmentAvailable = true;

  Future<void> _fetchAndLogLimit() async {
    int limit = await _appointmentLimitsService.getAppointmentLimit(_selectedDate);
    setState(() {
      _appointmentLimit = limit;
    });
  }

  Future<void> _fetchAndLogAppointmentsCount() async {
    int appointmentsCount = await _appointmentsService.getAppointmentsCount(_selectedDate);
    setState(() {
      _appointmentsCount = appointmentsCount;

      if (_appointmentLimit == 0 || _appointmentsCount != _appointmentLimit) {
        _isAppointmentAvailable = true;
      } else {
        _isAppointmentAvailable = false;
      }
    });
  }

  Future<void> _fetchAndLogNextQueueAndTime() async {
    var result = await _queueService.getNextQueueAndTime(_selectedDate);
    setState(() {
      _nextQueueNumber = result['nextQueueNumber'];
      _estimatedQueueTime = result['estimatedQueueTime'];
    });
  }

  Future<void> _saveSelectedDateAndQueueDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDate', DateFormat('yyyy-MM-dd').format(_selectedDate));
    if (_nextQueueNumber != null) {
      prefs.setInt('selectedQueueNumber', _nextQueueNumber!);
    }
    if (_estimatedQueueTime != null) {
      prefs.setString('estimatedQueueTime', _estimatedQueueTime!);
    }
  }

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
        backgroundColor: Color(0xFFE5F7F1),
      ),
      body: Container(
        color: Colors.white, // Set body background color to white
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date for Service',
                      style: TextStyle(
                        fontSize: 20, // Font size for main title
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Choose an available date for your service appointment.',
                      style: TextStyle(
                        fontSize: 16, // Font size for subtitle
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // Calendar
              TableCalendar(
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                    _fetchAndLogLimit();
                    _fetchAndLogAppointmentsCount();
                    _fetchAndLogNextQueueAndTime();
                  }
                },
                firstDay: DateTime.now(),
                lastDay: DateTime(2030),
                enabledDayPredicate: (day) {
                  return day.isAfter(DateTime.now().subtract(Duration(days: 1)));
                },
              ),
              SizedBox(height: 20),
              // Appointment Availability
              if (_isAppointmentAvailable) ...[
                if (_nextQueueNumber != null && _estimatedQueueTime != null) ...[
                  Center(
                    child: Text(
                      'Next Queue Number: $_nextQueueNumber',
                      style: TextStyle(
                        fontSize: 18, // Increased font size
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.blue, // Highlight color
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Estimated Queue Time: $_estimatedQueueTime',
                      style: TextStyle(
                        fontSize: 16, // Adjusted font size
                        color: Colors.black87, // Regular color for contrast
                      ),
                    ),
                  ),
                ],
              ]
              else ...[
                Text(
                  'Appointments for this date are already reserved.',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
              Spacer(),
              // Continue Button
              SizedBox(
                width: double.infinity, // Standard full-width button
                height: 50, // Standard button height
                child: ElevatedButton(
                  onPressed: _isAppointmentAvailable
                      ? () async {
                    await _saveSelectedDateAndQueueDetails();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VehicleDetails()),
                    );
                  }
                      : null, // Disable button if no appointments are available
                  child: Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
