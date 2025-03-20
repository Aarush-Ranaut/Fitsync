import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoseWeightScreen extends StatefulWidget {
  @override
  _LoseWeightScreenState createState() => _LoseWeightScreenState();
}

class _LoseWeightScreenState extends State<LoseWeightScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  double? currentWeight;
  double? targetWeight;
  double? maintenanceCalories;
  double? dailyCalorieDeficit;
  double? dailyProtein;
  double? finalDailyCalorieGoal;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user data (current weight & maintenance calories) from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackBar("User not logged in.");
        return;
      }

      // Get current weight from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        currentWeight = (userDoc.data()?['weight'] as num?)?.toDouble();
      }

      // Get maintenance calories from Firestore
      final maintenanceDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("maintenance_data")
          .doc("maintenance")
          .get();

      maintenanceCalories = maintenanceDoc.exists
          ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
          : null;

      // Get previous weight loss goals
      final goalsSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("lose_weight_goals")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (goalsSnapshot.docs.isNotEmpty) {
        final data = goalsSnapshot.docs.first.data() as Map<String, dynamic>;

        _goalWeightController.text = data["targetWeight"]?.toString() ?? "";
        _durationController.text = data["goalDuration"]?.toString() ?? "";

        dailyCalorieDeficit = (data["dailyCalorieDeficit"] ?? 0).toDouble();
        dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
        finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error fetching data: ${e.toString()}");
    }
  }

  /// Calculate weight loss goals based on user input
  Future<void> _calculateLoseGoal() async {
    try {
      double? targetWeightInput = double.tryParse(_goalWeightController.text);
      int? months = int.tryParse(_durationController.text);

      if (targetWeightInput == null ||
          months == null ||
          months <= 0 ||
          maintenanceCalories == null ||
          currentWeight == null) {
        _showSnackBar("Please enter valid values.");
        return;
      }

      // Ensure target weight is lower than current weight
      if (targetWeightInput >= currentWeight!) {
        _showSnackBar("Target weight must be lower than current weight.");
        return;
      }

      // Calculate weight loss amount
      double weightLoss = currentWeight! - targetWeightInput;

      // 7700 kcal = 1kg of fat loss
      double totalCalorieDeficit = weightLoss * 7700;
      double dailyCalorieDeficit = totalCalorieDeficit / (months * 30);

      // Protein intake calculation (1.5g per kg of target weight)
      double dailyProteinIntake = targetWeightInput * 1.5;

      // Final daily calorie intake goal
      double calculatedFinalDailyCalorieGoal =
          maintenanceCalories! - dailyCalorieDeficit;

      setState(() {
        targetWeight = targetWeightInput;
        this.dailyCalorieDeficit = dailyCalorieDeficit;
        dailyProtein = dailyProteinIntake;
        finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
      });

      await _storeData(
        targetWeightInput,
        months,
        dailyCalorieDeficit,
        dailyProteinIntake,
        calculatedFinalDailyCalorieGoal,
      );
    } catch (e) {
      _showSnackBar("Error calculating goal.");
    }
  }

  /// Store weight loss goal in Firestore
  Future<void> _storeData(
    double targetWeight,
    int months,
    double dailyCalorieDeficit,
    double dailyProtein,
    double finalCalorieGoal,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("lose_weight_goals")
          .add({
        "targetWeight": targetWeight,
        "goalDuration": months,
        "dailyCalorieDeficit": dailyCalorieDeficit,
        "dailyProteinIntake": dailyProtein,
        "finalDailyCalorieGoal": finalCalorieGoal,
        "maintenanceCalories": maintenanceCalories,
        "currentWeight": currentWeight,
        "timestamp": FieldValue.serverTimestamp(),
      });

      _showSnackBar("Goal saved successfully!");
    } catch (e) {
      _showSnackBar("Error saving goal data.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lose Weight Plan")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Text(
                    "Create Your Weight Loss Plan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: _goalWeightController,
                    label: "Target Weight (kg)",
                    hint: "Enter your target weight",
                  ),
                  _buildInputField(
                    controller: _durationController,
                    label: "Duration (months)",
                    hint: "Enter timeline in months",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculateLoseGoal,
                    child: Text("Calculate Plan"),
                  ),
                  SizedBox(height: 30),
                  if (dailyCalorieDeficit != null &&
                      dailyProtein != null &&
                      finalDailyCalorieGoal != null)
                    _buildResultsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Your Daily Targets",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 15),
            _buildResultRow("Calorie Deficit:",
                "${dailyCalorieDeficit!.toStringAsFixed(1)} kcal"),
            _buildResultRow("Total Daily Calories:",
                "${finalDailyCalorieGoal!.toStringAsFixed(1)} kcal"),
            _buildResultRow(
                "Protein Intake:", "${dailyProtein!.toStringAsFixed(1)} g"),
            _buildResultRow(
                "Target Weight:", "${targetWeight!.toStringAsFixed(1)} kg"),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
