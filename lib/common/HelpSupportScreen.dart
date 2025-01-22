import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE5F7F1), // Consistent color
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Color(0xFFF5F5F5), // Light grey background for a calm tone
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Text(
                  'How can we assist you?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26, // Adjusted for better prominence
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF46C2AF),
                  ),
                ),
              ),
              SizedBox(height: 24), // Reduced space for compactness

              // Contact Information Section
              _buildSectionTitle('Contact Us'),
              SizedBox(height: 20), // Adjusted for consistent spacing
              _buildContactItem(
                icon: Icons.email,
                title: 'Email',
                content: 'support@autoq.lk',
              ),
              _buildContactItem(
                icon: Icons.phone,
                title: 'Phone',
                content: '+94 112 345 678',
              ),
              _buildContactItem(
                icon: Icons.location_on,
                title: 'Address',
                content: 'No. 45, Sri Lanka',
              ),
              SizedBox(height: 24), // Reduced spacing

              // FAQ Section
              _buildSectionTitle('FAQs (Frequently Asked Questions)'),
              SizedBox(height: 20), // Adjusted for consistent spacing
              _buildFAQ(
                'How do I book a service?',
                'Go to the "Book Service" section, select your preferred service center, date, and time, then confirm your booking.',
              ),
              _buildFAQ(
                'How can I cancel or reschedule?',
                'You can manage your bookings in the "My Bookings" section. Cancellations or reschedules should be made at least 24 hours in advance.',
              ),
              _buildFAQ(
                'How do I track my queue position?',
                'Queue positions can be tracked in real-time under the "Queue Status" section. Notifications will provide updates.',
              ),
              SizedBox(height: 24), // Reduced spacing

              // Feedback Section
              _buildSectionTitle('Feedback & Suggestions'),
              SizedBox(height: 20), // Adjusted for consistent spacing
              Text(
                'We value your feedback! Please share your thoughts to help us improve AutoQ. Use the in-app feedback form or email us directly at support@autoq.lk.',
                style: TextStyle(
                  fontSize: 16, // Adjusted for readability
                  height: 1.6,  // Line height for better readability
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24), // Reduced spacing

              // Social Media Links
              _buildSectionTitle('Follow Us'),
              SizedBox(height: 20), // Adjusted for consistent spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialMediaButton(Icons.facebook, 'Facebook', 'facebook.com/autoq.lk'),
                ],
              ),
              SizedBox(height: 24), // Reduced spacing
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20, // Adjusted for consistency
        fontWeight: FontWeight.bold,
        color: Color(0xFF46C2AF), // Consistent color for section titles
      ),
    );
  }

  // Helper method for contact information
  Widget _buildContactItem({required IconData icon, required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14), // Adjusted for compactness
      child: Row(
        children: [
          Icon(icon, size: 28, color: Color(0xFF46C2AF)), // Updated color
          SizedBox(width: 18), // Adjusted space between icon and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for FAQ items
  Widget _buildFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 18, // Adjusted font size for FAQ
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
          ),
        ],
      ),
    );
  }

  // Helper method for social media buttons
  Widget _buildSocialMediaButton(IconData icon, String platform, String handle) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF46C2AF), size: 36), // Updated color
        SizedBox(height: 8),
        Text(
          platform,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Text(
          handle,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
