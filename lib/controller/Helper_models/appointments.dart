import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the number of appointments booked for a given date.
  Future<int> getAppointmentsCount(DateTime date) async {
    try {
      // Normalize the date to only compare the year, month, and day (ignoring time).
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      // Query Firestore to count appointments for the given date (ignoring time information)
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(normalizedDate.add(Duration(days: 1))))
          .get();

      // Return the count of documents found
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching appointments count: $e');
      return 0;
    }
  }
  // New method to check if there's an approved appointment for the selected date and position number
  Future<bool> checkApprovedAppointment(DateTime selectedDate, int positionNo) async {
    try {
      // Normalize the selectedDate to the start of the day (00:00:00)
      DateTime normalizedSelectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      // Convert the Firestore timestamp to DateTime (ignoring the time)
      QuerySnapshot querySnapshot = await _firestore
          .collection('waiting_appointments')
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedSelectedDate))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(normalizedSelectedDate.add(Duration(days: 1)))) // the next day to ensure we get the whole day
          .where('positionNo', isEqualTo: positionNo)
          .where('Status', isEqualTo: 'approved') // Checking for approved status
          .get();

      // Return true if any matching documents are found (approved appointment exists)
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking approved appointment: $e');
      return false;
    }
  }

  /// Approves a waiting appointment if data matches and updates its status to "approved".
  Future<bool> approveWaitingAppointment(String uid, int positionNo, DateTime appointmentDate) async {
    try {
      DateTime normalizedDate = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
      QuerySnapshot querySnapshot = await _firestore
          .collection('waiting_appointments')
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(normalizedDate.add(Duration(days: 1))))
          .where('positionNo', isEqualTo: positionNo)
          .where('uid', isEqualTo: uid)
          .where('Status', isEqualTo: 'pending')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({'Status': 'approved'});
        return true;
      }

      return false;
    } catch (e) {
      print('Error approving waiting appointment: $e');
      return false;
    }
  }

  /// Adds a new appointment to the `appointments` collection.
  Future<bool> addAppointment(Map<String, dynamic> appointmentData) async {
    try {
      String appointmentId = _firestore.collection('appointments').doc().id;
      appointmentData['appointmentId'] = appointmentId;

      // Add appointment to the collection
      await _firestore.collection('appointments').doc(appointmentId).set(appointmentData);

      // Add appointment to the queue
      Map<String, dynamic> queueData = {
        'appointmentId': appointmentId,
        'positionNo': appointmentData['positionNo'],
        'queueTime': Timestamp.fromDate(DateTime.now()), // Example value, replace with actual logic
        'status': 'waiting',
      };
      await _firestore.collection('queue').doc(appointmentId).set(queueData);

      return true;
    } catch (e) {
      print('Error adding appointment: $e');
      return false;
    }
  }

  /// Adds a new document to the `queue` collection.
  Future<bool> addToQueue(Map<String, dynamic> queueData) async {
    try {
      String queueId = queueData['appointmentId']; // Use appointmentId as the document ID
      await _firestore.collection('queue').doc(queueId).set(queueData);
      return true;
    } catch (e) {
      print('Error adding to queue: $e');
      return false;
    }
  }
}

