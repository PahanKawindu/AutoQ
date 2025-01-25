import 'package:flutter/material.dart';
import 'dart:io';
import '../common/top_slide_bar.dart'; // Import the top slide bar widget
import 'main_features_screens/notification.dart';
import 'user_body_home.dart'; // Import the user home body widget
import 'user_body_history.dart'; // Import the service history widget
import 'package:shared_preferences/shared_preferences.dart'; // Import for SharedPreferences
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import

class HomeScreenUser extends StatefulWidget {
  @override
  State<HomeScreenUser> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenUser> {
  int _selectedIndex = 0;
  bool _isSlideBarOpen = false; // Track if the slide bar is open
  bool _isNotificationAvailable = false; // Track if a notification is available
  late String _uid; // User UID to listen to active messages collection

  // Navigation function
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  // Load the UID from SharedPreferences
  void _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _uid = prefs.getString('uid') ?? ''; // Get UID from SharedPreferences

    if (_uid.isNotEmpty) {
      // Listen to changes in the active_messages collection for the current user
      FirebaseFirestore.instance
          .collection('active_messages')
          .doc(_uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          // Update the notification state without affecting the whole screen
          setState(() {
            _isNotificationAvailable = snapshot.data()?['hasNewMessage'] ?? false;
          });
        }
      });
    }
  }

  // Function to handle notification icon tap
  void _onNotificationTapped() {
    setState(() {
      _isNotificationAvailable = false; // Remove the notification dot
    });

    // Navigate to the notification screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    );
  }

  // Refresh function for pull-to-refresh
  Future<void> _refreshContent() async {
    // You can add custom logic to refresh your content here
    // For example, re-fetch data from Firestore, SharedPreferences, or APIs.
    // If you need to reload the data, you can call the necessary functions here.

    await Future.delayed(Duration(seconds: 2)); // Simulate a network request

    // After refreshing, update the UI state
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0); // Terminates the app
      },
      child: Scaffold(
        backgroundColor: Color(0xFFE5F7F1), // Light transparent green background for body
        appBar: AppBar(
          title: const Text(
            'AutoQ',
            style: TextStyle(
              color: Color(0xFF46C2AF),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white, // Set the AppBar background color to white
          elevation: 1, // Subtle shadow effect for a more professional look
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(169, 169, 169, 0.3),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isSlideBarOpen = !_isSlideBarOpen; // Toggle the slide bar state
                  });
                },
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(169, 169, 169, 0.3),
                ),
                child: IconButton(
                  icon: Stack(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.black54,
                      ),
                      if (_isNotificationAvailable)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _onNotificationTapped,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Add SizedBox with height 30 at the top and bottom of the body
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshContent, // Attach the refresh function
                    child: _selectedIndex == 0 ? UserHomeBody() : UserServiceHistory(),
                  ),
                ),
              ],
            ),
            // Slide Bar (Top Sliding Menu)
            if (_isSlideBarOpen)
              Positioned(
                top: 0,
                left: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width / 1.29, // Half of the screen width
                  height: MediaQuery.of(context).size.height * 1,
                  color: Colors.black.withOpacity(0.6), // Background overlay
                  child: TopSlideBar(), // Your custom slide bar
                ),
              ),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white, // Set the bottom navigation bar background color to white
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Service History',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF46C2AF),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
