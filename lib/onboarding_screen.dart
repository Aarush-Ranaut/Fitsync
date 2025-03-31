import 'package:fitsync_app/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:fitsync_app/models/onboarding_data.dart'; // Add this import
import 'package:fitsync_app/widgets/user_info/height_picker_page.dart'; // Add this import

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  double _slideOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth floating animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onSlideComplete() {
    if (_slideOffset >= 100) {
      // Navigate to HeightPickerPage with onboardingData
      var defaultOnboardingData = OnboardingData(
        goal: 'Build Muscle',
        focusAreas: ['Chest', 'Legs'],
        experience: 'Beginner',
        workoutFrequency: 3,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SignupScreen(onboardingData: defaultOnboardingData),
        ),
      );
    } else {
      setState(() {
        _slideOffset = 0.0; // Reset if slide is incomplete
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B0A),
      body: SafeArea(
        child: Stack(
          children: [
            // FitSync Logo
            const Positioned(
              left: 100,
              top: 120,
              child: Text.rich(
                TextSpan(
                  text: 'Fit',
                  style: TextStyle(
                    fontFamily: 'Roboto', // Changed to Roboto
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sync',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Changed to Roboto
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7CBA3B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Draggable container
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final newOffset =
                      (_slideOffset - (details.primaryDelta ?? 0.0))
                          .clamp(0.0, 200.0);
                  if (newOffset != _slideOffset) {
                    setState(() => _slideOffset = newOffset);
                  }
                },
                onVerticalDragEnd: (_) => _onSlideComplete(),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_slideOffset),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Green background container
                          Container(
                            width: 80, // Reduced width for a smaller button
                            height: 120, // Reduced height for a smaller button
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CBA3B),
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          // Floating "GO" button
                          Positioned(
                            bottom: _slideOffset + _floatingAnimation.value,
                            child: Container(
                              width: 60, // Reduced width for a smaller button
                              height: 60, // Reduced height for a smaller button
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
                                  fontSize: 16, // Smaller font size
                                ),
                              ),
                            ),
                          ),
                          // Floating arrow above the "GO" button
                          Positioned(
                            bottom: _slideOffset +
                                60 +
                                _floatingAnimation
                                    .value, // Adjusted position based on new button size
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black,
                              size:
                                  40, // Adjusted size for better proportioning
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
