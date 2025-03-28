// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'calorie_tracker.dart';

// class MaintainWeightScreen extends StatelessWidget {
//   final double maintenanceCalories;
//   final double bodyWeight;

//   const MaintainWeightScreen({
//     required this.maintenanceCalories,
//     required this.bodyWeight,
//   });

//   Future<void> _storeData(BuildContext context) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final dailyProtein = bodyWeight * 1.5; // Calculate protein intake

//       final data = {
//         "goalType": "maintain",
//         "finalDailyCalorieGoal": maintenanceCalories,
//         "dailyProteinIntake": dailyProtein,
//         "maintenanceCalories": maintenanceCalories,
//         "currentWeight": bodyWeight,
//         "date": currentDate,
//         "timestamp": FieldValue.serverTimestamp(),
//       };

//       await FirebaseFirestore.instance
//           .collection("users")
//           .doc(user.uid)
//           .collection("calorie_goal")
//           .doc(currentDate)
//           .set(data, SetOptions(merge: true));

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => CalorieTracker()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text("Error saving maintenance goal: ${e.toString()}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Maintain Weight Plan")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Your Maintenance Plan",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     _buildInfoRow("Daily Calorie Goal:",
//                         "${maintenanceCalories.toStringAsFixed(0)} kcal"),
//                     _buildInfoRow("Daily Protein Intake:",
//                         "${(bodyWeight * 1.5).toStringAsFixed(1)} g"),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => _storeData(context),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                 child: Text("Confirm and Start Tracking"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
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
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'calorie_tracker.dart';

class MaintainWeightScreen extends StatelessWidget {
  final double maintenanceCalories;
  final double bodyWeight;

  const MaintainWeightScreen({
    required this.maintenanceCalories,
    required this.bodyWeight,
  });

  // App theme colors (same as previous prompts)
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color textLight = const Color(0xFFE0E0E0);

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
          content: Text(
            "Error saving maintenance goal: ${e.toString()}",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: cardDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color gradientStart = const Color(0xFF4CAF50),
    Color gradientEnd = const Color(0xFF2E7D32),
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgDark,
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Maintain Weight Plan",
            style: GoogleFonts.poppins(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.balance,
                      size: 60,
                      color: lightGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Maintain Your Weight",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Follow this plan to maintain your current weight.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Results section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryGreen.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Your Maintenance Plan",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      "Daily Calorie Goal:",
                      "${maintenanceCalories.toStringAsFixed(0)} kcal",
                    ),
                    _buildInfoRow(
                      "Daily Protein Intake:",
                      "${(bodyWeight * 1.5).toStringAsFixed(1)} g",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Confirm button
              _buildButton(
                text: "Confirm and Start Tracking",
                onPressed: () => _storeData(context),
                icon: Icons.check_circle,
                gradientStart: primaryGreen,
                gradientEnd: darkGreen,
              ),
            ],
          ),
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
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: textLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}
