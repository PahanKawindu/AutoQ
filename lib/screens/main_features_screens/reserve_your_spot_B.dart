import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    logSelectedVehicle(); // Log the selected vehicle when the screen loads

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Spot B'),
        backgroundColor: Color(0xFF46C2AF),
      ),
      body: SelectVehicle(),
    );
  }
}
