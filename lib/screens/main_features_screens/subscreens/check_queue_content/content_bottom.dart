import 'package:flutter/material.dart';

import '../select_vehicle.dart';

class ContentBottom extends StatelessWidget {
  final bool hasReservation;
  final bool isServiced;
  final int currentServicingPosition;
  final String userPosition;

  const ContentBottom({
    Key? key,
    required this.hasReservation,
    required this.isServiced,
    required this.currentServicingPosition,
    required this.userPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Check if user has reservation
        if (!hasReservation)
          Center(  // Center the button
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0), // Add vertical padding
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to SelectVehicle screen with AppBar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Color(0xFFE5F7F1),
                        ),
                        body: SelectVehicle(), // Your SelectVehicle screen content
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF46C2AF), // White text color
                  minimumSize: Size(200, 40), // Increased width and height for button
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16), // Padding for button text
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Text styling
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0), // Rounded corners for modern look
                  ),
                  elevation: 5, // Adding a subtle shadow
                ),
                child: Text('Book Now'),
              ),

            ),
          ),

        // If user has reservation, check if service is completed
        if (hasReservation)
          if (isServiced)
          // Service completed message in green
            Text(
              'Your vehicle service is completed!',
              style: TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
          else if (currentServicingPosition > int.parse(userPosition))
          // Display message in red if userPosition > currentServicingPosition
            Text(
              'Please contact us as soon as possible!',
              style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
      ],
    );
  }
}
