import 'package:flutter/material.dart';
import 'gain_weight.dart';
import 'lose_weight.dart';
import 'maintain_weight.dart';

class GoalSelectionScreen extends StatelessWidget {
  final double maintenanceCalories;
  final double
      bodyWeight; // Used for protein calculation in MaintainWeightScreen

  GoalSelectionScreen(
      {required this.maintenanceCalories, required this.bodyWeight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Your Goal")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "What is your goal?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GainWeightScreen()),
                  );
                },
                child: Text("Gain Weight"),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoseWeightScreen()),
                  );
                },
                child: Text("Lose Weight"),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintainWeightScreen(
                        maintenanceCalories: maintenanceCalories,
                        bodyWeight: bodyWeight,
                      ),
                    ),
                  );
                },
                child: Text("Maintain Weight"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
