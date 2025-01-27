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
    try {
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
    } catch (e) {
      print("Error checking reservation status: $e");
      return false; // Return false in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkReservationStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFE5F7F1),
            ),
            body: Center(child: CircularProgressIndicator()), // Show loading indicator
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Color(0xFFE5F7F1),
            ),
            body: Center(
              child: Text('An error occurred while checking your reservation. Please try again later.'),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFE5F7F1),
            ),
            body: Center(
              child: _buildReservationAlreadyBookedDialog(context),
            ),
          );
        }

        // Continue with the regular screen if no reservation is found
        logSelectedVehicle(); // Log the selected vehicle when the screen loads

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFE5F7F1),
          ),
          body: SelectVehicle(),
        );
      },
    );
  }

  Widget _buildReservationAlreadyBookedDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Color(0xFFFFEBEE), // Light red background for alert
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFEBEE), // Background color
          border: Border.all(
            color: Colors.redAccent, // Thin red border
            width: 1.5, // Border thickness
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(20), // Adjust padding for a compact layout
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with enhanced style
              Icon(
                Icons.warning_amber_rounded,
                size: 40, // Slightly smaller icon size
                color: Colors.redAccent, // Highlighted red icon for notice
              ),
              SizedBox(height: 15),
              // Title with bold and prominent text
              Text(
                'Reservation Already Booked',
                style: TextStyle(
                  fontSize: 18, // Smaller font size
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 8),
              // Subtitle styled for clarity
              Text(
                'You have already booked a reservation. Please check your appointment details or try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, // Smaller font size
                  color: Colors.black87,
                  height: 1.4, // Slightly reduced line height
                ),
              ),
              SizedBox(height: 25),
              // OK button with modern styling
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Red button background
                  foregroundColor: Colors.white, // White text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), // Adjust padding for compactness
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 14, // Smaller font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
