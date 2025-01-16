import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: Center(
        child: Text(
          'This is the Help & Support screen.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
