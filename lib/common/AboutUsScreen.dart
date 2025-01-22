import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define the color to be used for both the appbar and body
    Color primaryColor = Color(0xFFE5F7F1);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor, // Set AppBar background color
        elevation: 0, // Removes shadow for a more seamless look
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AutoQ Logo
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF46C2AF), // Set the same background color here
                child: Text(
                  'AutoQ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Welcome Text
            Center(
              child: Text(
                'Welcome to AutoQ!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),

            // Introduction Section
            Text(
              'At AutoQ, we understand the challenges of managing vehicle service queues efficiently. '
                  'Our mission is to provide a seamless, hassle-free solution for vehicle owners and service centers.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            SizedBox(height: 16),

            // Vision Section
            Text(
              'Our Vision',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Use the same color
              ),
            ),
            SizedBox(height: 8),
            Text(
              'To redefine vehicle service experiences by creating a digital platform that ensures convenience, transparency, and efficiency for everyone involved.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            SizedBox(height: 16),

            // Mission Section
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Use the same color
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- To reduce waiting times and enhance customer satisfaction.\n'
                  '- To empower service centers with innovative tools for managing daily operations.\n'
                  '- To bridge the gap between vehicle owners and service providers using a user-friendly mobile application.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            SizedBox(height: 16),

            // Why Choose Us Section
            Text(
              'Why Choose AutoQ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Use the same color
              ),
            ),
            SizedBox(height: 8),
            Text(
              '- Real-Time Queue Tracking: Get live updates on your service status and reduce idle waiting.\n'
                  '- Effortless Booking: Schedule service appointments at your convenience with just a few taps.\n'
                  '- Customized Notifications: Receive reminders and updates about your bookings and queue position.\n'
                  '- Customer-Centric Design: Designed with the user in mind, AutoQ ensures a seamless experience for vehicle owners and service centers alike.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            SizedBox(height: 16),

            // Team Section
            Text(
              'Our Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor, // Use the same color
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We are a group of passionate developers, designers, and automotive enthusiasts dedicated to creating solutions that enhance the vehicle service experience. '
                  'Our commitment to innovation and customer satisfaction drives us to constantly improve and expand the AutoQ platform.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            SizedBox(height: 16),

            // Closing Text
            Center(
              child: Text(
                'Join us in transforming the future of vehicle service management.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Use the same color
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
