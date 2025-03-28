// TODO Implement this library.
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// import 'calorie_tracker.dart';

// class LoseWeightScreen extends StatefulWidget {
//   @override
//   _LoseWeightScreenState createState() => _LoseWeightScreenState();
// }

// class _LoseWeightScreenState extends State<LoseWeightScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _goalWeightController = TextEditingController();
//   final TextEditingController _durationController = TextEditingController();

//   double? currentWeight;
//   double? targetWeight;
//   double? maintenanceCalories;
//   double? dailyCalorieDeficit;
//   double? dailyProtein;
//   double? finalDailyCalorieGoal;
//   String? goalDocId;

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   /// Fetch user data (current weight & maintenance calories) from Firestore
//   Future<void> _fetchUserData() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user == null) {
//         setState(() => isLoading = false);
//         _showSnackBar("User not logged in.");
//         return;
//       }

//       // Get current weight from Firestore
//       final userDoc = await _firestore.collection('users').doc(user.uid).get();
//       if (userDoc.exists) {
//         currentWeight = (userDoc.data()?['weight'] as num?)?.toDouble();
//       }

//       // Get maintenance calories from Firestore
//       final maintenanceDoc = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("maintenance_data")
//           .doc("maintenance")
//           .get();

//       maintenanceCalories = maintenanceDoc.exists
//           ? (maintenanceDoc["maintenanceCalories"] as num?)?.toDouble()
//           : null;

//       // Get latest goal document (either gain or lose)
//       final goalsSnapshot = await _firestore
//           .collection("users")
//           .doc(user.uid)
//           .collection("calorie_goal")
//           .orderBy("timestamp", descending: true)
//           .limit(1)
//           .get();

//       if (goalsSnapshot.docs.isNotEmpty) {
//         final data = goalsSnapshot.docs.first.data();
//         goalDocId = goalsSnapshot.docs.first.id;

//         _goalWeightController.text = data["targetWeight"]?.toString() ?? "";
//         _durationController.text = data["goalDuration"]?.toString() ?? "";

//         dailyCalorieDeficit = (data["dailyCalorieChange"] ?? 0).toDouble();
//         dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
//         finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
//         targetWeight = (data["targetWeight"] ?? 0).toDouble();
//       }

//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showSnackBar("Error fetching data: ${e.toString()}");
//     }
//   }

//   /// Calculate weight loss goals based on user input
//   Future<void> _calculateLoseGoal() async {
//     try {
//       double? targetWeightInput = double.tryParse(_goalWeightController.text);
//       int? months = int.tryParse(_durationController.text);

//       if (targetWeightInput == null ||
//           months == null ||
//           months <= 0 ||
//           maintenanceCalories == null ||
//           currentWeight == null) {
//         _showSnackBar("Please enter valid values.");
//         return;
//       }

//       // Ensure target weight is lower than current weight
//       if (targetWeightInput >= currentWeight!) {
//         _showSnackBar("Target weight must be lower than current weight.");
//         return;
//       }

//       // Calculate weight loss amount
//       double weightLoss = currentWeight! - targetWeightInput;

//       // 7700 kcal = 1kg of fat loss
//       double totalCalorieDeficit = weightLoss * 7700;
//       double dailyCalorieDeficit = totalCalorieDeficit / (months * 30);

//       // Protein intake calculation (1.5g per kg of target weight)
//       double dailyProteinIntake = targetWeightInput * 1.5;

//       // Final daily calorie intake goal
//       double calculatedFinalDailyCalorieGoal =
//           maintenanceCalories! - dailyCalorieDeficit;

//       setState(() {
//         targetWeight = targetWeightInput;
//         this.dailyCalorieDeficit = dailyCalorieDeficit;
//         dailyProtein = dailyProteinIntake;
//         finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
//       });

//       await _storeData(
//         targetWeightInput,
//         months,
//         dailyCalorieDeficit,
//         dailyProteinIntake,
//         calculatedFinalDailyCalorieGoal,
//       );
//     } catch (e) {
//       _showSnackBar("Error calculating goal.");
//     }
//   }

//   /// Store weight loss goal in Firestore, updating the same document if it exists
//   Future<void> _storeData(
//     double targetWeight,
//     int months,
//     double dailyCalorieDeficit,
//     double dailyProtein,
//     double finalCalorieGoal,
//   ) async {
//     try {
//       User? user = _auth.currentUser;
//       if (user == null) return;

//       final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

//       final data = {
//         "goalType": "lose",
//         "targetWeight": targetWeight,
//         "goalDuration": months,
//         "dailyCalorieChange": dailyCalorieDeficit,
//         "dailyProteinIntake": dailyProtein,
//         "finalDailyCalorieGoal": finalCalorieGoal,
//         "maintenanceCalories": maintenanceCalories,
//         "currentWeight": currentWeight,
//         "date": currentDate,
//         "timestamp": FieldValue.serverTimestamp(),
//       };

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

//       _showSnackBar("Goal saved successfully!");
//     } catch (e) {
//       _showSnackBar("Error saving goal data.");
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Lose Weight Plan")),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: ListView(
//                 children: [
//                   Text(
//                     "Create Your Weight Loss Plan",
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   _buildInputField(
//                     controller: _goalWeightController,
//                     label: "Target Weight (kg)",
//                     hint: "Enter your target weight",
//                   ),
//                   _buildInputField(
//                     controller: _durationController,
//                     label: "Duration (months)",
//                     hint: "Enter timeline in months",
//                   ),
//                   SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _calculateLoseGoal,
//                     child: Text("Calculate Plan"),
//                   ),
//                   SizedBox(height: 30),
//                   if (dailyCalorieDeficit != null &&
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
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           border: OutlineInputBorder(),
//         ),
//         keyboardType: TextInputType.number,
//       ),
//     );
//   }

//   Widget _buildResultsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Your Weight Loss Plan",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text(
//                 "Daily Calorie Deficit: ${dailyCalorieDeficit?.toStringAsFixed(0)} kcal"),
//             Text("Daily Protein Intake: ${dailyProtein?.toStringAsFixed(1)} g"),
//             Text(
//                 "Final Daily Calorie Goal: ${finalDailyCalorieGoal?.toStringAsFixed(0)} kcal"),
//           ],
//         ),
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

class LoseWeightScreen extends StatefulWidget {
  @override
  _LoseWeightScreenState createState() => _LoseWeightScreenState();
}

class _LoseWeightScreenState extends State<LoseWeightScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  double? currentWeight;
  double? targetWeight;
  double? maintenanceCalories;
  double? dailyCalorieDeficit;
  double? dailyProtein;
  double? finalDailyCalorieGoal;
  String? goalDocId;

  bool isLoading = true;

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
    _fetchUserData();
  }

  /// Fetch user data (current weight & maintenance calories) from Firestore
  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        _showSnackBar("User not logged in.");
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

        dailyCalorieDeficit = (data["dailyCalorieChange"] ?? 0).toDouble();
        dailyProtein = (data["dailyProteinIntake"] ?? 0).toDouble();
        finalDailyCalorieGoal = (data["finalDailyCalorieGoal"] ?? 0).toDouble();
        targetWeight = (data["targetWeight"] ?? 0).toDouble();
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error fetching data: ${e.toString()}");
    }
  }

  /// Calculate weight loss goals based on user input
  Future<void> _calculateLoseGoal() async {
    try {
      double? targetWeightInput = double.tryParse(_goalWeightController.text);
      int? months = int.tryParse(_durationController.text);

      if (targetWeightInput == null ||
          months == null ||
          months <= 0 ||
          maintenanceCalories == null ||
          currentWeight == null) {
        _showSnackBar("Please enter valid values.");
        return;
      }

      // Ensure target weight is lower than current weight
      if (targetWeightInput >= currentWeight!) {
        _showSnackBar("Target weight must be lower than current weight.");
        return;
      }

      // Calculate weight loss amount
      double weightLoss = currentWeight! - targetWeightInput;

      // 7700 kcal = 1kg of fat loss
      double totalCalorieDeficit = weightLoss * 7700;
      double dailyCalorieDeficit = totalCalorieDeficit / (months * 30);

      // Protein intake calculation (1.5g per kg of target weight)
      double dailyProteinIntake = targetWeightInput * 1.5;

      // Final daily calorie intake goal
      double calculatedFinalDailyCalorieGoal =
          maintenanceCalories! - dailyCalorieDeficit;

      setState(() {
        targetWeight = targetWeightInput;
        this.dailyCalorieDeficit = dailyCalorieDeficit;
        dailyProtein = dailyProteinIntake;
        finalDailyCalorieGoal = calculatedFinalDailyCalorieGoal;
      });

      await _storeData(
        targetWeightInput,
        months,
        dailyCalorieDeficit,
        dailyProteinIntake,
        calculatedFinalDailyCalorieGoal,
      );
    } catch (e) {
      _showSnackBar("Error calculating goal.");
    }
  }

  /// Store weight loss goal in Firestore, updating the same document if it exists
  Future<void> _storeData(
    double targetWeight,
    int months,
    double dailyCalorieDeficit,
    double dailyProtein,
    double finalCalorieGoal,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final data = {
        "goalType": "lose",
        "targetWeight": targetWeight,
        "goalDuration": months,
        "dailyCalorieChange": dailyCalorieDeficit,
        "dailyProteinIntake": dailyProtein,
        "finalDailyCalorieGoal": finalCalorieGoal,
        "maintenanceCalories": maintenanceCalories,
        "currentWeight": currentWeight,
        "date": currentDate,
        "timestamp": FieldValue.serverTimestamp(),
      };

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

      _showSnackBar("Goal saved successfully!");
    } catch (e) {
      _showSnackBar("Error saving goal data.");
    }
  }

  void _showSnackBar(String message) {
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
            "Lose Weight Plan",
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
                            Icons.arrow_downward,
                            size: 60,
                            color: lightGreen,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Create Your Weight Loss Plan",
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
                            hint: "Enter your target weight",
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
                            onPressed: _calculateLoseGoal,
                            icon: Icons.calculate,
                            gradientStart: primaryGreen,
                            gradientEnd: darkGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Results section
                    if (dailyCalorieDeficit != null &&
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
            "Your Weight Loss Plan",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            "Daily Calorie Deficit:",
            "${dailyCalorieDeficit?.toStringAsFixed(0)} kcal",
          ),
          _buildResultRow(
            "Daily Protein Intake:",
            "${dailyProtein?.toStringAsFixed(1)} g",
          ),
          _buildResultRow(
            "Final Daily Calorie Goal:",
            "${finalDailyCalorieGoal?.toStringAsFixed(0)} kcal",
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
