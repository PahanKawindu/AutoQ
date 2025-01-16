import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/screens/main_features_screens/subscreens/select_date.dart';

class ReserveYourSpotA extends StatefulWidget {
  final Map<String, dynamic> serviceDetails;

  const ReserveYourSpotA({Key? key, required this.serviceDetails})
      : super(key: key);

  @override
  _ReserveYourSpotAState createState() => _ReserveYourSpotAState();
}

class _ReserveYourSpotAState extends State<ReserveYourSpotA> {
  @override
  void initState() {
    super.initState();
    saveDataAndPrepareForSelectDate();
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
      child: SelectDate(),
    );
  }
}
