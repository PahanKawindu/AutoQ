import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  // Function to fetch card data from Firebase
  Future<List<Map<String, dynamic>>> fetchCards() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('services').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

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
        backgroundColor: const Color(0xFFE5E5E5),
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
                  Scaffold.of(context).openDrawer();
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
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'AutoQ Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Queue Status'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Queue History'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.support),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchCards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No services available'));
            }

            final services = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  service['imageUrl'],
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 16.0),
                                Text(
                                  service['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  service['description'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: services.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.blue,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Queue Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Queue History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Service History',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
