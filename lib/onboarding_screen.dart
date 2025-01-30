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
  late AnimationController _animationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    // Smooth floating animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // Shortened for smoothness
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _onSlideComplete() {
    if (_slideOffset >= 100) {
      // Directly navigate to WelcomeScreen without fade transition
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    
    if (_slideOffset >= 100) {
      // Directly navigate to WelcomeScreen without fade transition
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
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
                    fontFamily: 'Poppins',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sync',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF89F336),
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
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CBA3B),
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          // Floating "GO" button
                          Positioned(
                            bottom: _slideOffset + _floatingAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
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
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          // Floating arrow above the "GO" button
                          Positioned(
                            bottom:
                                _slideOffset + 80 + _floatingAnimation.value,
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black,
                              size: 50,
                            ),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  final newOffset = (_slideOffset - (details.primaryDelta ?? 0.0))
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
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CBA3B),
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          // Floating "GO" button
                          Positioned(
                            bottom: _slideOffset + _floatingAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
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
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          // Floating arrow above the "GO" button
                          Positioned(
                            bottom: _slideOffset + 80 + _floatingAnimation.value,
                            child: const Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black,
                              size: 50,
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
