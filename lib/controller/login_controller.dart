import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen_admin.dart'; // Import admin screen
import '../screens/home_screen_user_main.dart'; // Import user screen

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
          (value) async {
        // Fetch user information from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(value.user!.uid)
            .get();

        if (!userDoc.exists) {
          // Handle case where the user document doesn't exist
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  const Text('User data not found'),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          return;
        }

        // Extract user role
        String userRole = userDoc['user_role'];

        // Save session-related information (example: user ID and role)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('uid', value.user!.uid);
        await prefs.setString('userRole', userRole);

        // Read and display session-related information
        String? savedUid = prefs.getString('uid');
        String? savedUserRole = prefs.getString('userRole');
        debugPrint('Saved Session Info: UID = $savedUid, UserRole = $savedUserRole');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text('User Successfully Logged in'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        debugPrint('User Successfully Logged in with role: $userRole');

        // Navigate to the appropriate screen based on user role
        if (userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenAdmin()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenUser()),
          );
        }
      },
    ).onError(
          (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.redAccent),
                const SizedBox(width: 8),
                const Text('Login Failed: Invalid Credentials'),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        debugPrint('User Failed Log in : $error');
      },
    );
  }
}
