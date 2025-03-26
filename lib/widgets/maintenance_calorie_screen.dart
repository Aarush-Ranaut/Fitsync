import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/calorie_calculator.dart';
import 'goal_selection_screen.dart';

class MaintenanceCalorieScreen extends StatefulWidget {
  @override
  _MaintenanceCalorieScreenState createState() =>
      _MaintenanceCalorieScreenState();
}

class _MaintenanceCalorieScreenState extends State<MaintenanceCalorieScreen> {
  final CalorieCalculator _calculator = CalorieCalculator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double? bmr, maintenanceCalories, lowerBound, upperBound, userWeight;
  bool isLoading = true, isFirstTimeUser = false;
  String? selectedActivityLevel;

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

  // Modified _fetchUserData method
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

  // Rest of the code remains the same...
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

    _showSnackBar(
      "Estimated Maintenance Calories: ${lowerBound?.toStringAsFixed(2) ?? 'N/A'} - ${upperBound?.toStringAsFixed(2) ?? 'N/A'} kcal",
    );
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                          : (bmr != null
                              ? "Your estimated BMR: ${bmr!.toStringAsFixed(2)} kcal"
                              : "BMR not available"),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text("Select your activity level:",
                        style: TextStyle(fontSize: 16)),
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
                          maintenanceCalories = null;
                          lowerBound = null;
                          upperBound = null;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _calculateFinalCalories,
                      child: Text("Calculate Maintenance Calories"),
                    ),
                    if (maintenanceCalories != null) ...[
                      SizedBox(height: 30),
                      Text(
                        'Your Maintenance Calories:',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${maintenanceCalories!.toStringAsFixed(2)} kcal',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Daily Range: ${lowerBound!.toStringAsFixed(2)} - ${upperBound!.toStringAsFixed(2)} kcal',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GoalSelectionScreen(
                                maintenanceCalories: maintenanceCalories!,
                                bodyWeight: userWeight ?? 0.0, // Proper double
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Continue to Goals',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
      ),
    );
  }
}
