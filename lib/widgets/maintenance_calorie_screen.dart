import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../services/calorie_calculator.dart';
import 'goal_selection_screen.dart'; // Import the new page

class MaintenanceCalorieScreen extends StatefulWidget {
  @override
  _MaintenanceCalorieScreenState createState() =>
      _MaintenanceCalorieScreenState();
}

class _MaintenanceCalorieScreenState extends State<MaintenanceCalorieScreen> {
  final CalorieCalculator _calculator = CalorieCalculator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double? bmr;
  double? maintenanceCalories;
  double? lowerBound;
  double? upperBound;
  double? userWeight;
  bool isLoading = true;
  String? selectedActivityLevel;
  bool isFirstTimeUser =
      false; // Track if user is using the feature for the first time

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
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in.")),
        );
        return;
      }

      // Fetch BMR and weight
      Map<String, dynamic>? userData =
          await _calculator.fetchUserData(user.uid);

      if (userData == null ||
          userData['bmr'] == null ||
          userData['weight'] == null) {
        setState(() {
          isLoading = false;
          isFirstTimeUser = true; // User has no previous data
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Welcome! Please select your activity level and calculate your calories.")),
        );
        return;
      }

      // Fetch stored calorie data
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();

      if (!userDoc.exists) {
        // First time user, set default values
        setState(() {
          bmr = userData['bmr'];
          userWeight = userData['weight'];
          isFirstTimeUser = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "No previous data found. Please enter details and calculate your calories.")),
        );
      } else {
        // Fetch available values and set defaults for missing ones
        setState(() {
          bmr = userData['bmr'];
          userWeight = userData['weight'];
          maintenanceCalories = userDoc["maintenanceCalories"] ?? null;
          lowerBound = userDoc["lowerBound"] ?? null;
          upperBound = userDoc["upperBound"] ?? null;
          selectedActivityLevel = userDoc["selectedActivityLevel"] ?? null;
          isFirstTimeUser = false;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Previous data loaded successfully!")),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error fetching user data. Please try again later.")),
      );
    }
  }

  Future<void> _calculateFinalCalories() async {
    if (bmr == null || selectedActivityLevel == null || userWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an activity level.")),
      );
      return;
    }

    double activityFactor;
    switch (selectedActivityLevel) {
      case "Sedentary (little to no exercise)":
        activityFactor = 1.2;
        break;
      case "Lightly active (1-3 days per week)":
        activityFactor = 1.375;
        break;
      case "Moderately active (3-5 days per week)":
        activityFactor = 1.55;
        break;
      case "Very active (6-7 days per week)":
        activityFactor = 1.725;
        break;
      case "Super active (intense exercise daily)":
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55; // Default to moderate
    }

    double estimatedCalories = bmr! * activityFactor;
    lowerBound = estimatedCalories * 0.95;
    upperBound = estimatedCalories * 1.05;

    setState(() {
      maintenanceCalories = estimatedCalories;
    });

    // Store calculated values in Firebase Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection("users").doc(user.uid).set({
        "maintenanceCalories": estimatedCalories,
        "lowerBound": lowerBound,
        "upperBound": upperBound,
        "selectedActivityLevel": selectedActivityLevel,
      }, SetOptions(merge: true));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Estimated Maintenance Calories: ${lowerBound!.toStringAsFixed(2)} - ${upperBound!.toStringAsFixed(2)} kcal",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maintenance Calories")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isFirstTimeUser
                          ? "Welcome! Please select your activity level and calculate your calories."
                          : "Your estimated BMR: ${bmr!.toStringAsFixed(2)} kcal",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Select your activity level:",
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: selectedActivityLevel,
                      hint: Text("Choose Activity Level"),
                      items: activityLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedActivityLevel = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateFinalCalories,
                      child: Text("Calculate Maintenance Calories"),
                    ),
                    SizedBox(height: 20),
                    if (maintenanceCalories != null)
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Final Maintenance Calories:",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${lowerBound!.toStringAsFixed(2)} - ${upperBound!.toStringAsFixed(2)} kcal",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoalSelectionScreen(
                                    maintenanceCalories: maintenanceCalories!,
                                    bodyWeight: userWeight!,
                                  ),
                                ),
                              );
                            },
                            child: Text("Next"),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
