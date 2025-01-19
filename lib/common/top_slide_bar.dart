
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter1/screens/signup_screen.dart';
import 'MyProfileScreen.dart';
import 'AboutUsScreen.dart';
import 'HelpSupportScreen.dart';

class TopSlideBar extends StatefulWidget {
  @override
  _TopSlideBarState createState() => _TopSlideBarState();
}

class _TopSlideBarState extends State<TopSlideBar> {
  String _firstName = '';
  String _lastName = '';
  String _contactNo = '';
  String _profileImage = 'assets/icon/user.png'; // Default profile image

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    //debugPrint('Saved Session Info: UID = $uid ');

    if (uid != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _firstName = userDoc['first_name'] ?? 'User';
          _lastName = userDoc['last_name'] ?? 'Name';
          _contactNo = userDoc['contact_no'] ?? 'N/A';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(0), // No rounding on the top-right corner
        bottomRight: Radius.circular(0), // No rounding on the bottom-right corner
      ),
      child: Drawer(
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF46C2AF),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50, // Larger size
                    backgroundColor: Color(0xFF46C2AF), // Border color
                    child: CircleAvatar(
                      radius: 45, // Inner circle with some padding
                      backgroundColor: Colors.white, // Background color inside the border
                      child: Icon(
                        Icons.person, // Default profile icon
                        size: 40, // Icon size
                        color: Color(0xFF46C2AF), // Icon color
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_firstName \n$_lastName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _contactNo,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Drawer Items
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: Color(0xFF46C2AF)),
                    title: Text('My Profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Color(0xFF46C2AF)),
                    title: Text('About Us'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUsScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help, color: Color(0xFF46C2AF)),
                    title: Text('Help & Support'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Logout Icon
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: GestureDetector(
                onTap: () async {
                  bool shouldLogout = await _showLogoutConfirmationDialog();
                  if (shouldLogout) {
                    _handleLogout();
                  }
                },
                child: Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('userRole');

    // Show logout success notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You have successfully logged out.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to SignupScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen(),
      ),
    );
  }
}
