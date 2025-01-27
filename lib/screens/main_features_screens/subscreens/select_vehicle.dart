import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this for SVG support
import 'package:shared_preferences/shared_preferences.dart';

import 'select_packge.dart';

class SelectVehicle extends StatelessWidget {
  final List<Map<String, String>> vehicles = [
    {'name': 'Car', 'image': 'assets/images/car.png'},
    {'name': 'Bike', 'image': 'assets/images/bike.png'},
    {'name': 'Truck', 'image': 'assets/images/lorry.png'},
    {'name': 'Bus', 'image': 'assets/images/bus.png'},
  ];

  final List<Color> vehicleColors = [
    Color(0xFF46C2AF),  // Color for Car (Electric Blue)
    Color(0xFF46C2AF),  // Color for Bike (Vibrant Purple)
    Color(0xFF46C2AF),  // Color for Truck (Forest Green)
    Color(0xFF46C2AF), // Color for Bus
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
        backgroundColor: Colors.white, // Subtle background color
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                SizedBox(height: 10),
                // Packages Section Title
                Text(
                  'Select your vehicle type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Choose a vehicle to proceed with booking.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 20),
                // Vehicle Cards
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          await saveSelectedVehicle(vehicles[index]['name']!);
                          navigateToNextScreen(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: vehicleColors[index], // Use different colors for each card
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6.0,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Vehicle Icon
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: vehicles[index]['image']!.endsWith('.svg')
                                    ? SvgPicture.asset(
                                  vehicles[index]['image']!,
                                  height: 60,
                                  width: 60,
                                )
                                    : Image.asset(
                                  vehicles[index]['image']!,
                                  height: 60,
                                  width: 60,
                                ),
                              ),
                              // Vehicle Name
                              Text(
                                vehicles[index]['name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white, // White text for contrast
                                ),
                              ),
                              // Subtext (Optional)
                              SizedBox(height: 4),
                              Text(
                                'Tap to select',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70, // Lighter text for subtext
                                ),
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
      ),
    );
  }
}
