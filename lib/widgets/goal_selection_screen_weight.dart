// GoalSelectionScreen modifications
// import 'package:flutter/material.dart';
// import 'gain_weight.dart';
// import 'lose_weight.dart';
// import 'maintain_weight.dart'; // Add this import

// class GoalSelectionScreen extends StatelessWidget {
//   final double maintenanceCalories;
//   final double bodyWeight;

//   GoalSelectionScreen({
//     required this.maintenanceCalories,
//     required this.bodyWeight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Select Your Goal")),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "What is your goal?",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => GainWeightScreen()),
//                   );
//                 },
//                 child: Text("Gain Weight"),
//               ),
//               SizedBox(height: 15),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => LoseWeightScreen()),
//                   );
//                 },
//                 child: Text("Lose Weight"),
//               ),
//               SizedBox(height: 15),
//               // New Maintain Weight button
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MaintainWeightScreen(
//                         maintenanceCalories: maintenanceCalories,
//                         bodyWeight: bodyWeight,
//                       ),
//                     ),
//                   );
//                 },
//                 child: Text("Maintain Weight"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gain_weight.dart';
import 'lose_weight.dart';
import 'maintain_weight.dart';

class GoalSelectionScreen extends StatelessWidget {
  final double maintenanceCalories;
  final double bodyWeight;

  GoalSelectionScreen({
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
      margin: const EdgeInsets.symmetric(vertical: 8),
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
            "Select Your Goal",
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
                      Icons.fitness_center,
                      size: 60,
                      color: lightGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "What is your goal?",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose a goal to personalize your calorie plan.",
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

              // Buttons section
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
                  children: [
                    _buildButton(
                      text: "Gain Weight",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GainWeightScreen()),
                        );
                      },
                      icon: Icons.arrow_upward,
                      gradientStart: primaryGreen,
                      gradientEnd: darkGreen,
                    ),
                    _buildButton(
                      text: "Lose Weight",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoseWeightScreen()),
                        );
                      },
                      icon: Icons.arrow_downward,
                      gradientStart: primaryGreen,
                      gradientEnd: darkGreen,
                    ),
                    _buildButton(
                      text: "Maintain Weight",
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
                      icon: Icons.balance,
                      gradientStart: primaryGreen,
                      gradientEnd: darkGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
