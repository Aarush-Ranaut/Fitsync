import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'calorie_tracker.dart';

class MaintainWeightScreen extends StatelessWidget {
  final double maintenanceCalories;
  final double bodyWeight;

  const MaintainWeightScreen({
    required this.maintenanceCalories,
    required this.bodyWeight,
  });

  Future<void> _storeData(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final dailyProtein = bodyWeight * 1.5; // Calculate protein intake

      final data = {
        "goalType": "maintain",
        "finalDailyCalorieGoal": maintenanceCalories,
        "dailyProteinIntake": dailyProtein,
        "maintenanceCalories": maintenanceCalories,
        "currentWeight": bodyWeight,
        "date": currentDate,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("calorie_goal")
          .doc(currentDate)
          .set(data, SetOptions(merge: true));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CalorieTracker()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error saving maintenance goal: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maintain Weight Plan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      "Your Maintenance Plan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildInfoRow("Daily Calorie Goal:",
                        "${maintenanceCalories.toStringAsFixed(0)} kcal"),
                    _buildInfoRow("Daily Protein Intake:",
                        "${(bodyWeight * 1.5).toStringAsFixed(1)} g"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _storeData(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Text("Confirm and Start Tracking"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
