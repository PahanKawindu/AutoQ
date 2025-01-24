import 'package:flutter/material.dart';
import 'package:test_flutter1/common/top_slide_bar_admin.dart';
import 'dart:io';
import 'admin_body_home.dart';
import 'admin_body_settings.dart';


class HomeScreenAdmin extends StatefulWidget {
  @override
  State<HomeScreenAdmin> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenAdmin> {
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
        backgroundColor: Color(0xFFE5F7F1),
        appBar: AppBar(
          title: const Text(
            'AutoQ',
            style: TextStyle(
              color: Color(0xFF46C2AF),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFE5E5E5),
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
            _selectedIndex == 0 ? AdminBodyHome() : AdminBodySettings(),
            // Slide Bar (Top Sliding Menu)
            if (_isSlideBarOpen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 600, // Height of the sliding menu
                  color: Colors.black.withOpacity(0.6), // Background overlay
                  child: TopSlideBarAdmin(), // Your custom slide bar
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
              icon: Icon(Icons.settings),
              label: 'Settings',
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
