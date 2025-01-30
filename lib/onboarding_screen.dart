import 'package:fitsync_app/welcome_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  double _slideOffset = 0.0;
  final double _animationOffset =
      0.0; // Offset for floating animation of GO button and arrow
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    // Set up animation controller for floating effect
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onSlideComplete() {
    if (_slideOffset >= 100.0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
      );
    } else {
      setState(() {
        _slideOffset = 0.0; // Reset if the slide is incomplete
      });
    }
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Dispose the animation controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0A),
      body: SafeArea(
        child: Stack(
          children: [
            // FitSync Logo at precise position
            const Positioned(
              left: 100, // Adjusted x-coordinate for better positioning
              top: 120, // Adjusted y-coordinate for better positioning
              child: Text.rich(
                TextSpan(
                  text: 'Fit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:
                        50, // Increased font size for a more prominent look
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sync',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 50, // Increased font size
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF89F336),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // The whole screen container that moves up with the slide
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(0, -_slideOffset, 0),
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _slideOffset -=
                          details.primaryDelta ?? 0.0; // Invert drag direction
                      _slideOffset = _slideOffset.clamp(
                          0.0, 200.0); // Limit the slide range
                    });
                  },
                  onVerticalDragEnd: (_) => _onSlideComplete(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer green container
                      Container(
                        width: 100, // Increased size for prominence
                        height: 150, // Increased size
                        decoration: BoxDecoration(
                          color: const Color(0xFF7CBA3B),
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      // Positioned animated "GO" button
                      Positioned(
                        bottom: _slideOffset + _floatingAnimation.value,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 80, // Increased size
                          height: 80, // Increased size
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'GO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  18, // Increased font size for visibility
                            ),
                          ),
                        ),
                      ),
                      // Up arrow icon, above the "GO" button
                      Positioned(
                        bottom: _slideOffset +
                            80 +
                            _floatingAnimation.value, // Adjusted positioning
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.black,
                            size:
                                50, // Increased size of the arrow for better visibility
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
