import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this for SVG support
import 'package:shared_preferences/shared_preferences.dart';

import 'select_packge.dart';

class SelectVehicle extends StatelessWidget {
  final List<Map<String, String>> vehicles = [
    {
      'name': 'Car',
      'image': 'assets/images/car.png', // SVG file
    },
    {
      'name': 'Bike',
      'image': 'assets/images/bike.png', // PNG file
    },
    {
      'name': 'Truck',
      'image': 'assets/images/lorry.png', // PNG file
    },
    {
      'name': 'Bus',
      'image': 'assets/images/bus.png', // PNG file
    },
  ];

  Future<void> saveSelectedVehicle(String vehicle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVehicle', vehicle);
  }

  Future<void> removeSelectedVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedVehicle');
  }

  void navigateToNextScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectPackage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await removeSelectedVehicle();
        return true; // Allow the back navigation
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Vehicle Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await saveSelectedVehicle(vehicles[index]['name']!);
                        navigateToNextScreen(context);
                      },
                      child: Card(
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            vehicles[index]['image']!.endsWith('.svg')
                                ? SvgPicture.asset(
                              vehicles[index]['image']!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              vehicles[index]['image']!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 8),
                            Text(
                              vehicles[index]['name']!,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}