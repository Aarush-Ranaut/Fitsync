// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class GainWeightScreen extends StatefulWidget {
//   @override
//   _GainWeightScreenState createState() => _GainWeightScreenState();
// }

// class _GainWeightScreenState extends State<GainWeightScreen> {
//   final TextEditingController _goalWeightController = TextEditingController();
//   final TextEditingController _durationController = TextEditingController();

//   double? dailyCaloriesSurplus;
//   double? dailyProtein;
//   double? finalDailyCalorieGoal;
//   double? currentWeight;
//   double? targetWeight;
//   double? maintenanceCalories;
//   bool isLoading = true;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPreviousData();
//   }

//   Future<void> _fetchPreviousData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() => isLoading = false);
//         _showSnackbar("User not logged in.");
//         return;
//       }

//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         currentWeight = (userDoc.data()!['weight'] as num?)?.toDouble();
//       }

//       final maintenanceDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("maintenance_data")
//           .doc("maintenance")
//           .get();

//       maintenanceCalories = maintenanceDoc.exists
//           ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
//           : null;

//       final goalsSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("gain_weight_goals")
//           .orderBy("timestamp", descending: true)
//           .limit(1)
//           .get();

//       if (goalsSnapshot.docs.isNotEmpty) {
//         final data = goalsSnapshot.docs.first.data();

//         _goalWeightController.text = data["goalWeight"]?.toString() ?? "";
//         _durationController.text = data["goalDuration"]?.toString() ?? "";

//         dailyCaloriesSurplus = (data["dailyCalorieSurplus"] ?? 0).toDouble();
//         dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
//         finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
//         targetWeight = (data["targetWeight"] ?? 0).toDouble();
//       }

//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showSnackbar("Error fetching data: ${e.toString()}");
//     }
//   }

//   Future<void> _calculateGainGoal() async {
//     try {
//       final goalWeight = double.tryParse(_goalWeightController.text);
//       final months = int.tryParse(_durationController.text);

//       if (goalWeight == null || months == null || months <= 0) {
//         _showSnackbar("Please enter valid values.");
//         return;
//       }

//       if (currentWeight == null) {
//         _showSnackbar("Error: Current weight not found.");
//         return;
//       }

//       if (goalWeight <= currentWeight!) {
//         _showSnackbar(
//             "Target weight must be greater than your current weight.");
//         return;
//       }

//       targetWeight = goalWeight;

//       final totalExtraCalories = (targetWeight! - currentWeight!) * 7700;
//       final dailyExtraCalories = totalExtraCalories / (months * 30);
//       final dailyProteinIntake = targetWeight! * 2.2;
//       final calculatedFinalDailyCalorieGoal =
//           maintenanceCalories! + dailyExtraCalories;

//       setState(() {
//         dailyCaloriesSurplus = dailyExtraCalories;
//         dailyProtein = dailyProteinIntake;
//         finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
//       });

//       await _storeData(
//         goalWeight,
//         months,
//         dailyExtraCalories,
//         dailyProteinIntake,
//         calculatedFinalDailyCalorieGoal,
//         currentWeight!,
//         targetWeight!,
//       );
//     } catch (e) {
//       _showSnackbar("Calculation error: ${e.toString()}");
//     }
//   }

//   Future<void> _storeData(
//     double goalWeight,
//     int months,
//     double dailyCalories,
//     double dailyProtein,
//     double finalCalorieGoal,
//     double currentWeight,
//     double targetWeight,
//   ) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("gain_weight_goals")
//           .add({
//         "goalWeight": goalWeight,
//         "goalDuration": months,
//         "dailyCalorieSurplus": dailyCalories,
//         "dailyProteinIntake": dailyProtein,
//         "finalDailyCalorieGoal": finalCalorieGoal,
//         "currentWeight": currentWeight,
//         "targetWeight": targetWeight,
//         "maintenanceCalories": maintenanceCalories,
//         "timestamp": FieldValue.serverTimestamp(),
//       });

//       _showSnackbar("Goal saved successfully!");
//     } catch (e) {
//       _showSnackbar("Save failed: ${e.toString()}");
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Gain Weight Plan")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: ListView(
//                 children: [
//                   Text(
//                     "Create Your Weight Gain Plan",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   _buildInputField(
//                     controller: _goalWeightController,
//                     label: "Target Weight (kg)",
//                     hint: "Enter desired weight",
//                   ),
//                   _buildInputField(
//                     controller: _durationController,
//                     label: "Duration (months)",
//                     hint: "Enter timeline in months",
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _calculateGainGoal,
//                     child: Text("Calculate Plan"),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                   ),
//                   SizedBox(height: 30),
//                   if (dailyCaloriesSurplus != null &&
//                       dailyProtein != null &&
//                       finalDailyCalorieGoal != null)
//                     _buildResultsCard(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           border: OutlineInputBorder(),
//           filled: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildResultsCard() {
//     return Card(
//       elevation: 5,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Text(
//               "Your Daily Targets",
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue),
//             ),
//             SizedBox(height: 15),
//             _buildResultRow("Calorie Surplus:",
//                 "${dailyCaloriesSurplus!.toStringAsFixed(1)} kcal"),
//             _buildResultRow("Total Daily Calories:",
//                 "${finalDailyCalorieGoal!.toStringAsFixed(1)} kcal"),
//             _buildResultRow(
//                 "Protein Intake:", "${dailyProtein!.toStringAsFixed(1)} g"),
//             _buildResultRow(
//                 "Target Weight:", "${targetWeight!.toStringAsFixed(1)} kg"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontSize: 16)),
//           Text(value,
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

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

  double? dailyCaloriesSurplus;
  double? dailyProtein;
  double? finalDailyCalorieGoal;
  double? currentWeight;
  double? targetWeight;
  double? maintenanceCalories;
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? goalDocId;

  @override
  void initState() {
    super.initState();
    _fetchPreviousData();
  }

  Future<void> _fetchPreviousData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackbar("User not logged in.");
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        currentWeight = (userDoc.data()?['weight'] as num?)?.toDouble();
        goalDocId = userDoc.data()?['goal_doc']; // Retrieve stored goal doc ID
      }

      final maintenanceDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("maintenance_data")
          .doc("maintenance")
          .get();

      maintenanceCalories = maintenanceDoc.exists
          ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
          : null;

      if (goalDocId != null) {
        final goalDoc = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("calorie_goal")
            .doc(goalDocId)
            .get();

        if (goalDoc.exists) {
          final data = goalDoc.data()!;
          _goalWeightController.text = data["targetWeight"]?.toString() ?? "";
          _durationController.text = data["goalDuration"]?.toString() ?? "";
          dailyCaloriesSurplus = (data["dailyCalorieChange"] ?? 0).toDouble();
          dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
          finalDailyCalorieGoal =
              (data["finalDailyCalorieGoal"] ?? 0).toDouble();
          targetWeight = (data["targetWeight"] ?? 0).toDouble();
        }
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar("Error fetching data: ${e.toString()}");
    }
  }

  Future<void> _calculateGainGoal() async {
    try {
      final goalWeight = double.tryParse(_goalWeightController.text);
      final months = int.tryParse(_durationController.text);

      if (goalWeight == null || months == null || months <= 0) {
        _showSnackbar("Please enter valid values.");
        return;
      }

      if (currentWeight == null) {
        _showSnackbar("Error: Current weight not found.");
        return;
      }

      if (goalWeight <= currentWeight!) {
        _showSnackbar(
            "Target weight must be greater than your current weight.");
        return;
      }

      targetWeight = goalWeight;

      final totalExtraCalories = (targetWeight! - currentWeight!) * 7700;
      final dailyExtraCalories = totalExtraCalories / (months * 30);
      final dailyProteinIntake = targetWeight! * 2.2;
      final calculatedFinalDailyCalorieGoal =
          maintenanceCalories! + dailyExtraCalories;

      setState(() {
        dailyCaloriesSurplus = dailyExtraCalories;
        dailyProtein = dailyProteinIntake;
        finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
      });

      await _storeData(
        goalWeight,
        months,
        dailyExtraCalories,
        dailyProteinIntake,
        calculatedFinalDailyCalorieGoal,
        currentWeight!,
        targetWeight!,
      );
    } catch (e) {
      _showSnackbar("Calculation error: ${e.toString()}");
    }
  }

  Future<void> _storeData(
    double goalWeight,
    int months,
    double dailyCalories,
    double dailyProtein,
    double finalCalorieGoal,
    double currentWeight,
    double targetWeight,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final data = {
        "goalType": "gain",
        "targetWeight": goalWeight,
        "goalDuration": months,
        "dailyCalorieChange": dailyCalories,
        "dailyProteinIntake": dailyProtein,
        "finalDailyCalorieGoal": finalCalorieGoal,
        "currentWeight": currentWeight,
        "maintenanceCalories": maintenanceCalories,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // If goalDocId exists, update the existing document; otherwise, create a new one
      if (goalDocId != null) {
        await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("calorie_goal")
            .doc(goalDocId)
            .set(data);
      } else {
        final newDocRef = await _firestore
            .collection("users")
            .doc(user.uid)
            .collection("calorie_goal")
            .add(data);

        // Save the document ID in the user's main document
        await _firestore.collection("users").doc(user.uid).update({
          "goal_doc": newDocRef.id,
        });

        goalDocId = newDocRef.id;
      }

      _showSnackbar("Goal saved successfully!");
    } catch (e) {
      _showSnackbar("Save failed: ${e.toString()}");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gain Weight Plan")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Text(
                    "Create Your Weight Gain Plan",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: _goalWeightController,
                    label: "Target Weight (kg)",
                    hint: "Enter desired weight",
                  ),
                  _buildInputField(
                    controller: _durationController,
                    label: "Duration (months)",
                    hint: "Enter timeline in months",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculateGainGoal,
                    child: Text("Calculate Plan"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  SizedBox(height: 30),
                  if (dailyCaloriesSurplus != null &&
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
            Text("Your Daily Targets",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
            _buildResultRow("Calorie Surplus:",
                "${dailyCaloriesSurplus!.toStringAsFixed(1)} kcal"),
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
