import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double? progressValue; // Optional parameter for animated progress
  final Color progressColor; // Add this to customize the progress bar color

  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.progressValue, // Optional parameter for animated progress
    this.progressColor = const Color(0xFF8ACA7A), // Default green color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step text (e.g., "Step 2 of 4")
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Step $currentStep of $totalSteps",
              style: GoogleFonts.roboto(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Spacing between text and progress bar
        // Progress bar
        SizedBox(
          height: 8, // Height of the progress bar
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4), // Rounded corners
            child: LinearProgressIndicator(
              value: progressValue ??
                  (currentStep / totalSteps), // Use progressValue if provided
              backgroundColor: Colors.grey[800], // Background color of the bar
              valueColor: AlwaysStoppedAnimation<Color>(progressColor), // Progress color
            ),
          ),
        ),
      ],
    );
  }
}