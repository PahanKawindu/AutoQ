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

  // Create a TableCalendar controller
  late final ValueNotifier<List<DateTime>> _selectedEvents;

  // List of dates with existing limitations
  List<DateTime> limitedDates = [];

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
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
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Reservation Limit'),
        backgroundColor: const Color(0xFF46C2AF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calendar directly displayed
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
                  // If the user selects today or a past date
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
                  // Highlight days with existing limitations
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

            // Description below the calendar
            if (limitedDates.isNotEmpty) ...[
              Text(
                'Dates with red circles indicate reservation limitations are set.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent, // Light red color
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center, // Center the text
              ),
              SizedBox(height: 10),
            ],

            // Display limit and reason input fields after selecting a valid date
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
              ElevatedButton(
                onPressed: _saveLimitation,
                child: Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF46C2AF),
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

      // Convert selected date to timestamp
      final timestamp = Timestamp.fromDate(selectedDate!);

      // Check if a limitation already exists for the selected date
      final existingDoc = await appointmentLimits.doc(timestamp.toDate().toString()).get();

      if (existingDoc.exists) {
        // If the document exists, update it
        await appointmentLimits.doc(existingDoc.id).update({
          'limit': limit,
          'message': reasonText,
        });
      } else {
        // If no document exists, create a new one
        await appointmentLimits.add({
          'date': timestamp,
          'limit': limit,
          'message': reasonText,
        });
      }

      // Add the date to the list of limited dates to highlight it
      setState(() {
        limitedDates.add(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day));
        isLoading = false;
      });

      // Show success message and refresh the screen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Reservation limit set successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDate = null;
                  limitController.clear();
                  reasonController.clear();
                });
                Navigator.of(context).pop();
              },
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
