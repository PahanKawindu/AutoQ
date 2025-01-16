
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
  static Future<void> notifyServiceStatus(Map<String, dynamic> queueData) async {
    print('Notification sent for service status with the following data:');
    print(queueData);
  }

  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    }
  }

}
