import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subscreens/select_vehicle.dart';

class ReserveYourSpotB extends StatelessWidget {
  Future<void> logSelectedVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedVehicle');
    await prefs.remove('selectedPackage');
    await prefs.remove('estimatedQueueTime');
    await prefs.remove('selectedQueueNumber');
    await prefs.remove('vehicle_registration');
    await prefs.remove('vehicle_chassis');
  }

  // Method to check if the user has already booked a reservation
  Future<bool> checkReservationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      // Fetch all appointments for the user
      QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('uid', isEqualTo: uid)
          .get();

      // Check if the user has any active or waiting appointment
      for (var doc in appointmentSnapshot.docs) {
        String appointmentId = doc['appointmentId'];

        // Check queue collection for this appointmentId
        QuerySnapshot queueSnapshot = await FirebaseFirestore.instance
            .collection('queue')
            .where('appointmentId', isEqualTo: appointmentId)
            .where('status', whereIn: ['waiting', 'servicing'])
            .get();

        if (queueSnapshot.docs.isNotEmpty) {
          return true; // Reservation already booked
        }
      }
    }
    return false; // No reservation found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkReservationStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Reserve Spot B'),
              backgroundColor: Color(0xFF34A0A4),
            ),
            body: Center(child: CircularProgressIndicator()), // Show loading indicator
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Reservation Already Booked'),
              backgroundColor: Color(0xFF34A0A4),
            ),
            body: Center(
              child: AlertDialog(
                title: Text('Reservation Already Booked'),
                content: Text(
                    'You have already booked a reservation. Please check your appointment details or try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          );
        }

        // Continue with the regular screen if no reservation is found
        logSelectedVehicle(); // Log the selected vehicle when the screen loads

        return Scaffold(
          appBar: AppBar(
            title: Text('Reserve Spot B'),
            backgroundColor: Color(0xFF34A0A4),
          ),
          body: SelectVehicle(),
        );
      },
    );
  }
}
