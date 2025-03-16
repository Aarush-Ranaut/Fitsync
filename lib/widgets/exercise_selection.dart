// import 'package:flutter/material.dart';
// import '../widgets/Camera_integrate.dart';

// class ExerciseSelectionScreen extends StatelessWidget {
//   const ExerciseSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Exercise")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 1),
//                   ),
//                 );
//               },
//               child: Text("Exercise 1"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 2),
//                   ),
//                 );
//               },
//               child: Text("Exercise 2"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../widgets/Camera_integrate.dart';
// import '../screens/chat_screen.dart';

// class ExerciseSelectionScreen extends StatelessWidget {
//   const ExerciseSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Exercise")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 1),
//                   ),
//                 );
//               },
//               child: Text("Exercise 1"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 2),
//                   ),
//                 );
//               },
//               child: Text("Exercise 2"),
//             ),
//             SizedBox(height: 20), // Spacing
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         ChatScreen(), // Navigate to ChatScreen
//                   ),
//                 );
//               },
//               child: Text("Open Chat"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../widgets/Camera_integrate.dart';
// import '../screens/community_screen.dart'; // Import CommunityScreen

// class ExerciseSelectionScreen extends StatelessWidget {
//   const ExerciseSelectionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Exercise")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 1),
//                   ),
//                 );
//               },
//               child: Text("Exercise 1"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PoseScreen(exercise: 2),
//                   ),
//                 );
//               },
//               child: Text("Exercise 2"),
//             ),
//             SizedBox(height: 20), // Spacing
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         CommunityScreen(), // Navigate to CommunityScreen
//                   ),
//                 );
//               },
//               child: Text("Open Community"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//calorie_tracker button added
import 'package:flutter/material.dart';
import '../widgets/Camera_integrate.dart';
import '../screens/community_screen.dart'; // Import CommunityScreen
import '../widgets/calorie_tracker.dart'; // Import CalorieTrackerScreen

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
            SizedBox(height: 20), // Spacing
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunityScreen(),
                  ),
                );
              },
              child: Text("Open Community"),
            ),
            SizedBox(height: 20), // Spacing
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalorieTracker(),
                  ),
                );
              },
              child: Text("Track Calories"), // New button for calorie tracker
            ),
          ],
        ),
      ),
    );
  }
}
