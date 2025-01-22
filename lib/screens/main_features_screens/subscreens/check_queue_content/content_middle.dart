import 'package:flutter/material.dart';
import 'package:test_flutter1/controller/Helper_models/queue.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    queueRecords = QueueService().getTodayQueueRecords();
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
        SizedBox(height: 10),
        widget.totalPositionsToday != 0
            ? FutureBuilder<List<Map<String, dynamic>>>(
          future: queueRecords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No queue records available for today.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

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
                        elevation: 6,
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: record['status'] == 'completed'
                            ? Colors.green.shade100
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                            crossAxisAlignment:
                            CrossAxisAlignment.center, // Center horizontally
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/vehicle.png',
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
                              SizedBox(height: 20),
                              Text(
                                'Vehicle No: ${record['vehicleRegNo']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Status: ${record['status']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: record['status'] == 'completed'
                                      ? Colors.green
                                      : (record['status'] == 'servicing'
                                      ? Colors.orange
                                      : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 20,
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
          },
        )
            : Center(
          child: Image.asset(
            'assets/icon/icon.png',
            height: 100,
          ),
        ),
      ],
    );
  }
}
