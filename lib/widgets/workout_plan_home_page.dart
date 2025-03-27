import 'package:flutter/material.dart';
import 'workout_plan_page.dart';

class WorkoutPlanHomePage extends StatelessWidget {
  const WorkoutPlanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Plan
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Active Plan:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text("Aarush's Muscle-Building Journey",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutPlanPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                    ),
                    child: Text("Plans", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Next Workout Section
            Text("Your next workout:", style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Back and Biceps Focus",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Column(
                    children: _buildExerciseList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Start Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Start", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExerciseList() {
    List<Map<String, dynamic>> exercises = [
      {"name": "Barbell Bent-Over Row", "sets": "3 sets x 10 reps", "muscle": "Lats", "percentage": "14%"},
      {"name": "Dumbbell Concentration Curl", "sets": "3 sets x 10 reps", "muscle": "Biceps", "percentage": "25%"},
      {"name": "Cable Lat Pulldown", "sets": "3 sets x 10 reps", "muscle": "Lats", "percentage": "18%"},
      {"name": "Dumbbell Alternating Hammer Curl", "sets": "3 sets x 10 reps", "muscle": "Biceps", "percentage": "25%"},
      {"name": "Dumbbell One Arm Triceps Extension", "sets": "3 sets x 10 reps", "muscle": "Triceps", "percentage": "36%"},
      {"name": "Dumbbell Bent-Over Row", "sets": "3 sets x 10 reps", "muscle": "Lats", "percentage": "14%"},
    ];

    return exercises.map((exercise) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: Colors.white70), // Placeholder for exercise image
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise["name"], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(exercise["sets"], style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(exercise["muscle"], style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text(exercise["percentage"], style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}