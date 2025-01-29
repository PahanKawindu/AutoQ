import 'package:flutter/material.dart';
import 'package:test_flutter1/screens/welcome_screen.dart'; // Import the welcome screen.

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Background color for the splash screen
      body: Center(
        child: Text(
          'AutoQ', // Your app's name or logo here
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    // Navigate to the welcome screen after a delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()), // Replace with your WelcomeScreen widget
      );
    });
  }
}
