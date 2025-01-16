import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// QueueService class
class QueueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getNextQueueAndTime(DateTime date) async {
    try {
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);

      QuerySnapshot queueSnapshot = await _firestore
          .collection('queue')
          .where('queueTime', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedDate))
          .where('queueTime', isLessThan: Timestamp.fromDate(normalizedDate.add(Duration(days: 1))))
          .orderBy('positionNo', descending: true)
          .limit(1)
          .get();

      if (queueSnapshot.docs.isEmpty) {
        DateTime estimatedTime = DateTime(normalizedDate.year, normalizedDate.month, normalizedDate.day, 8, 0);
        return {
          'nextQueueNumber': 1,
          'estimatedQueueTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(estimatedTime),
        };
      }

      var highestQueueDoc = queueSnapshot.docs.first;
      int highestPositionNo = highestQueueDoc['positionNo'];
      String appointmentId = highestQueueDoc['appointmentId'];
      Timestamp queueTimeTimestamp = highestQueueDoc['queueTime'];
      DateTime queueTime = queueTimeTimestamp.toDate();

      QuerySnapshot appointmentSnapshot = await _firestore
          .collection('appointments')
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      if (appointmentSnapshot.docs.isEmpty) {
        return {'nextQueueNumber': highestPositionNo + 1, 'estimatedQueueTime': 'No appointments found'};
      }

      var appointmentDoc = appointmentSnapshot.docs.first;
      int serviceId = appointmentDoc['serviceId'];

      QuerySnapshot serviceSnapshot = await _firestore
          .collection('AutoQ_service')
          .where('ServceID', isEqualTo: serviceId)
          .get();

      if (serviceSnapshot.docs.isEmpty) {
        return {'nextQueueNumber': highestPositionNo + 1, 'estimatedQueueTime': 'No service found'};
      }

      var serviceDoc = serviceSnapshot.docs.first;
      String approxServiceTimeStr = serviceDoc['ApproxServiceTime'];

      List<String> timeParts = approxServiceTimeStr.split(':');
      int hours = int.parse(timeParts[0].replaceAll('h', '').trim());
      int minutes = int.parse(timeParts[1].replaceAll('m', '').trim());

      DateTime estimatedPositionTime = queueTime.add(Duration(hours: hours, minutes: minutes));

      int nextQueueNumber = highestPositionNo + 1;

      return {
        'nextQueueNumber': nextQueueNumber,
        'estimatedQueueTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(estimatedPositionTime),
      };
    } catch (e) {
      return {'nextQueueNumber': 1, 'estimatedQueueTime': 'Error'};
    }
  }

  Future<Map<String, dynamic>> getTodayQueueInfo() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      // Get how many positions are there today
      QuerySnapshot queueSnapshot = await _firestore
          .collection('queue')
          .where('queueTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('queueTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      int totalPositionsToday = queueSnapshot.docs.length;
      print('totalPositionsToday: $totalPositionsToday');

      // Get the current servicing position number
      QuerySnapshot servicingSnapshot = await _firestore
          .collection('queue')
          .where('queueTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('queueTime', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: 'servicing')
          .get();
      String currentServicingPosition = servicingSnapshot.docs.isNotEmpty
          ? servicingSnapshot.docs.first['positionNo'].toString()
          : 'Closed.'; // -1 if no servicing position is found
      print('currentServicingPosition: $currentServicingPosition');


      // Check if there is a reservation for today for the current user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString('uid');
      if (uid == null) {
        return {'error': 'User not logged in'};
      }

      QuerySnapshot reservationSnapshot = await _firestore
          .collection('appointments')
          .where('uid', isEqualTo: uid)
          .where('appointmentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('appointmentDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();
      bool hasReservation = reservationSnapshot.docs.isNotEmpty;
      String? appointmentId;
      int? userPosition;
      print('hasReservation: $hasReservation');


      if (hasReservation) {
        var reservationDoc = reservationSnapshot.docs.first;
        appointmentId = reservationDoc['appointmentId'];

        // Get the user's position in the queue
        QuerySnapshot userQueueSnapshot = await _firestore
            .collection('queue')
            .where('appointmentId', isEqualTo: appointmentId)
            .get();
        if (userQueueSnapshot.docs.isNotEmpty) {
          var userQueueDoc = userQueueSnapshot.docs.first;
          userPosition = userQueueDoc['positionNo'];
        }
      }
      print('userPosition: $userPosition');


      // Check if the vehicle is serviced
      bool isServiced = false;
      if (userPosition != null) {
        QuerySnapshot positionSnapshot = await _firestore
            .collection('queue')
            .where('appointmentId', isEqualTo: appointmentId)
            .where('positionNo', isEqualTo: userPosition)
            .get();
        if (positionSnapshot.docs.isNotEmpty) {
          var positionDoc = positionSnapshot.docs.first;
          if (positionDoc['status'] == 'completed') {
            isServiced = true;
          }
        }
      }

      print('isServiced: $isServiced');


      // Returning the result
      return {
        'totalPositionsToday': totalPositionsToday,
        'currentServicingPosition': currentServicingPosition,
        'hasReservation': hasReservation,
        'userPosition': userPosition,
        'isServiced': isServiced,
      };

    } catch (e) {
      return {'error': 'Error occurred while fetching queue info'};
    }
  }

  Future<List<Map<String, dynamic>>> getTodayQueueRecords() async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      // Fetch all queue records for today
      QuerySnapshot queueSnapshot = await _firestore
          .collection('queue')
          .where('queueTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('queueTime', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      List<Map<String, dynamic>> queueRecords = [];

      for (var doc in queueSnapshot.docs) {
        String appointmentId = doc['appointmentId'];
        int positionNo = doc['positionNo'];
        String status = doc['status'];

        // Fetch appointment details for the corresponding appointmentId
        QuerySnapshot appointmentSnapshot = await _firestore
            .collection('appointments')
            .where('appointmentId', isEqualTo: appointmentId)
            .get();

        if (appointmentSnapshot.docs.isNotEmpty) {
          var appointmentDoc = appointmentSnapshot.docs.first;
          String vehicleRegNo = appointmentDoc['vehicleRegNo'];
          DateTime appointmentDate = appointmentDoc['appointmentDate'].toDate();

          // Add relevant data to the list
          queueRecords.add({
            'appointmentDate': DateFormat('yyyy-MM-dd HH:mm:ss').format(appointmentDate),
            'appointmentId': appointmentId,
            'positionNo': positionNo,
            'status': status,
            'vehicleRegNo': vehicleRegNo,
          });
        }
      }

      return queueRecords;
    } catch (e) {
      return [];
    }
  }

}
