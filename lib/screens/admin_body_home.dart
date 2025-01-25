import 'package:flutter/material.dart';

import 'main_features_screens/set_reservation_limitation_admin.dart';
import 'main_features_screens/view_reservation_admin.dart';
import 'main_features_screens/view_today_queue_admin.dart';

class AdminBodyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1), // Light transparent green background
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card 1: View Reservation
                buildMinimalCard(
                  context,
                  title: 'View All Reservations',
                  subtitle: 'Manage and review all bookings.',
                  icon: Icons.calendar_today_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewReservationAdmin()),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Card 2: Today Queue
                buildMinimalCard(
                  context,
                  title: 'Today\'s Queue',
                  subtitle: 'View today’s reservation queue.',
                  icon: Icons.access_time_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewTodayQueueAdmin()),
                    );
                  },
                ),
                SizedBox(height: 20),
                // Card 3: Set Reservation Limit
                buildMinimalCard(
                  context,
                  title: 'Set Reservation Limit',
                  subtitle: 'Define daily reservation limits.',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SetReservationLimitationAdmin()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMinimalCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Function onTap,
      }) {
    return InkWell(
      onTap: () => onTap(),
      splashColor: Colors.teal.shade200, // Splash effect color
      highlightColor: Colors.teal.shade300, // Highlight effect color
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 140, // Adjusted height for a sleek look
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          color: Colors.teal.shade100, // Subtle and consistent card color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade300, // Icon background color
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
