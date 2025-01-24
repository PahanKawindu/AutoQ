import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/select_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReserveYourSpotA extends StatefulWidget {
  final Map<String, dynamic> serviceDetails;

  const ReserveYourSpotA({Key? key, required this.serviceDetails}) : super(key: key);

  @override
  _ReserveYourSpotAState createState() => _ReserveYourSpotAState();
}

class _ReserveYourSpotAState extends State<ReserveYourSpotA> {
  bool isAlreadyBooked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkReservationStatus();
  }

  Future<void> checkReservationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      await Future.delayed(Duration(seconds: 3));
      QuerySnapshot appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('uid', isEqualTo: uid)
          .get();

      for (var doc in appointmentSnapshot.docs) {
        String appointmentId = doc['appointmentId'];
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

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveDataAndPrepareForSelectDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVehicle', widget.serviceDetails['VehicleType']);
    await prefs.setInt('selectedPackage', widget.serviceDetails['ServceID']);
  }

  Future<void> removeSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedVehicle');
    await prefs.remove('selectedPackage');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await removeSavedData();
        return true;
      },
      child: Scaffold(
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : isAlreadyBooked
            ? _buildStyledAlertDialog(context)
            : SelectDate(),
      ),
    );
  }

  Widget _buildStyledAlertDialog(BuildContext context) {
    return Center(
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.red, width: 1.5),
        ),
        backgroundColor: Colors.pink.shade50,
        title: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48.0,
            ),
            SizedBox(height: 8.0),
            Text(
              'Reservation Already Booked',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        content: Text(
          'You have already booked a reservation. Please check your appointment details or try again later.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.0),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}