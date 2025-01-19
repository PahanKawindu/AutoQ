import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/select_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReserveYourSpotA extends StatefulWidget {
  final Map<String, dynamic> serviceDetails;

  const ReserveYourSpotA({Key? key, required this.serviceDetails})
      : super(key: key);

  @override
  _ReserveYourSpotAState createState() => _ReserveYourSpotAState();
}

class _ReserveYourSpotAState extends State<ReserveYourSpotA> {
  bool isAlreadyBooked = false;
  bool isLoading = true; // Flag to indicate loading status

  @override
  void initState() {
    super.initState();
    checkReservationStatus();
  }

  // Method to check if the user has already booked a reservation
  Future<void> checkReservationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      // Simulating a wait time before checking the status
      await Future.delayed(Duration(seconds: 3));

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
          setState(() {
            isAlreadyBooked = true;
          });
          break;
        }
      }
    }

    // Set the loading flag to false after the operation completes
    setState(() {
      isLoading = false;
    });
  }

  // Method to save data to SharedPreferences
  Future<void> saveDataAndPrepareForSelectDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVehicle', widget.serviceDetails['VehicleType']);
    await prefs.setInt('selectedPackage', widget.serviceDetails['ServceID']);

    // Triggering the state update to display SelectDate content
    setState(() {});
  }

  // Method to remove saved data from SharedPreferences
  Future<void> removeSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedVehicle');
    await prefs.remove('selectedPackage');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Remove saved data when back button is pressed
        await removeSavedData();
        return true; // Allow the back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reserve Your Spot'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator
            : isAlreadyBooked
            ? Center(
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
        )
            : SelectDate(),
      ),
    );
  }
}
