// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'calorie_tracker.dart';

// class GainWeightScreen extends StatefulWidget {
//   @override
//   _GainWeightScreenState createState() => _GainWeightScreenState();
// }

// class _GainWeightScreenState extends State<GainWeightScreen> {
//   final TextEditingController _goalWeightController = TextEditingController();
//   final TextEditingController _durationController = TextEditingController();

//   double? dailyCaloriesSurplus;
//   double? dailyProtein;
//   double? finalDailyCalorieGoal;
//   double? currentWeight;
//   double? targetWeight;
//   double? maintenanceCalories;
//   bool isLoading = true;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? goalDocId;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPreviousData();
//   }

//   Future<void> _fetchPreviousData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         setState(() => isLoading = false);
//         _showSnackbar("User not logged in.");
//         return;
//       }

//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         currentWeight = (userDoc.data()?['weight'] as num?)?.toDouble();
//         goalDocId = userDoc.data()?['goal_doc']; // Retrieve stored goal doc ID
//       }

//       final maintenanceDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("maintenance_data")
//           .doc("maintenance")
//           .get();

//       maintenanceCalories = maintenanceDoc.exists
//           ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
//           : null;

//       if (goalDocId != null) {
//         final goalDoc = await _firestore
//             .collection("users")
//             .doc(user.uid)
//             .collection("calorie_goal")
//             .doc(goalDocId)
//             .get();

//         if (goalDoc.exists) {
//           final data = goalDoc.data()!;
//           _goalWeightController.text = data["targetWeight"]?.toString() ?? "";
//           _durationController.text = data["goalDuration"]?.toString() ?? "";
//           dailyCaloriesSurplus = (data["dailyCalorieChange"] ?? 0).toDouble();
//           dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
//           finalDailyCalorieGoal =
//               (data["finalDailyCalorieGoal"] ?? 0).toDouble();
//           targetWeight = (data["targetWeight"] ?? 0).toDouble();
//         }
//       }

//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showSnackbar("Error fetching data: ${e.toString()}");
//     }
//   }

//   Future<void> _calculateGainGoal() async {
//     try {
//       final goalWeight = double.tryParse(_goalWeightController.text);
//       final months = int.tryParse(_durationController.text);

//       if (goalWeight == null || months == null || months <= 0) {
//         _showSnackbar("Please enter valid values.");
//         return;
//       }

//       if (currentWeight == null) {
//         _showSnackbar("Error: Current weight not found.");
//         return;
//       }

//       if (goalWeight <= currentWeight!) {
//         _showSnackbar(
//             "Target weight must be greater than your current weight.");
//         return;
//       }

//       targetWeight = goalWeight;

//       final totalExtraCalories = (targetWeight! - currentWeight!) * 7700;
//       final dailyExtraCalories = totalExtraCalories / (months * 30);
//       final dailyProteinIntake = targetWeight! * 2.2;
//       final calculatedFinalDailyCalorieGoal =
//           maintenanceCalories! + dailyExtraCalories;

//       setState(() {
//         dailyCaloriesSurplus = dailyExtraCalories;
//         dailyProtein = dailyProteinIntake;
//         finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
//       });

//       await _storeData(
//         goalWeight,
//         months,
//         dailyExtraCalories,
//         dailyProteinIntake,
//         calculatedFinalDailyCalorieGoal,
//         currentWeight!,
//         targetWeight!,
//       );
//     } catch (e) {
//       _showSnackbar("Calculation error: ${e.toString()}");
//     }
//   }

//   Future<void> _storeData(
//     double goalWeight,
//     int months,
//     double dailyCalories,
//     double dailyProtein,
//     double finalCalorieGoal,
//     double currentWeight,
//     double targetWeight,
//   ) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       // Use current date as document ID
//       final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final data = {
//         "goalType": "gain",
//         "targetWeight": goalWeight,
//         "goalDuration": months,
//         "dailyCalorieChange": dailyCalories,
//         "dailyProteinIntake": dailyProtein,
//         "finalDailyCalorieGoal": finalCalorieGoal,
//         "currentWeight": currentWeight,
//         "maintenanceCalories": maintenanceCalories,
//         "date": currentDate,
//         "timestamp": FieldValue.serverTimestamp(),
//       };

//       // Save/update with date-based document ID
//       await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("calorie_goal")
//           .doc(currentDate)
//           .set(data, SetOptions(merge: true));

//       // Navigate to CalorieTracker after successful save
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => CalorieTracker()),
//       );

//       _showSnackbar("Goal saved successfully!");
//     } catch (e) {
//       _showSnackbar("Save failed: ${e.toString()}");
//     }
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Gain Weight Plan")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: ListView(
//                 children: [
//                   Text(
//                     "Create Your Weight Gain Plan",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   _buildInputField(
//                     controller: _goalWeightController,
//                     label: "Target Weight (kg)",
//                     hint: "Enter desired weight",
//                   ),
//                   _buildInputField(
//                     controller: _durationController,
//                     label: "Duration (months)",
//                     hint: "Enter timeline in months",
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _calculateGainGoal,
//                     child: Text("Calculate Plan"),
//                     style: ElevatedButton.styleFrom(
//                       padding: EdgeInsets.symmetric(vertical: 15),
//                     ),
//                   ),
//                   SizedBox(height: 30),
//                   if (dailyCaloriesSurplus != null &&
//                       dailyProtein != null &&
//                       finalDailyCalorieGoal != null)
//                     _buildResultsCard(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           border: OutlineInputBorder(),
//           filled: true,
//         ),
//       ),
//     );
//   }

//   Widget _buildResultsCard() {
//     return Card(
//       elevation: 5,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             Text("Your Daily Targets",
//                 style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue)),
//             _buildResultRow("Calorie Surplus:",
//                 "${dailyCaloriesSurplus!.toStringAsFixed(1)} kcal"),
//             _buildResultRow("Total Daily Calories:",
//                 "${finalDailyCalorieGoal!.toStringAsFixed(1)} kcal"),
//             _buildResultRow(
//                 "Protein Intake:", "${dailyProtein!.toStringAsFixed(1)} g"),
//             _buildResultRow(
//                 "Target Weight:", "${targetWeight!.toStringAsFixed(1)} kg"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultRow(String label, String value) {
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

class GainWeightScreen extends StatefulWidget {
  @override
  _GainWeightScreenState createState() => _GainWeightScreenState();
}

class _GainWeightScreenState extends State<GainWeightScreen> {
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  double? dailyCaloriesSurplus;
  double? dailyProtein;
  double? finalDailyCalorieGoal;
  double? currentWeight;
  double? targetWeight;
  double? maintenanceCalories;
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? goalDocId;

  // App theme colors (same as previous prompts)
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color inputDark = const Color(0xFF2A2A2A);
  final Color textLight = const Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _fetchPreviousData();
  }

  Future<void> _fetchPreviousData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackbar("User not logged in.");
        return;
      }

      // Get current weight from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        currentWeight = (userDoc.data()?['weight'] as num?)?.toDouble();
      }

      // Get maintenance calories from Firestore
      final maintenanceDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("maintenance_data")
          .doc("maintenance")
          .get();

      maintenanceCalories = maintenanceDoc.exists
          ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
          : null;

      // Get latest goal document (either gain or lose)
      final goalsSnapshot = await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("calorie_goal")
          .orderBy("timestamp", descending: true)
          .limit(1)
          .get();

      if (goalsSnapshot.docs.isNotEmpty) {
        final data = goalsSnapshot.docs.first.data();
        goalDocId = goalsSnapshot.docs.first.id;

        _goalWeightController.text = data["targetWeight"]?.toString() ?? "";
        _durationController.text = data["goalDuration"]?.toString() ?? "";
        dailyCaloriesSurplus = (data["dailyCalorieChange"] ?? 0).toDouble();
        dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
        finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
        targetWeight = (data["targetWeight"] ?? 0).toDouble();
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackbar("Error fetching data: ${e.toString()}");
    }
  }

  Future<void> _calculateGainGoal() async {
    try {
      final goalWeight = double.tryParse(_goalWeightController.text);
      final months = int.tryParse(_durationController.text);

      if (goalWeight == null || months == null || months <= 0) {
        _showSnackbar("Please enter valid values.");
        return;
      }

      if (currentWeight == null) {
        _showSnackbar("Error: Current weight not found.");
        return;
      }

      if (goalWeight <= currentWeight!) {
        _showSnackbar(
            "Target weight must be greater than your current weight.");
        return;
      }

      targetWeight = goalWeight;

      final totalExtraCalories = (targetWeight! - currentWeight!) * 7700;
      final dailyExtraCalories = totalExtraCalories / (months * 30);
      final dailyProteinIntake = targetWeight! * 2.2;
      final calculatedFinalDailyCalorieGoal =
          maintenanceCalories! + dailyExtraCalories;

      setState(() {
        dailyCaloriesSurplus = dailyExtraCalories;
        dailyProtein = dailyProteinIntake;
        finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
      });

      await _storeData(
        goalWeight,
        months,
        dailyExtraCalories,
        dailyProteinIntake,
        calculatedFinalDailyCalorieGoal,
        currentWeight!,
        targetWeight!,
      );
    } catch (e) {
      _showSnackbar("Calculation error: ${e.toString()}");
    }
  }

  Future<void> _storeData(
    double goalWeight,
    int months,
    double dailyCalories,
    double dailyProtein,
    double finalCalorieGoal,
    double currentWeight,
    double targetWeight,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Use current date as document ID
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final data = {
        "goalType": "gain",
        "targetWeight": goalWeight,
        "goalDuration": months,
        "dailyCalorieChange": dailyCalories,
        "dailyProteinIntake": dailyProtein,
        "finalDailyCalorieGoal": finalCalorieGoal,
        "currentWeight": currentWeight,
        "maintenanceCalories": maintenanceCalories,
        "date": currentDate,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Save/update with date-based document ID
      await _firestore
          .collection("users")
          .doc(user.uid)
          .collection("calorie_goal")
          .doc(currentDate)
          .set(data, SetOptions(merge: true));

      // Navigate to CalorieTracker after successful save
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CalorieTracker()),
      );

      _showSnackbar("Goal saved successfully!");
    } catch (e) {
      _showSnackbar("Save failed: ${e.toString()}");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryGreen, width: 2),
          ),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          labelStyle: TextStyle(color: textLight),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Gain Weight Plan",
            style: GoogleFonts.poppins(),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                ),
              )
            : SingleChildScrollView(
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
                            Icons.arrow_upward,
                            size: 60,
                            color: lightGreen,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Create Your Weight Gain Plan",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Set your target weight and timeline to achieve your goal.",
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

                    // Input section
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            controller: _goalWeightController,
                            label: "Target Weight (kg)",
                            hint: "Enter desired weight",
                            icon: Icons.fitness_center,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _durationController,
                            label: "Duration (months)",
                            hint: "Enter timeline in months",
                            icon: Icons.calendar_today,
                          ),
                          const SizedBox(height: 24),
                          _buildButton(
                            text: "Calculate Plan",
                            onPressed: _calculateGainGoal,
                            icon: Icons.calculate,
                            gradientStart: primaryGreen,
                            gradientEnd: darkGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Results section
                    if (dailyCaloriesSurplus != null &&
                        dailyProtein != null &&
                        finalDailyCalorieGoal != null)
                      _buildResultsCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(
        color: textLight,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: lightGreen.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
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
            "Your Daily Targets",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            "Calorie Surplus:",
            "${dailyCaloriesSurplus!.toStringAsFixed(1)} kcal",
          ),
          _buildResultRow(
            "Total Daily Calories:",
            "${finalDailyCalorieGoal!.toStringAsFixed(1)} kcal",
          ),
          _buildResultRow(
            "Protein Intake:",
            "${dailyProtein!.toStringAsFixed(1)} g",
          ),
          _buildResultRow(
            "Target Weight:",
            "${targetWeight!.toStringAsFixed(1)} kg",
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
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
