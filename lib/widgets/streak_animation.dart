import 'package:flutter/material.dart';
import 'dart:math';

class StreakAnimation extends StatefulWidget {
  final int currentStreak;
  final int currentExperience;
  final Function(int, int, List<String>) onAnimationComplete;

  const StreakAnimation({
    Key? key,
    required this.currentStreak,
    required this.currentExperience,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  _StreakAnimationState createState() => _StreakAnimationState();
}

class _StreakAnimationState extends State<StreakAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _coinController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _xpBarAnimation;
  final List<Offset> _coinPositions = [];
  final Random _random = Random();
  bool _showContinueButton = false;
  double _xpProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Main animation controller for fade and overall timing
    _controller = AnimationController(
      duration:
          const Duration(seconds: 5), // Extended duration for full sequence
      vsync: this,
    );

    // Coin animation controller
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.2, curve: Curves.easeInOut)),
    );

    // XP bar filling animation
    _xpBarAnimation = Tween<double>(
            begin: widget.currentExperience / 1000,
            end: (widget.currentExperience + 10) / 1000)
        .animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );

    // Generate random coin positions
    for (int i = 0; i < 10; i++) {
      _coinPositions.add(Offset(
        _random.nextDouble() * 300 - 150, // Random x-position
        _random.nextDouble() * 400 - 200, // Random y-position
      ));
    }

    // Start animations
    _controller.forward().then((_) {
      setState(() {
        _showContinueButton = true; // Show button after animation
      });
    });

    _coinController.forward();
  }

  List<String> _updateAchievements(int streak) {
    const milestoneLabels = [
      '1 Day',
      '1 Week',
      '10 Days',
      '20 Days',
      '1 Month',
      '2 Months',
      '3 Months',
      '6 Months',
      '1 Year'
    ];
    const milestoneDays = [1, 7, 10, 20, 30, 60, 90, 180, 365];

    List<String> achievements = [];
    for (int i = 0; i < milestoneDays.length; i++) {
      if (streak >= milestoneDays[i]) {
        achievements.add(milestoneLabels[i]);
      }
    }
    return achievements;
  }

  @override
  void dispose() {
    _controller.dispose();
    _coinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Streak and XP display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Streak: ${widget.currentStreak + 1} Days',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Experience Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: AnimatedBuilder(
                      animation: _xpBarAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Text(
                              '+10 XP Collected!',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: _xpBarAnimation.value > 1.0
                                  ? 1.0
                                  : _xpBarAnimation.value,
                              minHeight: 20,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${(widget.currentExperience + 10) % 1000}/1000 XP to Level ${(widget.currentExperience + 10) ~/ 1000 + 1}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Continue Button
                  if (_showContinueButton)
                    ElevatedButton(
                      onPressed: () {
                        int newStreak = widget.currentStreak + 1;
                        int newExperience = widget.currentExperience + 10;
                        List<String> newAchievements =
                            _updateAchievements(newStreak);
                        widget.onAnimationComplete(
                            newStreak, newExperience, newAchievements);
                        Navigator.of(context).pop(); // Close the overlay
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        shadowColor: Colors.green.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward, color: Colors.black),
                          const SizedBox(width: 10),
                          Text(
                            'Continue to Fitness Journey',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Coin animation flying into the XP bar
              ..._coinPositions.map((position) {
                return AnimatedBuilder(
                  animation: _coinController,
                  builder: (context, child) {
                    double t = _coinController.value;
                    // Coins move towards the XP bar (assumed at center bottom)
                    Offset targetPosition = Offset(
                      0, // Center horizontally
                      MediaQuery.of(context).size.height / 2 -
                          150, // Above XP bar
                    );
                    Offset currentPosition = Offset(
                      position.dx * (1 - t) + targetPosition.dx * t,
                      position.dy * (1 - t) + targetPosition.dy * t,
                    );

                    return Positioned(
                      left: currentPosition.dx +
                          MediaQuery.of(context).size.width / 2,
                      top: currentPosition.dy,
                      child: AnimatedOpacity(
                        opacity: t < 0.8
                            ? 1.0
                            : (1.0 - (t - 0.8) / 0.2), // Fade out near the end
                        duration: const Duration(milliseconds: 300),
                        child: Transform.rotate(
                          angle: t * 2 * pi, // Spin effect
                          child: const Icon(
                            Icons.monetization_on,
                            color: Colors.yellow,
                            size: 30,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
