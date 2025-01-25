import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar package

class SetReservationLimitationAdmin extends StatefulWidget {
  @override
  _SetReservationLimitationAdminState createState() => _SetReservationLimitationAdminState();
}

class _SetReservationLimitationAdminState extends State<SetReservationLimitationAdmin> {
  DateTime? selectedDate;
  final TextEditingController limitController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  // Firestore collection reference
  final CollectionReference appointmentLimits = FirebaseFirestore.instance.collection('appointment_limits');

  // List of dates with existing limitations
  List<DateTime> limitedDates = [];

  @override
  void initState() {
    super.initState();
    _loadExistingLimits();
  }

  // Function to load existing limitation dates from Firestore
  Future<void> _loadExistingLimits() async {
    try {
      final snapshot = await appointmentLimits.get();
      final List<DateTime> fetchedDates = [];

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date'];
        DateTime date = timestamp.toDate();
        fetchedDates.add(DateTime(date.year, date.month, date.day)); // Store only the date part
      }

      setState(() {
        limitedDates = fetchedDates;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load existing dates.';
      });
    }
  }

  @override
  void dispose() {
    limitController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5F7F1),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading Section
            Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Ensure both texts are left-aligned
                children: [
                  Text(
                    'Set Reservation Limitation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage reservation capacities with ease.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24), // Spacing between the heading and calendar

            // Calendar
            TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 365)),
              onDaySelected: (selectedDay, focusedDay) {
                if (selectedDay.isAfter(DateTime.now())) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                } else {
                  setState(() {
                    errorMessage = 'You cannot select today or past dates.';
                    selectedDate = null;
                  });
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDate, day);
              },
              onPageChanged: (focusedDay) {},
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (limitedDates.contains(DateTime(date.year, date.month, date.day))) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        width: 9,
                        height: 9,
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            SizedBox(height: 20),

            if (limitedDates.isNotEmpty) ...[
              Text(
                'Dates with red circles indicate reservation limitations are set.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
            ],
            if (selectedDate != null) ...[
              TextField(
                controller: limitController,
                decoration: InputDecoration(labelText: 'Enter limit number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: 'Enter reason'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveLimitation,
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF46C2AF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              if (errorMessage != null) ...[
                SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Save the limitation data in Firestore
  Future<void> _saveLimitation() async {
    final String limitText = limitController.text;
    final String reasonText = reasonController.text;

    if (limitText.isEmpty || reasonText.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    final int? limit = int.tryParse(limitText);
    if (limit == null || limit <= 0) {
      setState(() {
        errorMessage = 'Please enter a valid limit number.';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final timestamp = Timestamp.fromDate(selectedDate!);

      await appointmentLimits.add({
        'date': timestamp,
        'limit': limit,
        'message': reasonText,
      });

      setState(() {
        limitedDates.add(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day));
        isLoading = false;
        selectedDate = null;
        limitController.clear();
        reasonController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF46C2AF),
              ),
              SizedBox(width: 8),
              Text(
                'Success',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Reservation limit set successfully!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF46C2AF),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to save data. Please try again.';
      });
    }
  }
}
