// import 'package:flutter/material.dart';

// class CalorieCalculator extends StatefulWidget {
//   @override
//   _CalorieCalculatorState createState() => _CalorieCalculatorState();
// }

// class _CalorieCalculatorState extends State<CalorieCalculator> {
//   final TextEditingController _calorieController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   String _result = "";
//   String _exampleCalculation = "";

//   /// **Method to Calculate Calories**
//   void _calculateCalories() {
//     // Hide the keyboard
//     FocusScope.of(context).unfocus();

//     double caloriesPer100g = double.tryParse(_calorieController.text) ?? 0;
//     double weight = double.tryParse(_weightController.text) ?? 0;
//     double totalCalories = (caloriesPer100g / 100) * weight;

//     setState(() {
//       _result = "Total Calories: ${totalCalories.toStringAsFixed(2)} kcal";
//       _exampleCalculation =
//           "If a food item has ${caloriesPer100g.toStringAsFixed(2)} kcal per 100g, "
//           "and you consume ${weight.toStringAsFixed(2)}g of it, then total calories will be:\n\n"
//           "Total Calories = (${caloriesPer100g.toStringAsFixed(2)} kcal ÷ 100) × ${weight.toStringAsFixed(2)}g = "
//           "${totalCalories.toStringAsFixed(2)} kcal";
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus(); // Hide keyboard when tapping outside
//       },
//       child: Scaffold(
//         appBar: AppBar(title: Text("Calorie Calculator")),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // **Title**
//               Text(
//                 "Calorie Calculator",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20),

//               // **Calories per 100g Input**
//               Text("Calories per 100g (kcal)",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//               SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _calorieController,
//                       keyboardType: TextInputType.number,
//                       textInputAction:
//                           TextInputAction.done, // Hide keyboard on "Done"
//                       decoration: InputDecoration(
//                         hintText: "e.g. 250",
//                         border: OutlineInputBorder(),
//                       ),
//                       onEditingComplete: () => FocusScope.of(context).unfocus(),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Text("kcal", style: TextStyle(fontSize: 16)),
//                 ],
//               ),
//               SizedBox(height: 20),

//               // **Weight Input**
//               Text("Serving Size (Weight in grams)",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//               SizedBox(height: 5),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _weightController,
//                       keyboardType: TextInputType.number,
//                       textInputAction:
//                           TextInputAction.done, // Hide keyboard on "Done"
//                       decoration: InputDecoration(
//                         hintText: "e.g. 150",
//                         border: OutlineInputBorder(),
//                       ),
//                       onEditingComplete: () => FocusScope.of(context).unfocus(),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Text("g", style: TextStyle(fontSize: 16)),
//                 ],
//               ),
//               SizedBox(height: 20),

//               // **Calculate Button**
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _calculateCalories,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 15),
//                     textStyle: TextStyle(fontSize: 18),
//                   ),
//                   child: Text("Calculate"),
//                 ),
//               ),
//               SizedBox(height: 20),

//               // **Result Text**
//               Center(
//                 child: Text(
//                   _result,
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // **Example Image (Optional)**
//               Center(
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.9,
//                   height: 400,
//                   child: Image.asset(
//                     'assets/images/calorie_ex.png',
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 30),

//               // **Example Calculation**
//               Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Example Calculation:",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 5),
//                     Text(
//                       _exampleCalculation.isNotEmpty
//                           ? _exampleCalculation
//                           : "If a food item has 250 kcal per 100g, and you consume 150g of it, "
//                               "then total calories will be calculated as:\n\n"
//                               "Total Calories = (250 kcal ÷ 100) × 150g = 375 kcal",
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 30),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalorieCalculator extends StatefulWidget {
  const CalorieCalculator({super.key});

  @override
  _CalorieCalculatorState createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<CalorieCalculator> {
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _result = "";
  String _exampleCalculation = "";

  // App theme colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color inputDark = const Color(0xFF2A2A2A);
  final Color textLight = const Color(0xFFE0E0E0);

  /// **Method to Calculate Calories**
  void _calculateCalories() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    double caloriesPer100g = double.tryParse(_calorieController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;
    double totalCalories = (caloriesPer100g / 100) * weight;

    setState(() {
      _result = "${totalCalories.toStringAsFixed(2)}";
      _exampleCalculation =
          "If a food item has ${caloriesPer100g.toStringAsFixed(2)} kcal per 100g, "
          "and you consume ${weight.toStringAsFixed(2)}g of it, then total calories will be:\n\n"
          "Total Calories = (${caloriesPer100g.toStringAsFixed(2)} kcal ÷ 100) × ${weight.toStringAsFixed(2)}g = "
          "${totalCalories.toStringAsFixed(2)} kcal";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgDark,
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.dark(
          primary: primaryGreen,
          secondary: lightGreen,
          surface: cardDark,
          background: bgDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkGreen,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Hide keyboard when tapping outside
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Calorie Calculator",
              style: GoogleFonts.poppins(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate, color: lightGreen, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Calorie Calculator",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Calculate the exact calories in your food portions",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Input section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // **Calories per 100g Input**
                      Text(
                        "Calories per 100g",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _calorieController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.poppins(
                                color: textLight,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "e.g. 493.5",
                                prefixIcon: Icon(
                                  Icons.local_fire_department,
                                  color: lightGreen.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: inputDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Text(
                              "kcal",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // **Weight Input**
                      Text(
                        "Serving Size (Weight)",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              style: GoogleFonts.poppins(
                                color: textLight,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: "e.g. 10",
                                prefixIcon: Icon(
                                  Icons.scale,
                                  color: lightGreen.withOpacity(0.7),
                                ),
                              ),
                              onEditingComplete: () =>
                                  FocusScope.of(context).unfocus(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: inputDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade800),
                            ),
                            child: Text(
                              "g",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // **Calculate Button**
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _calculateCalories,
                          icon: const Icon(Icons.calculate_outlined),
                          label: Text("Calculate Calories"),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // **Result Section**
                if (_result.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryGreen.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total Calories",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _result,
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "kcal",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // **Example Calculation**
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: lightGreen),
                          const SizedBox(width: 8),
                          Text(
                            "How It's Calculated",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Text(
                          _exampleCalculation.isNotEmpty
                              ? _exampleCalculation
                              : "If a food item has 250 kcal per 100g, and you consume 150g of it, "
                                  "then total calories will be calculated as:\n\n"
                                  "Total Calories = (250 kcal ÷ 100) × 150g = 375 kcal",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            color: _exampleCalculation.isNotEmpty
                                ? lightGreen
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Formula explanation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: lightGreen),
                          const SizedBox(width: 8),
                          Text(
                            "Formula Explained",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "The formula to calculate calories in a specific portion is:",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: darkGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Total Calories = (Calories per 100g ÷ 100) × Weight in grams",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: lightGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // **Example Image Section**
                // **Example Image Section**
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height:
                        400, // Adjusted height to match the second code block
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      'assets/images/calorie_ex.png', // Path to the example image
                      fit: BoxFit
                          .contain, // Ensure the image fits within the container
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
