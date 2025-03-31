import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'step_progress_indicator.dart';
import 'gender_selection.dart';
import 'package:fitsync_app/models/onboarding_data.dart';

class HeightPickerPage extends StatefulWidget {
  final OnboardingData? onboardingData; // Made nullable
  const HeightPickerPage({this.onboardingData, super.key}); // Removed required

  @override
  _HeightPickerPageState createState() => _HeightPickerPageState();
}

class _HeightPickerPageState extends State<HeightPickerPage>
    with TickerProviderStateMixin {
  int _selectedHeight = 170; // Default height
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

  Widget _buildHeightSelector() {
    return ListWheelScrollView.useDelegate(
      itemExtent: 60,
      perspective: 0.005,
      diameterRatio: 2.0,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: (index) {
        setState(() {
          _selectedHeight = 150 + index;
        });
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final height = 150 + index;
          return Center(
            child: Text(
              '$height',
              style: GoogleFonts.roboto(
                fontSize: height == _selectedHeight ? 48 : 32,
                fontWeight: height == _selectedHeight
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: height == _selectedHeight
                    ? const Color(0xFF7CBA3B)
                    : Colors.grey[400],
              ),
            ),
          );
        },
        childCount: 100,
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
    // Provide a default OnboardingData if null, to pass to GenderSelectionScreen
    final effectiveOnboardingData = widget.onboardingData ??
        OnboardingData(
          goal: 'Build Muscle',
          focusAreas: ['Chest', 'Legs'],
          experience: 'Beginner',
          workoutFrequency: 3,
        );

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
                            text: "Enter Your ",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            children: [
                              TextSpan(
                                text: "Height",
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
                          child: _buildHeightSelector(),
                        ),
                        const SizedBox(height: 60),
                        _buildButton(
                          text: "Save & Continue",
                          onPressed: () {
                            // Pass effectiveOnboardingData to GenderSelectionScreen
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => GenderSelectionScreen(
                                  onboardingData: effectiveOnboardingData,
                                ),
                              ),
                            );
                          },
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
