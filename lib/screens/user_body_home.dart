import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:test_flutter1/common/AboutUsScreen.dart';
import 'package:test_flutter1/screens/main_features_screens/check_queue.dart';
import './main_features_screens/reserve_your_spot_A.dart';
import './main_features_screens/reserve_your_spot_B.dart';

class UserHomeBody extends StatelessWidget {
  final PageController _pageController = PageController();

  // Fetch card data from Firebase
  Future<List<Map<String, dynamic>>> fetchCards() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('AutoQ_service').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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
        return SingleChildScrollView(
          child: Column(
            children: [
              // Card section at the top
              Container(
                height: 200, // Fixed height for the card area
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
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Approx Service Time: ${service['ApproxServiceTime'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Price: ${service['Price']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Vehicle Type: ${service['VehicleType']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
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
                                    child: SvgPicture.asset(
                                      'assets/images/service_icon.svg', // Example SVG path
                                      height: 120,
                                      fit: BoxFit.cover,
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

              // Additional cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildAdditionalCard(
                      context,
                      title: 'Reserve Your Spot',
                      description: 'Book your service appointment today.',
                      svgPath: 'assets/images/spot.svg',
                      backgroundColor: const Color(0xFFE8F6F3),
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
                      description:
                      'Stay updated on your service progress in real-time.',
                      svgPath: 'assets/images/queue.svg',
                      backgroundColor: const Color(0xFFE8F6F3),
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
                      svgPath: 'assets/images/about.svg',
                      backgroundColor: const Color(0xFFE8F6F3),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(),
                          ),
                        );
                      },
                    ),
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
        required String svgPath,
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
              // Right side for SVG image
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(
                    svgPath,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
