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
          title: Text('Select Package'),
          backgroundColor: Color(0xFF46C2AF),
        ),
        body: selectedVehicle == null
            ? Center(child: Text('No vehicle selected'))
            : packages.isEmpty
            ? Center(child: Text('No packages available for the selected vehicle', style: TextStyle(fontSize: 16, color: Colors.red)))
            : ListView.builder(
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
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 12,
                shadowColor: Colors.black.withOpacity(0.3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orangeAccent.withOpacity(0.8),
                          Colors.pinkAccent.withOpacity(0.6),
                          Colors.purple.withOpacity(0.4),
                          Colors.blue.withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package['ServicePackgeName'] ?? 'Package Name',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Approx Time: ${package['ApproxServiceTime'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Price: ${package['Price']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                package['ServiceImage'] ?? 'https://placehold.co/100x100.png',
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
