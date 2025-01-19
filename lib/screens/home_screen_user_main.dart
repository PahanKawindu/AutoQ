import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../common/top_slide_bar.dart'; // Import the top slide bar widget
import 'user_body_home.dart'; // Import the user home body widget
import 'user_body_history.dart'; // Import the service history widget

class HomeScreenUser extends StatefulWidget {
  @override
  State<HomeScreenUser> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenUser> {
  int _selectedIndex = 0;
  bool _isSlideBarOpen = false; // Track if the slide bar is open

  // Navigation function
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0); // Terminates the app
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set the overall background color to white
        appBar: AppBar(
          title: const Text(
            'AutoQ',
            style: TextStyle(
              color: Color(0xFF46C2AF), // Theme green color
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white, // Set the app bar background color to white
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(169, 169, 169, 0.3), // Subtle background
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
                  color: Color.fromRGBO(169, 169, 169, 0.3), // Subtle background
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    print('Notification icon pressed');
                  },
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Conditionally load either the Home Body or Service History
            _selectedIndex == 0 ? UserHomeBody() : UserServiceHistory(),
            // Slide Bar (Top Sliding Menu)
            if (_isSlideBarOpen)
              Positioned(
                top: 0,
                left: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: MediaQuery.of(context).size.height, // Full screen height
                  width: MediaQuery.of(context).size.width * 0.75, // Slightly more than half screen width
                  color: Colors.black.withOpacity(0.6), // Background overlay
                  child: Stack(
                    children: [
                      TopSlideBar(), // Your custom slide bar
                      // Add a back icon in the top-right corner of the sidebar
                      Positioned(
                        top: 16, // Padding from the top
                        right: 16, // Padding from the right
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSlideBarOpen = false; // Close the sidebar
                            });
                          },
                          child: Icon(
                            Icons.arrow_back, // Back arrow icon
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
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
          selectedItemColor: Color(0xFF46C2AF), // Theme green color for selected
          unselectedItemColor: Colors.grey, // Neutral gray for unselected
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, // White background for bottom bar
          elevation: 8, // Add subtle elevation for separation
        ),
      ),
    );
  }
}
