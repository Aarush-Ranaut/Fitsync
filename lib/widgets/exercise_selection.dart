import 'package:flutter/material.dart';
import '../widgets/Camera_integrate.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Exercise")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoseScreen(exercise: 1),
                  ),
                );
              },
              child: Text("Exercise 1"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PoseScreen(exercise: 2),
                  ),
                );
              },
              child: Text("Exercise 2"),
            ),
          ],
        ),
      ),
    );
  }
}
