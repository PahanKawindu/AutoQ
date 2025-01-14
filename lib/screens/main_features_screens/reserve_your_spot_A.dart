import 'package:flutter/material.dart';

class ReserveYourSpotA extends StatelessWidget {
  final Map<String, dynamic> serviceDetails;

  const ReserveYourSpotA({Key? key, required this.serviceDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserve Spot A'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: Center(
        child: Text(
          'Selected Package: ${serviceDetails['ServceID']}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
