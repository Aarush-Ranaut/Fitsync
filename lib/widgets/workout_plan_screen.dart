import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import './home_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const WorkoutPlanScreen({required this.onboardingData, super.key});

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen>
    with SingleTickerProviderStateMixin {
  late Map<int, String> workoutPlan;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _cardAnimations;
  bool _isLoading = true;

  // Fake progress dialog state
  double _progressValue = 0.0;
  String _progressMessage = "Fetch user data...";
  bool _showFakeProgressDialog = true;

  @override
  void initState() {
    super.initState();
    workoutPlan = generateWorkoutPlan(widget.onboardingData);
    _initializeAnimations();
    _startFakeProgress();
  }

  void _initializeAnimations() {
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize the fade animation for the screen
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Initialize staggered animations for the cards
    _cardAnimations = List.generate(
      workoutPlan.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.1), // Staggered delay for each card
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    // Start the animation after loading
  }

  void _startFakeProgress() {
    const totalDuration = 5; // Total duration in seconds
    const steps = [
      "Fetch user data...",
      "Analyzing preferences...",
      "Generating plan...",
      "Finalizing details..."
    ];
    int currentStep = 0;

    // Show the dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildFakeProgressDialog(),
      );
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progressValue += 0.02; // Increment progress
        if (_progressValue >= (currentStep + 1) / steps.length) {
          currentStep++;
          if (currentStep < steps.length) {
            _progressMessage = steps[currentStep];
          }
        }

        if (_progressValue >= 1.0) {
          timer.cancel();
          _showFakeProgressDialog = false;
          if (mounted) {
            Navigator.pop(context); // Close the dialog
            setState(() {
              _isLoading = false;
            });
            _animationController.forward(); // Start the animations
          }
        }
      });
    });
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
          "Your Workout Plan",
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
        child: _isLoading
            ? const SizedBox.shrink() // Dialog is shown, no need for content
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "Here’s your personalized workout plan based on your preferences",
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
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: workoutPlan.length,
                        itemBuilder: (context, index) {
                          int day = index + 1;
                          return FadeTransition(
                            opacity: _cardAnimations[index],
                            child: Transform.translate(
                              offset: Offset(
                                  0, 20 * (1 - _cardAnimations[index].value)),
                              child:
                                  _buildWorkoutDayCard(day, workoutPlan[day]!),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildFakeProgressDialog() {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            const Icon(
              Icons.fitness_center,
              color: Color(0xFF89F336),
              size: 40,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              "Building Your Plan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // Progress message
            Text(
              _progressMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Circular progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.grey[700],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF89F336)),
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  "${(_progressValue * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subtle animation dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: index < (_progressValue * 3).toInt()
                        ? const Color(0xFF89F336)
                        : Colors.grey[700],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutDayCard(int day, String routine) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background gradient overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day and Routine
                Text(
                  "Day $day: $routine",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                // Exercise thumbnails
                _exerciseThumbnails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _exerciseThumbnails() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(4, (index) => _exerciseImage()),
      ),
    );
  }

  Widget _exerciseImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          "assets/exercise.png",
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.fitness_center,
                color: Colors.white54,
                size: 30,
              ),
            );
          },
        ),
      ),
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
          // Plan summary
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              "${workoutPlan.length} day${workoutPlan.length == 1 ? '' : 's'} of workouts planned",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),

          // Confirm Plan button
          ElevatedButton(
            onPressed: () {
              // Add haptic feedback
              HapticFeedback.mediumImpact();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(onboardingData: widget.onboardingData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF89F336),
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
                "Confirm Plan",
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

  Map<int, String> generateWorkoutPlan(OnboardingData data) {
    // Example predefined workout plans (You can modify this logic)
    List<String> muscleGroups = data.focusAreas;
    int days = data.workoutFrequency;

    Map<int, String> plan = {};
    for (int i = 0; i < days; i++) {
      plan[i + 1] = "${muscleGroups[i % muscleGroups.length]} Routine";
    }
    return plan;
  }
}
