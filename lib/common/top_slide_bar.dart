import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _profileImage = 'assets/icon/icon.png'; // Default profile image

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  // Fetch user details from Firestore using the UID stored in SharedPreferences
  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    //debugPrint('Saved Session Info: UID = $uid ');

    if (uid != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

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
    return Container(
      color: Colors.white,
      height: 400, // Height of the slide bar
      child: Column(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(_profileImage), // User profile image
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_firstName $_lastName',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      _contactNo,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  onPressed: () {
                    _handleLogout();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Options section
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Handle logout functionality
  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('userRole');
    // Redirect to login page
  }
}
