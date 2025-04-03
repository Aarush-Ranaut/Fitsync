// exercise selection + calorie track + Maintainence calorie
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../widgets/Camera_integrate.dart';
// import '../screens/community_screen.dart';
// import '../widgets/calorie_tracker.dart';
// import '../widgets/maintenance_calorie_screen.dart'; // Import the new screen

// class ExerciseSelectionScreen extends StatelessWidget {
//   const ExerciseSelectionScreen({super.key});

//   Future<bool> _checkCalorieGoalExists() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) return false;

//       var calorieGoalSnapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("calorie_goal")
//           .limit(1) // Check if at least one document exists
//           .get();

//       return calorieGoalSnapshot.docs.isNotEmpty;
//     } catch (e) {
//       print("Error checking calorie goal: $e");
//       return false;
//     }
//   }

//   void _handleTrackCalories(BuildContext context) async {
//     bool goalExists = await _checkCalorieGoalExists();
//     if (goalExists) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => CalorieTracker()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => MaintenanceCalorieScreen()),
//       );
//     }
//   }

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
//                       builder: (context) => PoseScreen(exercise: 1)),
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
//                       builder: (context) => PoseScreen(exercise: 2)),
//                 );
//               },
//               child: Text("Exercise 2"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => CommunityScreen()),
//                 );
//               },
//               child: Text("Open Community"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _handleTrackCalories(context),
//               child: Text("Track Calories"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => MaintenanceCalorieScreen()),
//                 );
//               },
//               child: Text("Calculate Maintenance Calories"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../widgets/Camera_integrate.dart';
// import '../screens/community_screen.dart';
// import '../widgets/calorie_tracker.dart';
// import '../widgets/maintenance_calorie_screen.dart';
// import '../widgets/home_screen.dart'; // Import HomeScreen

// class ExerciseSelectionScreen extends StatelessWidget {
//   const ExerciseSelectionScreen({super.key});

//   Future<bool> _checkCalorieGoalExists() async {
//     // Existing implementation
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) return false;

//       var calorieGoalSnapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("calorie_goal")
//           .limit(1)
//           .get();

//       return calorieGoalSnapshot.docs.isNotEmpty;
//     } catch (e) {
//       print("Error checking calorie goal: $e");
//       return false;
//     }
//   }

//   void _handleTrackCalories(BuildContext context) async {
//     // Existing implementation
//     bool goalExists = await _checkCalorieGoalExists();
//     if (goalExists) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => CalorieTracker()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => MaintenanceCalorieScreen()),
//       );
//     }
//   }

//   void _handleBackButton(BuildContext context) {
//     // Custom back navigation logic
//     if (Navigator.canPop(context)) {
//       Navigator.pop(context); // Normal back navigation
//     } else {
//       // Redirect to HomeScreen if no previous screens
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         // Handle system back button
//         _handleBackButton(context);
//         return false; // Prevent default back behavior
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("Select Exercise"),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => _handleBackButton(context), // Custom back button
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => PoseScreen(exercise: 1)),
//                   );
//                 },
//                 child: const Text("Exercise 1"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => PoseScreen(exercise: 2)),
//                   );
//                 },
//                 child: const Text("Exercise 2"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => CommunityScreen()),
//                   );
//                 },
//                 child: const Text("Open Community"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => _handleTrackCalories(context),
//                 child: const Text("Track Calories"),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => MaintenanceCalorieScreen()),
//                   );
//                 },
//                 child: const Text("Calculate Maintenance Calories"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/Camera_integrate.dart';
import '../screens/community_screen.dart';
import '../widgets/calorie_tracker.dart';
import '../widgets/maintenance_calorie_screen.dart';
import '../widgets/home_screen.dart'; // Import HomeScreen

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({super.key});

  Future<bool> _checkCalorieGoalExists() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      var calorieGoalSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("calorie_goal")
          .limit(1)
          .get();

      return calorieGoalSnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking calorie goal: $e");
      return false;
    }
  }

  void _handleTrackCalories(BuildContext context) async {
    bool goalExists = await _checkCalorieGoalExists();
    if (goalExists) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CalorieTracker()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MaintenanceCalorieScreen()),
      );
    }
  }

  void _handleBackButton(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Normal back navigation
    } else {
      // Redirect to HomeScreen if no previous screens
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackButton(context);
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Select Exercise"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackButton(context), // Custom back button
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PoseScreen(exercise: 1)),
                  );
                },
                child: const Text("Exercise 1"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PoseScreen(exercise: 2)),
                  );
                },
                child: const Text("Exercise 2"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PoseScreen(exercise: 3)),
                  );
                },
                child: const Text("Exercise 3"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityScreen()),
                  );
                },
                child: const Text("Open Community"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _handleTrackCalories(context),
                child: const Text("Track Calories"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MaintenanceCalorieScreen()),
                  );
                },
                child: const Text("Calculate Maintenance Calories"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
