import 'package:flutter/material.dart';

class ContentTop extends StatelessWidget {
  final int totalPositionsToday;
  final int currentServicingPosition;

  const ContentTop({
    Key? key,
    required this.totalPositionsToday,
    required this.currentServicingPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Justify content horizontally
      children: [
        SizedBox(height: 80),
        // Display 'Current Queue' only if totalPositionsToday is not 0
        if (totalPositionsToday != 0)
          Text(
            'Current Queue',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        // Conditional message display
        totalPositionsToday == 0
            ? Text(
          'No any reservation yet. You are the first one!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        )
            : Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$currentServicingPosition/$totalPositionsToday',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
