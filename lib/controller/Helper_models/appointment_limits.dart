import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentLimitsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the appointment limit for a given date.
  Future<int> getAppointmentLimit(DateTime date) async {
    try {
      // Normalize the date to only compare the year, month, and day (ignoring time).
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);

      // Query Firestore to match the date (no time information)
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointment_limits')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('date', isLessThan: Timestamp.fromDate(normalizedDate.add(Duration(days: 1))))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming there is only one document for each date
        return querySnapshot.docs.first['limit'] ?? 0;
      } else {
        //print('No document found for the given date.');
        return 0;
      }
    } catch (e) {
      print('Error fetching appointment limit: $e');
      return 0;
    }
  }
}
