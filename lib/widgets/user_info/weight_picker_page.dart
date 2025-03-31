import 'package:fitsync_app/models/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';
import 'step_progress_indicator.dart'; // Import the reusable widget
import 'height_picker_page.dart';

class WeightPickerPage extends StatefulWidget {
  const WeightPickerPage({super.key, required OnboardingData onboardingData});

  @override
  _WeightPickerPageState createState() => _WeightPickerPageState();
}

class _WeightPickerPageState extends State<WeightPickerPage>
    with TickerProviderStateMixin {
  int _selectedWeight = 70; // Default weight
  final int _currentStep = 2; // This is step 2 in the flow
  final int _totalSteps = 4; // Total steps in the onboarding process

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _buttonColorAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the screen entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );

    // Initialize the button color animation
    _buttonColorAnimation = ColorTween(
      begin: const Color(0xFF7CBA3B),
      end: const Color.fromARGB(255, 65, 174, 69),
    ).animate(_animationController);

    // Initialize the progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(begin: 1 / 4, end: 2 / 4).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Start the animations
    _animationController.forward();
    _progressController.forward();

    // Fetch existing weight data
    _fetchWeightData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeightData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data['weight'] != null) {
            setState(() {
              _selectedWeight = data['weight'];
            });
          }
        }
      } catch (e) {
        _showSnackBar("Error fetching weight data: $e");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _syncWeightData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        // Save or update the weight in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'weight': _selectedWeight,
        });

        _showSnackBar("Weight saved successfully!");

        // Redirect to the next page after saving
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HeightPickerPage(), // Replace with your desired page
          ),
        );
      } catch (e) {
        _showSnackBar("Error saving weight data: $e");
      }
    } else {
      _showSnackBar("User not logged in.");
    }
  }

  Widget _buildWeightSelector() {
    return ListWheelScrollView.useDelegate(
      itemExtent: 50,
      perspective: 0.01,
      diameterRatio: 1.5,
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedWeight = index + 40; // Adjust the range as needed
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final weight = index + 40; // Adjust the range as needed
          return Center(
            child: Text(
              '$weight',
              style: GoogleFonts.roboto(
                fontSize: weight == _selectedWeight ? 48 : 32,
                fontWeight: weight == _selectedWeight
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: weight == _selectedWeight
                    ? const Color(0xFF7CBA3B)
                    : Colors.grey[400],
              ),
            ),
          );
        },
        childCount: 141, // Adjust the count based on the range
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7CBA3B).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CBA3B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return StepProgressIndicator(
                              currentStep: _currentStep,
                              totalSteps: _totalSteps,
                              progressValue: _progressAnimation.value,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        // Title with highlighted "Weight" text
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Enter Your ",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: "Weight",
                                style: GoogleFonts.roboto(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF7CBA3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          height: 200,
                          child: _buildWeightSelector(),
                        ),
                        const SizedBox(height: 60),
                        _buildButton(
                          text: "Save & Continue",
                          onPressed: _syncWeightData,
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
    );
  }
}
