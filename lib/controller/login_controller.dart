import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home_screen.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
          (value)  {
            // **Save login state after successful login**
            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // await prefs.setBool('isLoggedIn', true); // Store login state
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
        debugPrint('User Successfully Logged in');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
