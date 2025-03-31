import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'step_progress_indicator.dart';
import 'package:fitsync_app/widgets/goal_selection_screen.dart';
import 'package:fitsync_app/constant.dart';
import 'package:fitsync_app/models/onboarding_data.dart';

class GenderSelectionScreen extends StatefulWidget {
  final OnboardingData? onboardingData; // Nullable to handle upstream null
  const GenderSelectionScreen({this.onboardingData, super.key});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedGender;
  final int _currentStep = 3;
  final int _totalSteps = 4;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnimation = Tween<double>(begin: 2 / 4, end: 3 / 4).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _saveGender() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (selectedGender != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'gender': selectedGender,
        });

        final baseOnboardingData = widget.onboardingData ??
            OnboardingData(
              goal: 'Maintain',
              focusAreas: ['Full Body'],
              experience: 'Beginner',
              workoutFrequency: 3,
            );

        final updatedOnboardingData = OnboardingData(
          goal: baseOnboardingData.goal ?? 'Maintain',
          focusAreas: baseOnboardingData.focusAreas ?? ['Full Body'],
          experience: baseOnboardingData.experience ?? 'Beginner',
          workoutFrequency: baseOnboardingData.workoutFrequency ?? 3,
          gender: selectedGender,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gender saved successfully!")),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GoalSelectionScreen(
              onboardingData: updatedOnboardingData,
              maintenanceCalories: 0.0, // Default instead of null
              bodyWeight: 0.0, // Default instead of null
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving gender: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender.")),
      );
    }
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
                              progressColor: const Color(0xFF7CBA3B),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Select Your ",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: "Gender",
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = "Male";
                                });
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: selectedGender == "Male"
                                        ? const Color(0xFF7CBA3B)
                                        : Colors.grey[800],
                                    child: const Icon(
                                      Icons.male,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Male",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedGender = "Female";
                                });
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: selectedGender == "Female"
                                        ? const Color(0xFF7CBA3B)
                                        : Colors.grey[800],
                                    child: const Icon(
                                      Icons.female,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Female",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveGender,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7CBA3B),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Continue",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
    );
  }
}
