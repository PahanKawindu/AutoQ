import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_date.dart';

class SelectPackage extends StatefulWidget {
  @override
  _SelectPackageState createState() => _SelectPackageState();
}

class _SelectPackageState extends State<SelectPackage> {
  String? selectedVehicle;
  List<Map<String, dynamic>> packages = [];

  @override
  void initState() {
    super.initState();
    fetchSelectedVehicle();
  }

  Future<void> fetchSelectedVehicle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedVehicle = prefs.getString('selectedVehicle');
    if (selectedVehicle != null) {
      await fetchPackagesForVehicle(selectedVehicle!);
    }
  }

  Future<void> fetchPackagesForVehicle(String vehicleType) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('AutoQ_service')
        .where('VehicleType', isEqualTo: vehicleType)
        .get();

    setState(() {
      packages = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> savePackageId(int packageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedPackage', packageId);
    int? selectedPackage = prefs.getInt('selectedPackage');
    //print('Selected Package: $selectedPackage');
  }

  Future<void> removePackageId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedPackage');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await removePackageId();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFE5F7F1),
        ),
        body: Container(
          color: Colors.white, // Set body background color to white
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title
                    Text(
                      'Select your service package',
                      style: TextStyle(
                        fontSize: 20, // Font size adjusted to match your requested style
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Subtitle (Slogan)
                    Text(
                      'Choose a service package to proceed with your booking.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              // Check if vehicle is selected
              if (selectedVehicle == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'No vehicle selected',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                )
              else if (packages.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No packages available for the selected vehicle',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                )
              else
              // Package Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return GestureDetector(
                        onTap: () async {
                          await savePackageId(package['ServceID']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectDate(),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          color: Color(0xFF34A0A4),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        package['ServicePackgeName'] ??
                                            'Package Name',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Approx Time: ${package['ApproxServiceTime'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Price: ${package['Price']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Image.network(
                                    package['ServiceImage'] ??
                                        'https://placehold.co/100x100.png',
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
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
