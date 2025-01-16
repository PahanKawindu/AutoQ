import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Add this for smooth page indicator

class ContentMiddle extends StatefulWidget {
  final int totalPositionsToday;
  final String userPosition;

  const ContentMiddle({
    Key? key,
    required this.totalPositionsToday,
    required this.userPosition,
  }) : super(key: key);

  @override
  _ContentMiddleState createState() => _ContentMiddleState();
}

class _ContentMiddleState extends State<ContentMiddle> {
  late Future<List<Map<String, dynamic>>> queueRecords;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    queueRecords = QueueService().getTodayQueueRecords(); // Fetch today's queue records
  }

  void _scrollToCard(List<Map<String, dynamic>> records) {
    int targetIndex = records.indexWhere((record) => record['status'] == 'servicing');
    targetIndex = targetIndex == -1 ? 0 : targetIndex;

    _pageController.animateToPage(
      targetIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        widget.totalPositionsToday != 0
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: queueRecords,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No queue records available for today.');
                } else {
                  var records = snapshot.data!;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToCard(records);
                  });

                  return Container(
                    height: 400,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            var record = records[index];
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              color: record['status'] == 'completed' ? Colors.green.shade200 : null, // Change color if completed
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Position number on top of the vehicle image
                                    SizedBox(height: 10),
                                    // Row for car image and servicing gun image
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/vehicle.png', // Replace with your car image path
                                              height: 120,
                                            ),
                                            Positioned(
                                              top: 50,
                                              child: Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '${record['positionNo']}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 20),
                                        // Servicing gun icon on the right (only if the status is 'servicing')
                                        if (record['status'] == 'servicing')
                                          Image.asset(
                                            'assets/servicing-gun.jpg', // Replace with your servicing gun image path
                                            height: 80,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Vehicle number and status below the vehicle number
                                    Text(
                                      'Vehicle No: ${record['vehicleRegNo']}',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Status: ${record['status']}',
                                      style: TextStyle(fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 50,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: records.length,
                              effect: WormEffect(
                                dotWidth: 10,
                                dotHeight: 10,
                                activeDotColor: Colors.teal,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        )
            : Image.asset(
          'assets/icon/icon.png', // Path to your icon image
          height: 100, // Adjust the size as needed
          //Text('No queue records available for today.'),
        ),
      ],
    );
  }
}
