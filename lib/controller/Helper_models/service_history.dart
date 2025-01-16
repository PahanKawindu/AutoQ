import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceHistory {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getUserServiceHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('uid');

    if (userId == null) {
      throw Exception("User ID not found in shared preferences");
    }

    // Step 1: Fetch all appointment IDs for the given user ID
    final QuerySnapshot<Map<String, dynamic>> historySnapshot = await _firestore
        .collection('service-history')
        .where('uid', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();

    List<String> appointmentIds = historySnapshot.docs
        .map((doc) => doc.data()['appointmentId'] as String)
        .toList();

    if (appointmentIds.isEmpty) return [];

    // Step 2: Fetch appointment details and service details
    List<Map<String, dynamic>> serviceHistory = [];

    for (String appointmentId in appointmentIds) {
      // Fetch appointment details
      final QuerySnapshot<Map<String, dynamic>> appointmentSnapshot = await _firestore
          .collection('appointments')
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      if (appointmentSnapshot.docs.isEmpty) continue;

      final appointmentData = appointmentSnapshot.docs.first.data();

      // Fetch service details
      final QuerySnapshot<Map<String, dynamic>> serviceSnapshot = await _firestore
          .collection('AutoQ_service')
          .where('ServceID', isEqualTo: appointmentData['serviceId'])
          .get();

      if (serviceSnapshot.docs.isEmpty) continue;

      final serviceData = serviceSnapshot.docs.first.data();

      // Combine data
      serviceHistory.add({
        'appointmentDate': appointmentData['appointmentDate'],
        'servicePackageName': serviceData['ServicePackgeName'],
        'price': serviceData['Price'],
        'vehicleType': serviceData['VehicleType'],
        'vehicleRegNo': appointmentData['vehicleRegNo'],
      });
    }

    return serviceHistory;
  }
}
