import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import './workout_plan_screen.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const WorkoutFrequencyScreen({required this.onboardingData, super.key});

  @override
  _WorkoutFrequencyScreenState createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen>
    with SingleTickerProviderStateMixin {
  int selectedFrequency = 3; // Default value
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize the fade animation for the screen
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Workout Frequency",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "How often do you want to work out each week?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildFrequencySelector(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    const double minValue = 1;
    const double maxValue = 7;
    const int divisions = 6; // This ensures step size of 1 (7-1)/6 = 1

    // Ensure the selectedFrequency is within bounds
    if (selectedFrequency < minValue.toInt()) {
      selectedFrequency = minValue.toInt();
    } else if (selectedFrequency > maxValue.toInt()) {
      selectedFrequency = maxValue.toInt();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8ACA7A), // Green for selected value
          ),
          child: Text('$selectedFrequency'),
        ),
        const SizedBox(height: 8),
        Text(
          "time${selectedFrequency == 1 ? '' : 's'} / week",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Slider(
            value: selectedFrequency.toDouble(),
            min: minValue,
            max: maxValue,
            divisions: divisions, // Ensure divisions is positive
            label:
                "$selectedFrequency time${selectedFrequency == 1 ? '' : 's'} / week",
            activeColor: const Color(0xFF8ACA7A),
            inactiveColor: Colors.grey[700],
            onChanged: (value) {
              setState(() {
                selectedFrequency = value.toInt();
              });
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Frequency display
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              "$selectedFrequency time${selectedFrequency == 1 ? '' : 's'} / week",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),

          // Continue button
          ElevatedButton(
            onPressed: () {
              widget.onboardingData.workoutFrequency = selectedFrequency;

              // Add haptic feedback
              HapticFeedback.mediumImpact();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WorkoutPlanScreen(onboardingData: widget.onboardingData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8ACA7A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Container(
              width: double.infinity,
              child: Text(
                "Continue",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
