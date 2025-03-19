import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GainWeightScreen extends StatefulWidget {
  @override
  _GainWeightScreenState createState() => _GainWeightScreenState();
}

class _GainWeightScreenState extends State<GainWeightScreen> {
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _maintenanceCaloriesController =
      TextEditingController();

  double? dailyCaloriesSurplus;
  double? dailyProtein;
  double? finalGoalWeight;
  double? finalDailyCalorieGoal;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchPreviousData();
  }

  Future<void> _fetchPreviousData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackbar("User not logged in.");
        return;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        setState(() => isLoading = false);
        return;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        _goalWeightController.text = data["goalWeight"]?.toString() ?? "";
        _durationController.text = data["goalDuration"]?.toString() ?? "";
        _maintenanceCaloriesController.text =
            data["maintenanceCalories"]?.toString() ?? "";
        dailyCaloriesSurplus = (data["dailyCalorieSurplus"] ?? 0).toDouble();
        dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
        finalGoalWeight = (data["finalGoalWeight"] ?? 0).toDouble();
        finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
        isLoading = false;
      });

      _showSnackbar("Previous goal data loaded successfully!");
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar("Error fetching previous data.");
    }
  }

  Future<void> _calculateGainGoal() async {
    try {
      double? goalWeight = double.tryParse(_goalWeightController.text);
      int? months = int.tryParse(_durationController.text);
      double? maintenanceCalories =
          double.tryParse(_maintenanceCaloriesController.text);

      if (goalWeight == null ||
          months == null ||
          months <= 0 ||
          maintenanceCalories == null) {
        _showSnackbar("Please enter valid values.");
        return;
      }

      // Assuming 7700 kcal = 1kg gain
      double totalExtraCalories = goalWeight * 7700;
      double dailyExtraCalories = totalExtraCalories / (months * 30);

      // Protein intake calculation (2.2g per kg)
      double dailyProteinIntake = goalWeight * 2.2;

      // Final calorie intake goal
      double calculatedFinalDailyCalorieGoal =
          maintenanceCalories + dailyExtraCalories;

      setState(() {
        dailyCaloriesSurplus = dailyExtraCalories;
        dailyProtein = dailyProteinIntake;
        finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
      });

      await _storeData(goalWeight, months, dailyExtraCalories,
          dailyProteinIntake, calculatedFinalDailyCalorieGoal);
    } catch (e) {
      _showSnackbar("Error calculating goal.");
    }
  }

  Future<void> _storeData(double goalWeight, int months, double dailyCalories,
      double dailyProtein, double finalCalorieGoal) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar("User not logged in.");
        return;
      }

      await _firestore.collection("users").doc(user.uid).set({
        "goalWeight": goalWeight,
        "goalDuration": months,
        "dailyCalorieSurplus": dailyCalories,
        "dailyProteinIntake": dailyProtein,
        "finalDailyCalorieGoal": finalCalorieGoal,
      }, SetOptions(merge: true));

      _showSnackbar("Goal data saved successfully!");
    } catch (e) {
      _showSnackbar("Error saving goal data.");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gain Weight")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "Enter your weight gain goal (kg), duration (months), and maintenance calories:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  SizedBox(height: 20),
                  TextField(
                    controller: _goalWeightController,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: "Target weight gain (kg)"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Duration (months)"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _calculateGainGoal,
                    child: Text("Calculate Daily Goals"),
                  ),
                  SizedBox(height: 20),
                  if (dailyCaloriesSurplus != null &&
                      dailyProtein != null &&
                      finalDailyCalorieGoal != null)
                    Column(
                      children: [
                        Text(
                          "Daily Calorie Surplus: ${dailyCaloriesSurplus!.toStringAsFixed(2)} kcal\n"
                          "Final Daily Calorie Goal: ${finalDailyCalorieGoal!.toStringAsFixed(2)} kcal\n"
                          "Daily Protein Intake: ${dailyProtein!.toStringAsFixed(2)} g",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
