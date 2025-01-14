import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
}
