import 'package:flutter/material.dart';

class ContentTop extends StatefulWidget {
  final int totalPositionsToday;
  final int currentServicingPosition;
  final String userPosition;

  const ContentTop({
    Key? key,
    required this.totalPositionsToday,
    required this.currentServicingPosition,
    required this.userPosition,
  }) : super(key: key);

  @override
  _ContentTopState createState() => _ContentTopState();
}

class _ContentTopState extends State<ContentTop> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration
    )..repeat(reverse: true); // Repeat animation in reverse
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0), // Horizontal padding for the whole section
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          // Current Queue Row
          // Current Queue Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center align the row
            children: [
              SizedBox(height: 60), // Space above the content
              if (widget.totalPositionsToday != 0)
                Text(
                  'Current Queue  :    ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black, // White text color
                  ),
                ),
              // Conditional message display
              widget.totalPositionsToday == 0
                  ? Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'No reservation yet. You are the first one!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70, // Light white color for the message
                  ),
                ),
              )
                  : AnimatedContainer(
                duration: Duration(seconds: 1), // Animation duration for border changes
                curve: Curves.easeInOut, // Smooth curve for the animation
                margin: const EdgeInsets.only(top: 5.0), // Margin for separation
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Adjust padding for better spacing
                decoration: BoxDecoration(
                  color: Colors.black87, // Black background for the container
                  border: Border.all(
                    color: Colors.white, // White border color
                    width: 1.0, // Set border width
                  ),
                  borderRadius: BorderRadius.circular(12), // Rounded corners for a smoother look
                ),
                child: Text(
                  '${widget.currentServicingPosition} / ${widget.totalPositionsToday}',
                  style: TextStyle(
                    fontSize: 17, // Slightly larger font size
                    color: Colors.white, // White text color
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Ensure text is centered inside the box
                ),
              ),
            ],
          ),


          // Display userPosition below the current queue
          if (widget.totalPositionsToday != 0)
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center align the row
                children: [
                  Text(
                    'Your Position   ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(12), // Padding inside the circle
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(_controller.value), // Circle color with animation opacity
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: _controller.value * 20,
                              spreadRadius: _controller.value * 5,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.userPosition == 'Not found'
                              ? 'You have no reservation yet'
                              : '${widget.userPosition}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
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
  }
}
