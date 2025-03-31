import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/Camera_integrate.dart';
import '../screens/community_screen.dart';
import '../widgets/calorie_tracker.dart';
import '../widgets/maintenance_calorie_screen.dart';
import '../widgets/home_screen.dart';
import 'package:fitsync_app/models/onboarding_data.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({super.key});

  Future<bool> _checkCalorieGoalExists() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return false;
      }

      var calorieGoalSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("calorie_goal")
          .limit(1)
          .get();

      return calorieGoalSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking calorie goal: $e");
      return false;
    }
  }

  void _handleTrackCalories(BuildContext context) async {
    try {
      bool goalExists = await _checkCalorieGoalExists();
      if (goalExists) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CalorieTracker()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MaintenanceCalorieScreen()),
        );
      }
    } catch (e) {
      print("Error in _handleTrackCalories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error tracking calories: $e")),
      );
    }
  }

  void _handleBackButton(BuildContext context) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Normal back navigation
      } else {
        // Redirect to HomeScreen with default OnboardingData if no previous screens
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              onboardingData: OnboardingData(
                goal: 'Maintain', // Default value
                focusAreas: ['Full Body'], // Default value
                experience: 'Beginner', // Default value
                workoutFrequency: 3, // Default value
              ),
              showEnergyDialog: () {},
            ),
          ),
          (route) => false, // Clear stack and set HomeScreen as root
        );
      }
    } catch (e) {
      print("Error in _handleBackButton: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error navigating back: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton(context);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Exercise"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackButton(context), // Custom back button
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PoseScreen(exercise: 1)),
                    );
                  } catch (e) {
                    print("Error navigating to Exercise 1: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Exercise 1"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PoseScreen(exercise: 2)),
                    );
                  } catch (e) {
                    print("Error navigating to Exercise 2: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Exercise 2"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityScreen()),
                    );
                  } catch (e) {
                    print("Error navigating to Community: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Open Community"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleTrackCalories(context),
                child: const Text("Track Calories"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MaintenanceCalorieScreen()),
                    );
                  } catch (e) {
                    print("Error navigating to Maintenance Calories: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Calculate Maintenance Calories"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
