import 'package:flutter/material.dart';

class MaintainWeightScreen extends StatelessWidget {
  final double maintenanceCalories;
  final double bodyWeight;

  MaintainWeightScreen({required this.maintenanceCalories, required this.bodyWeight});

  @override
  Widget build(BuildContext context) {
    double dailyProtein = bodyWeight * 1.6; // Recommended protein intake for maintenance

    return Scaffold(
      appBar: AppBar(title: Text("Maintain Weight")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "To maintain your current weight:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Daily Caloric Intake: ${maintenanceCalories.toStringAsFixed(2)} kcal\n"
                "Recommended Protein Intake: ${dailyProtein.toStringAsFixed(2)} g",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
