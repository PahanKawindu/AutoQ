import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support
import 'package:test_flutter1/common/AboutUsScreen.dart';
import 'package:test_flutter1/screens/main_features_screens/check_queue.dart';
import './main_features_screens/reserve_your_spot_A.dart';
import './main_features_screens/reserve_your_spot_B.dart';

class UserHomeBody extends StatefulWidget {
  @override
  _UserHomeBodyState createState() => _UserHomeBodyState();
}

class _UserHomeBodyState extends State<UserHomeBody> {
  final PageController _pageController = PageController();
  Timer? _sliderTimer;

  // Fetch card data from Firebase
  Future<List<Map<String, dynamic>>> fetchCards() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('AutoQ_service').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sliderTimer?.cancel();
    super.dispose();
  }

  // Auto-slide functionality
  void _startAutoSlide(int totalPages) {
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.toInt() + 1) % totalPages;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No Services Available'));
        }

        final services = snapshot.data!;
        // Start the auto-slide once we have the data
        if (_sliderTimer == null) {
          _startAutoSlide(services.length);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Card section at the top
              SizedBox(
                height: 210, // Fixed height for the card area
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReserveYourSpotA(
                              serviceDetails: service,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF98D8EF), // Light blue
                                  Color(0xFF0077FF), // Darker blue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Left side for text
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        service['ServicePackgeName'] ?? 'Service Name',
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 15.0),
                                      Text(
                                        'Approx Time : ${service['ApproxServiceTime'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        'Vehicle Type : ${service['VehicleType']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      Text(
                                        'Price      : Rs.${service['Price']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side for image
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Container(
                                      margin: EdgeInsets.all(8.0),
                                      child: Image.network(
                                        service['ServiceImage'] ?? 'https://placehold.co/600x400.png',
                                        height: 120,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Smooth Page Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: services.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.blue,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
              const SizedBox(height: 20),

              // Slogan section after the card slider
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Your Vehicle, Our Priority! Reserve Your Spot Now.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),

              // Additional cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildAdditionalCard(
                      context,
                      title: 'Reserve Your Spot',
                      description: 'Book your service appointment today.',
                      assetPath: 'assets/images/reserve.svg',
                      backgroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReserveYourSpotB(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAdditionalCard(
                      context,
                      title: 'Check the Queue',
                      description: 'Stay updated on your service progress in real-time.',
                      assetPath: 'assets/images/check.svg',
                      backgroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckQueue(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildAdditionalCard(
                      context,
                      title: 'About Us',
                      description: 'Learn more about our services and team.',
                      assetPath: 'assets/images/about.svg',
                      backgroundColor: Colors.white,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 23),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build each additional card
  Widget _buildAdditionalCard(
      BuildContext context, {
        required String title,
        required String description,
        required String assetPath,
        required Color backgroundColor,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 5,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          splashColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade200,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left side for text
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side for image
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(
                      assetPath,
                      height: 64,
                      width: 64,
                    ),
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
