import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart'; // For formatting dates

class ViewReservationAdmin extends StatefulWidget {
  @override
  _ViewReservationAdminState createState() => _ViewReservationAdminState();
}

class _ViewReservationAdminState extends State<ViewReservationAdmin> {
  final QueueService _queueService = QueueService();
  Map<String, List<Map<String, dynamic>>> _groupedReservations = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      List<Map<String, dynamic>> reservations = await _queueService.getAllReservations();

      // Group reservations by appointmentDate
      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var reservation in reservations) {
        String dateKey = DateFormat('yyyy-MM-dd').format(reservation['appointmentDate'].toDate());
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]?.add(reservation);
      }

      setState(() {
        _groupedReservations = grouped;
        _isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Reservation'),
        backgroundColor: const Color(0xFF46C2AF),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groupedReservations.isEmpty
          ? Center(child: Text('No Reservations Found'))
          : ListView.builder(
        itemCount: _groupedReservations.keys.length,
        itemBuilder: (context, index) {
          String date = _groupedReservations.keys.elementAt(index);
          List<Map<String, dynamic>> reservations = _groupedReservations[date] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date Header
              Container(
                padding: EdgeInsets.all(10),
                color: Colors.grey[200],
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  'Date: $date',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Centered Cards for Reservations
              ...reservations.map((reservation) {
                // Determine card color based on status
                Color cardColor;
                if (reservation['status'] == 'completed') {
                  cardColor = Colors.green[100]!;
                } else if (reservation['status'] == 'canceled') {
                  cardColor = Colors.red[100]!;
                } else {
                  cardColor = Colors.white;
                }

                return Card(
                  color: cardColor,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${reservation['first_name']} ${reservation['last_name']}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        Text('Email: ${reservation['email']}'),
                        SizedBox(height: 5),
                        Text('Contact: ${reservation['contact_no']}'),
                        SizedBox(height: 5),
                        Text('Appointment Date: ${reservation['appointmentDate'].toDate()}'),
                        SizedBox(height: 5),
                        Text('Vehicle Type: ${reservation['vehicleType']}'),
                        SizedBox(height: 5),
                        Text('Vehicle Reg No: ${reservation['vehicleRegNo']}'),
                        SizedBox(height: 5),
                        Text('Chassis No: ${reservation['ChassisNo']}'),
                        SizedBox(height: 5),
                        Text('Service: ${reservation['ServicePackgeName']}'),
                        SizedBox(height: 5),
                        Text(
                          'Status: ${reservation['status']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
