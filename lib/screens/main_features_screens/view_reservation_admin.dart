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
        backgroundColor: Color(0xFFE5F7F1),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _groupedReservations.isEmpty
          ? Center(child: Text('No Reservations Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reservation Overview.',
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              'Manage and view all the customer reservations efficiently.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 20),
            // Reservations list
            ..._groupedReservations.keys.map((date) {
              List<Map<String, dynamic>> reservations = _groupedReservations[date] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Header
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      'Date: $date',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Reservations
                  ...reservations.map((reservation) {
                    // Determine card color based on status
                    Color cardColor;
                    IconData statusIcon;
                    if (reservation['status'] == 'completed') {
                      cardColor = Colors.green[50]!;
                      statusIcon = Icons.check_circle_outline;
                    } else if (reservation['status'] == 'canceled') {
                      cardColor = Colors.red[50]!;
                      statusIcon = Icons.cancel_outlined;
                    } else {
                      cardColor = Colors.white;
                      statusIcon = Icons.access_time_outlined;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Card(
                        color: cardColor,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: Colors.black54,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status Icon and Name
                              Row(
                                children: [
                                  Icon(statusIcon, color: Color(0xFFFFD700), size: 30),
                                  SizedBox(width: 12),
                                  Text(
                                    '${reservation['first_name']} ${reservation['last_name']}',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Reservation Details
                              Row(
                                children: [
                                  Icon(Icons.email_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${reservation['email']}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    '${reservation['contact_no']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_alarm_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Appointment: ${DateFormat('yyyy-MM-dd HH:mm').format(reservation['appointmentDate'].toDate())}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.directions_car_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Vehicle Type: ${reservation['vehicleType']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.car_repair_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Reg No: ${reservation['vehicleRegNo']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chassis No: ${reservation['ChassisNo']}',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Status
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                                  SizedBox(width: 8),
                                  Text(
                                    'Status: ${reservation['status']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
