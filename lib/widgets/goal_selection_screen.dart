import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import './focus_area_selection.dart';

class GoalSelectionScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  final double maintenanceCalories;
  final double bodyWeight;

  const GoalSelectionScreen({
    required this.onboardingData,
    required this.maintenanceCalories,
    required this.bodyWeight,
    super.key,
  });

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedGoal = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // App theme colors
  final Color primaryGreen = const Color(0xFF7CBA3B); // Green for buttons
  final Color bgDark = const Color(0xFF121212); // Dark background
  final Color cardDark = const Color(0xFF1E1E1E); // Card background

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildGoalCard(String title, String description, IconData icon) {
    final isSelected = selectedGoal == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = title;
        });
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          // Reduced height or make it flexible
          // height: 100,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey[800]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryGreen.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryGreen : Colors.grey[400],
                size: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Reduced font size
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 12, // Reduced font size
                        color: Colors.grey[400],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: primaryGreen,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              primaryGreen.withOpacity(0.8),
              primaryGreen,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedGoal.isNotEmpty
              ? () {
                  widget.onboardingData.goal = selectedGoal;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FocusAreaScreen(
                        onboardingData: widget.onboardingData,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            "Next",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgDark,
        appBarTheme: AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "What is your main goal?",
            style: GoogleFonts.poppins(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Reduced padding
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Added mainAxisSize: MainAxisSize.min
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGoalCard(
                        "Build Muscle",
                        "Increase muscle mass and strength.",
                        Icons.fitness_center,
                      ),
                      _buildGoalCard(
                        "Lose Weight",
                        "Reduce body fat and improve fitness.",
                        Icons.monitor_weight,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildNextButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
