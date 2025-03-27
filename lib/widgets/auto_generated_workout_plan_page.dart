import 'package:flutter/material.dart';

class GeneratedWorkoutPlanPage extends StatelessWidget {
  final int days;

  GeneratedWorkoutPlanPage({required this.days});

  final Map<int, List<Map<String, dynamic>>> workoutTemplates = {
    3: [
      {"title": "Full Body Strength", "muscles": ["Chest", "Back", "Legs", "Arms"], "exercises": ["Bench Press", "Deadlifts", "Squats", "Pull-ups"]},
      {"title": "Upper Body Focus", "muscles": ["Chest", "Back", "Shoulders", "Arms"], "exercises": ["Incline Press", "Bent-over Row", "Shoulder Press", "Biceps Curl"]},
      {"title": "Lower Body & Core", "muscles": ["Quads", "Hamstrings", "Calves", "Abs"], "exercises": ["Lunges", "Leg Press", "Calf Raises", "Plank"]},
    ],
    4: [
      {"title": "Chest & Triceps", "muscles": ["Chest", "Triceps"], "exercises": ["Bench Press", "Dips", "Push-ups", "Triceps Extensions"]},
      {"title": "Back & Biceps", "muscles": ["Back", "Biceps"], "exercises": ["Pull-ups", "Barbell Rows", "Biceps Curl", "Lat Pulldown"]},
      {"title": "Legs & Glutes", "muscles": ["Quads", "Hamstrings", "Glutes"], "exercises": ["Squats", "Deadlifts", "Lunges", "Hip Thrusts"]},
      {"title": "Core & Mobility", "muscles": ["Abs", "Flexibility"], "exercises": ["Plank", "Russian Twists", "Stretching"]},
    ],
    5: [
      {"title": "Chest & Triceps", "muscles": ["Chest", "Triceps"], "exercises": ["Bench Press", "Dips", "Incline Press", "Triceps Extensions"]},
      {"title": "Back & Biceps", "muscles": ["Back", "Biceps"], "exercises": ["Deadlifts", "Pull-ups", "Biceps Curls", "Rows"]},
      {"title": "Leg Day", "muscles": ["Quads", "Hamstrings"], "exercises": ["Squats", "Leg Press", "Calf Raises"]},
      {"title": "Shoulders & Abs", "muscles": ["Shoulders", "Abs"], "exercises": ["Shoulder Press", "Lateral Raises", "Plank"]},
      {"title": "Full Body Recovery", "muscles": ["Stretching", "Cardio"], "exercises": ["Yoga", "Foam Rolling", "Jogging"]},
    ],
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> plan = workoutTemplates[days] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Workout Plan", style: TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: plan.length,
        itemBuilder: (context, index) {
          return _buildWorkoutCard(plan[index], index + 1);
        },
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout, int day) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Day $day", style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(workout["title"], style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: workout["muscles"].map<Widget>((muscle) {
              return Container(
                margin: EdgeInsets.only(right: 6),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(muscle, style: TextStyle(color: Colors.white, fontSize: 14)),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Column(
            children: workout["exercises"].map<Widget>((exercise) {
              return Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(exercise, style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
