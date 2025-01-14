import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'select_packge.dart';

class SelectVehicle extends StatelessWidget {
  final List<Map<String, String>> vehicles = [
    {
      'name': 'Car',
      'image': 'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'
    },
    {
      'name': 'Bike',
      'image': 'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'
    },
    {
      'name': 'Truck',
      'image': 'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'
    },
    {
      'name': 'Bus',
      'image': 'https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI'
    },
  ];

  Future<void> saveSelectedVehicle(String vehicle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVehicle', vehicle);
    String? selectedVehicle = prefs.getString('selectedVehicle');
    //print('Selected Vehicle: $selectedVehicle');
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
                  fontSize: 28,
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
                            Image.network(
                              vehicles[index]['image']!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 8),
                            Text(
                              vehicles[index]['name']!,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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