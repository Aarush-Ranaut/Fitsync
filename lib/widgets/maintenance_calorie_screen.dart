import 'package:fitsync_app/widgets/calorie_calculator.dart';
import 'package:fitsync_app/widgets/goal_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calorie_calculator.dart';
import 'package:fitsync_app/models/onboarding_data.dart'; // Import OnboardingData

class MaintenanceCalorieScreen extends StatefulWidget {
  @override
  _MaintenanceCalorieScreenState createState() =>
      _MaintenanceCalorieScreenState();
}

class _MaintenanceCalorieScreenState extends State<MaintenanceCalorieScreen>
    with TickerProviderStateMixin {
  final CalorieCalculator _calculator = CalorieCalculator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double? bmr, maintenanceCalories, lowerBound, upperBound, userWeight;
  bool isLoading = true, isFirstTimeUser = false;
  String? selectedActivityLevel;
  OnboardingData? onboardingData; // Add OnboardingData variable

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days per week)",
    "Moderately active (3-5 days per week)",
    "Very active (6-7 days per week)",
    "Super active (intense exercise daily)"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackBar("User not logged in.");
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        setState(() {
          isLoading = false;
          isFirstTimeUser = true;
        });
        _showSnackBar("Complete your profile to calculate calories");
        return;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Parse birth date
      DateTime? birthDate;
      if (userData?['birthDate'] != null) {
        if (userData!['birthDate'] is Timestamp) {
          birthDate = (userData['birthDate'] as Timestamp).toDate();
        } else {
          birthDate = DateTime.parse(userData!['birthDate'].toString());
        }
      }

      // Calculate age
      int calculatedAge = 0;
      if (birthDate != null) {
        final now = DateTime.now();
        calculatedAge = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          calculatedAge--;
        }
      }

      // Get other data
      double parsedWeight = userData?['weight']?.toDouble() ?? 0.0;
      double parsedHeight = userData?['height']?.toDouble() ?? 0.0;
      String parsedGender = userData?['gender']?.toString() ?? '';

      // Fetch OnboardingData fields
      String goal = userData?['goal']?.toString() ?? 'Build Muscle';
      List<String> focusAreas = (userData?['focusAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Chest', 'Legs'];
      String experience = userData?['experience']?.toString() ?? 'Beginner';
      int workoutFrequency = userData?['workoutFrequency']?.toInt() ?? 3;

      bool hasEssentialData = parsedWeight > 0 &&
          parsedHeight > 0 &&
          calculatedAge > 0 &&
          parsedGender.isNotEmpty;

      if (!hasEssentialData) {
        _showSnackBar("Missing profile data. Please check:");
        print("""
      Missing Data:
      Weight: $parsedWeight
      Height: $parsedHeight
      Calculated Age: $calculatedAge (from birthDate: ${birthDate?.toIso8601String()})
      Gender: $parsedGender
      """);
        setState(() => isLoading = false);
        return;
      }

      // Set OnboardingData
      onboardingData = OnboardingData(
        goal: goal,
        focusAreas: focusAreas,
        experience: experience,
        workoutFrequency: workoutFrequency,
      );

      // Check if BMR exists in Firestore
      if (userData?['bmr'] != null) {
        setState(() {
          bmr = userData!['bmr']?.toDouble();
          userWeight = parsedWeight;
          isLoading = false;
        });
      } else {
        // Calculate BMR if missing
        Map<String, dynamic>? calculatedData =
            await _calculator.fetchUserData();

        if (calculatedData == null) {
          _showSnackBar("Calculation failed. Check profile data.");
          setState(() => isLoading = false);
          return;
        }

        await _firestore.collection("users").doc(user.uid).set({
          'bmr': calculatedData['bmr'],
          'weight': calculatedData['weight'],
        }, SetOptions(merge: true));

        setState(() {
          bmr = calculatedData['bmr'];
          userWeight = calculatedData['weight'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error in _fetchUserData: $e");
      _showSnackBar("Error loading data: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

  Future<void> _calculateFinalCalories() async {
    if (bmr == null || bmr == 0.0) {
      _showSnackBar("BMR data is missing. Please update your details.");
      return;
    }

    if (selectedActivityLevel == null) {
      _showSnackBar("Please select an activity level.");
      return;
    }

    double activityFactor = _getActivityFactor(selectedActivityLevel!);
    double estimatedCalories = bmr! * activityFactor;
    lowerBound = estimatedCalories * 0.95;
    upperBound = estimatedCalories * 1.05;

    setState(() {
      maintenanceCalories = estimatedCalories;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("maintenance_data")
          .doc("maintenance")
          .set({
        "maintenanceCalories": estimatedCalories,
        "lowerBound": lowerBound,
        "upperBound": upperBound,
        "selectedActivityLevel": selectedActivityLevel,
        "timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  double _getActivityFactor(String level) {
    switch (level) {
      case "Sedentary (little to no exercise)":
        return 1.2;
      case "Lightly active (1-3 days per week)":
        return 1.375;
      case "Moderately active (3-5 days per week)":
        return 1.55;
      case "Very active (6-7 days per week)":
        return 1.725;
      case "Super active (intense exercise daily)":
        return 1.9;
      default:
        return 1.55;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color gradientStart = const Color(0xFF8ACA7A),
    Color gradientEnd = const Color(0xFF5CB85C),
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientStart.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Maintenance Calories",
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(const Color(0xFF8ACA7A)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 60,
                            color: const Color(0xFF8ACA7A),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Calculate Your Maintenance Calories",
                            style: GoogleFonts.roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Determine how many calories you need to maintain your current weight.",
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            "Select Your Activity Level:",
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: const Color(0xFF8ACA7A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8ACA7A).withOpacity(0.5),
                                width: 1.5,
                              ),
                              color: const Color(0xFF1E1E1E),
                            ),
                            child: DropdownButton<String>(
                              value: selectedActivityLevel,
                              hint: Text(
                                "Choose Activity Level",
                                style: GoogleFonts.roboto(
                                  color: Colors.grey[400],
                                ),
                              ),
                              items: activityLevels.map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Text(
                                    level,
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedActivityLevel = value;
                                  maintenanceCalories = null;
                                  lowerBound = null;
                                  upperBound = null;
                                });
                              },
                              dropdownColor: const Color(0xFF1E1E1E),
                              underline: const SizedBox(),
                              isExpanded: true,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: const Color(0xFF8ACA7A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildButton(
                            text: "Calculate Maintenance Calories",
                            onPressed: _calculateFinalCalories,
                            icon: Icons.calculate,
                          ),
                          if (maintenanceCalories != null) ...[
                            const SizedBox(height: 32),
                            Card(
                              elevation: 4,
                              color: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Your Maintenance Calories",
                                      style: GoogleFonts.roboto(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF8ACA7A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "${maintenanceCalories!.toStringAsFixed(2)} kcal",
                                      style: GoogleFonts.roboto(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Daily Range: ${lowerBound!.toStringAsFixed(2)} - ${upperBound!.toStringAsFixed(2)} kcal",
                                      style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildButton(
                              text: "Continue to Goals",
                              onPressed: () {
                                if (onboardingData == null) {
                                  _showSnackBar(
                                      "Onboarding data not loaded yet.");
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoalSelectionScreen(
                                      maintenanceCalories: maintenanceCalories!,
                                      bodyWeight: userWeight ?? 0.0,
                                      onboardingData: onboardingData!,
                                    ),
                                  ),
                                );
                              },
                              icon: Icons.arrow_forward,
                              gradientStart: const Color(0xFF5CB85C),
                              gradientEnd: const Color(0xFF8ACA7A),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
