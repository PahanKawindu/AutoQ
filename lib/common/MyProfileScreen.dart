import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Load user info from Firestore
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    if (uid != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _userInfo = userDoc.data() as Map<String, dynamic>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontSize: 18)),
        backgroundColor: Color(0xFF46C2AF),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image and Name
            Center(
              child: Column(
                children: [
                  SizedBox(height: 25),
                  CircleAvatar(
                    radius: 40, // Smaller profile image
                    backgroundColor: Color(0xFF46C2AF),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF46C2AF),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_userInfo?['first_name'] ?? ''} ${_userInfo?['last_name'] ?? ''}',
                    style: TextStyle(
                      fontSize: 20, // Smaller text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userInfo?['email'] ?? '',
                    style: TextStyle(
                      fontSize: 14, // Smaller email text
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // User Details
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: 'Contact No',
                    value: _userInfo?['contact_no'] ?? 'N/A',
                  ),
                  SizedBox(height: 8), // Space between items
                  _buildInfoCard(
                    icon: Icons.person_outline,
                    label: 'User Role',
                    value: _userInfo?['user_role'] ?? 'N/A',
                  ),
                  SizedBox(height: 8), // Space between items
                  _buildInfoCard(
                    icon: Icons.date_range,
                    label: 'Account Created',
                    value: _userInfo?['created_at'] != null
                        ? (_userInfo!['created_at'] as Timestamp)
                        .toDate()
                        .toString()
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon, required String label, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Smaller border radius
      ),
      elevation: 3, // Reduced elevation
      margin: const EdgeInsets.symmetric(vertical: 4), // Uniform margin
      child: ListTile(
        leading: CircleAvatar(
          radius: 18, // Smaller icon size
          backgroundColor: Color(0xFF46C2AF),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14, // Smaller label text
            fontWeight: FontWeight.bold,
            color: Color(0xFF34A0A4),
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey[800]), // Smaller value text
        ),
      ),
    );
  }
}
