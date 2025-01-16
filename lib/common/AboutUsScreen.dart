import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: Center(
        child: Text(
          'This is the About Us screen.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
