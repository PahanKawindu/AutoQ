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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to SelectVehicle screen with AppBar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text('Select Vehicle'),
                          backgroundColor: Colors.teal, // Customize the AppBar color if needed
                        ),
                        body: SelectVehicle(), // Your SelectVehicle screen content
                      ),
                    ),
                  );
                },
                child: Text('Book Now'),
              ),
            ],
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
