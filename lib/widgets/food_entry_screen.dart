// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class FoodEntryScreen extends StatefulWidget {
//   final Function(String, int, int, double, double, double) onFoodAdded;

//   const FoodEntryScreen({Key? key, required this.onFoodAdded})
//       : super(key: key);

//   @override
//   _FoodEntryScreenState createState() => _FoodEntryScreenState();
// }

// class _FoodEntryScreenState extends State<FoodEntryScreen> {
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();

//   // Variables to store the original per-100g nutrient values.
//   double _selectedCaloriesPer100g = 0.0;
//   double _selectedProteinPer100g = 0.0;
//   double _selectedFatPer100g = 0.0;
//   double _selectedCarbsPer100g = 0.0;

//   // Default serving size values.
//   // If the API does not provide a serving size, we fall back to 100.
//   double _defaultServingSize = 100.0;
//   String _defaultServingSizeUnit = "g"; // fallback unit

//   // Determines whether the user is entering input in grams ("g")
//   // or in the provided unit (e.g. "ml", "mg", "unit").
//   String _selectedInputMode = "g";

//   // Calculated nutrient values based on the user's input.
//   double _calculatedCalories = 0.0;
//   double _calculatedProtein = 0.0;
//   double _calculatedFat = 0.0;
//   double _calculatedCarbs = 0.0;

//   List<Map<String, dynamic>> foodResults = [];
//   bool isSearching = false;

//   static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
//   static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

//   // Mapping for units to more user-friendly labels.
//   final Map<String, String> _unitMapping = {
//     "GRM": "g",
//     "MLT": "ml",
//     "MG": "mg",
//     // Add more mappings as needed.
//   };

//   Future<void> _fetchFoodData(String query) async {
//     if (query.length < 3) {
//       setState(() => foodResults = []);
//       return;
//     }
//     setState(() => isSearching = true);
//     final Uri url = Uri.parse("$baseUrl?query=$query&api_key=$apiKey");

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         List<Map<String, dynamic>> fetchedFoods = [];
//         for (var item in data["foods"]) {
//           List nutrients = item["foodNutrients"];

//           double caloriesPer100g = _getNutrientValue(nutrients, "Energy");
//           double proteinPer100g = _getNutrientValue(nutrients, "Protein");
//           double fatPer100g = _getNutrientValue(nutrients, "Total lipid (fat)");
//           double carbsPer100g =
//               _getNutrientValue(nutrients, "Carbohydrate, by difference");

//           // Check if API provides serving size information.
//           double servingSize = item["servingSize"] != null
//               ? double.parse(
//                   (item["servingSize"] as num).toDouble().toStringAsFixed(2))
//               : 100.0;
//           // Get raw serving unit and convert it using _unitMapping if available.
//           String rawUnit =
//               item["servingSizeUnit"] != null ? item["servingSizeUnit"] : "g";
//           String servingSizeUnit = _unitMapping[rawUnit] ?? rawUnit;

//           fetchedFoods.add({
//             "name": item["description"],
//             "caloriesPer100g": caloriesPer100g,
//             "proteinPer100g": proteinPer100g,
//             "fatPer100g": fatPer100g,
//             "carbsPer100g": carbsPer100g,
//             "servingSize": servingSize,
//             "servingSizeUnit": servingSizeUnit,
//           });
//         }
//         setState(() {
//           foodResults = fetchedFoods;
//           isSearching = false;
//         });
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (e) {
//       print("Error: $e");
//       setState(() {
//         foodResults = [];
//         isSearching = false;
//       });
//     }
//   }

//   double _getNutrientValue(List nutrients, String nutrientName) {
//     return (nutrients.firstWhere(
//               (n) => n["nutrientName"] == nutrientName,
//               orElse: () => {"value": 0},
//             )["value"] ??
//             0)
//         .toDouble();
//   }

//   // When a food is selected, store its nutrient values and serving size info.
//   // Also set the quantity field to the default serving size.
//   void _selectPredefinedFood(String name, double calories, double protein,
//       double fat, double carbs, double servingSize, String servingSizeUnit) {
//     // Calculate nutrients for the given serving size
//     final double servingCalories = (calories * servingSize) / 100.0;
//     final double servingProtein = (protein * servingSize) / 100.0;
//     final double servingFat = (fat * servingSize) / 100.0;
//     final double servingCarbs = (carbs * servingSize) / 100.0;

//     print("Selected Food: $name");
//     print(
//         "API per 100g -> Calories: $calories, Protein: $protein, Fat: $fat, Carbs: $carbs");
//     print(
//         "Computed per ${servingSize.toStringAsFixed(2)} $servingSizeUnit -> Calories: ${servingCalories.toStringAsFixed(2)}, Protein: ${servingProtein.toStringAsFixed(2)}g, Fat: ${servingFat.toStringAsFixed(2)}g, Carbs: ${servingCarbs.toStringAsFixed(2)}g");

//     setState(() {
//       _foodController.text = name;
//       _selectedCaloriesPer100g = calories;
//       _selectedProteinPer100g = protein;
//       _selectedFatPer100g = fat;
//       _selectedCarbsPer100g = carbs;
//       _defaultServingSize = servingSize;
//       _defaultServingSizeUnit = servingSizeUnit;
//       _selectedInputMode =
//           (_defaultServingSizeUnit != "g") ? _defaultServingSizeUnit : "g";
//       _quantityController.text = _defaultServingSize.toStringAsFixed(2);
//       _calculateNutrients();
//       foodResults = [];
//     });
//   }

//   // Calculates nutrients based on the user's serving input.
//   void _calculateNutrients() {
//     double quantity = double.tryParse(_quantityController.text) ?? 0.0;

//     print("User Entered Quantity: $quantity $_selectedInputMode");

//     double grams;
//     if (_selectedInputMode == "g") {
//       grams = quantity;
//     } else if (_selectedInputMode == "mg") {
//       grams = quantity / 1000.0; // Convert mg to g
//     } else {
//       grams = quantity *
//           (_defaultServingSize / 100.0); // Convert based on serving size
//     }

//     print("Converted Grams: $grams g");

//     // Ensure that calculations are properly based on 100g scaling
//     setState(() {
//       _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100.0;
//       _calculatedProtein = (_selectedProteinPer100g * grams) / 100.0;
//       _calculatedFat = (_selectedFatPer100g * grams) / 100.0;
//       _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100.0;
//     });

//     print("Calculated Calories: $_calculatedCalories");
//     print("Calculated Protein: $_calculatedProtein g");
//     print("Calculated Fat: $_calculatedFat g");
//     print("Calculated Carbs: $_calculatedCarbs g");
//   }

//   void _addFoodEntry() {
//     String food = _foodController.text;
//     double quantityDouble = double.tryParse(_quantityController.text) ?? 0.0;
//     int quantity = quantityDouble.toInt();
//     if (food.isNotEmpty && quantityDouble > 0) {
//       widget.onFoodAdded(
//         food,
//         quantity,
//         _calculatedCalories.round(),
//         _calculatedProtein,
//         _calculatedFat,
//         _calculatedCarbs,
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Build dropdown items based on available input modes.
//     List<String> inputModes = ["g"];
//     if (_defaultServingSizeUnit != "g") {
//       inputModes.add(_defaultServingSizeUnit);
//     }
//     // Remove duplicates.
//     inputModes = inputModes.toSet().toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Food Entry')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Search field for food name.
//             TextField(
//               controller: _foodController,
//               onChanged: _fetchFoodData,
//               decoration: const InputDecoration(
//                 labelText:
//                     'Search (check serving size; nutrients values per 100g)',
//                 hintText: 'Type to search',
//                 suffixIcon: Icon(Icons.search),
//               ),
//             ),
//             if (isSearching)
//               const Padding(
//                 padding: EdgeInsets.only(top: 8.0),
//                 child: CircularProgressIndicator(),
//               ),
//             if (foodResults.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: foodResults.length,
//                   itemBuilder: (context, index) {
//                     final food = foodResults[index];
//                     return ListTile(
//                       title: Text(food['name']),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Per 100g:",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             "Calories: ${food['caloriesPer100g']} kcal, Protein: ${food['proteinPer100g']}g, Fat: ${food['fatPer100g']}g, Carbs: ${food['carbsPer100g']}g",
//                           ),
//                           if (food['servingSize'] != 100.0) ...[
//                             SizedBox(height: 8),
//                             Text(
//                               "Serving Size ${food['servingSize'].toStringAsFixed(2)} ${food['servingSizeUnit']}:",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               "Calories: ${(food['caloriesPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)} kcal, "
//                               "Protein: ${(food['proteinPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g, "
//                               "Fat: ${(food['fatPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g, "
//                               "Carbs: ${(food['carbsPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g",
//                             ),
//                           ],
//                         ],
//                       ),
//                       onTap: () {
//                         _selectPredefinedFood(
//                           food['name'],
//                           food['caloriesPer100g'],
//                           food['proteinPer100g'],
//                           food['fatPer100g'],
//                           food['carbsPer100g'],
//                           food['servingSize'],
//                           food['servingSizeUnit'],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             const SizedBox(height: 8),
//             // Row for serving input and mode selector.
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _quantityController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       labelText: _selectedInputMode == "g"
//                           ? "Serving Size"
//                           : "Number of ${_selectedInputMode}",
//                     ),
//                     onChanged: (_) => _calculateNutrients(),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 DropdownButton<String>(
//                   value: _selectedInputMode,
//                   items: inputModes.map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedInputMode = newValue!;
//                     });
//                     _calculateNutrients();
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Display calculated nutrient values.
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade400),
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.grey.shade100,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Calculated Nutrients:",
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                           "Calories: ${_calculatedCalories.toStringAsFixed(2)}"),
//                       Text(
//                           "Protein: ${_calculatedProtein.toStringAsFixed(2)} g"),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Fat: ${_calculatedFat.toStringAsFixed(2)} g"),
//                       Text("Carbs: ${_calculatedCarbs.toStringAsFixed(2)} g"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _addFoodEntry,
//               child: const Text('Add Food'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//updated GUI
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_fonts/google_fonts.dart';

// class FoodEntryScreen extends StatefulWidget {
//   final Function(String, int, int, double, double, double) onFoodAdded;

//   const FoodEntryScreen({Key? key, required this.onFoodAdded})
//       : super(key: key);

//   @override
//   _FoodEntryScreenState createState() => _FoodEntryScreenState();
// }

// class _FoodEntryScreenState extends State<FoodEntryScreen> {
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();

//   // App theme colors (same as the first code)
//   final Color primaryGreen = const Color(0xFF4CAF50);
//   final Color darkGreen = const Color(0xFF2E7D32);
//   final Color lightGreen = const Color(0xFFA5D6A7);
//   final Color bgDark = const Color(0xFF121212);
//   final Color cardDark = const Color(0xFF1E1E1E);
//   final Color inputDark = const Color(0xFF2A2A2A);
//   final Color textLight = const Color(0xFFE0E0E0);

//   // Variables to store the original per-100g nutrient values.
//   double _selectedCaloriesPer100g = 0.0;
//   double _selectedProteinPer100g = 0.0;
//   double _selectedFatPer100g = 0.0;
//   double _selectedCarbsPer100g = 0.0;

//   // Default serving size values.
//   double _defaultServingSize = 100.0;
//   String _defaultServingSizeUnit = "g"; // fallback unit

//   // Determines whether the user is entering input in grams ("g") or in the provided unit.
//   String _selectedInputMode = "g";

//   // Calculated nutrient values based on the user's input.
//   double _calculatedCalories = 0.0;
//   double _calculatedProtein = 0.0;
//   double _calculatedFat = 0.0;
//   double _calculatedCarbs = 0.0;

//   List<Map<String, dynamic>> foodResults = [];
//   bool isSearching = false;
//   bool _isSearchCardVisible = true;

//   static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
//   static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

//   // Mapping for units to more user-friendly labels.
//   final Map<String, String> _unitMapping = {
//     "GRM": "g",
//     "MLT": "ml",
//     "MG": "mg",
//     // Add more mappings as needed.
//   };

//   @override
//   void initState() {
//     super.initState();
//     _searchFocusNode.addListener(() {
//       setState(() {
//         _isSearchCardVisible =
//             !_searchFocusNode.hasFocus && foodResults.isEmpty;
//       });
//     });

//     _foodController.addListener(() {
//       setState(() {
//         _isSearchCardVisible = _foodController.text.isEmpty &&
//             !_searchFocusNode.hasFocus &&
//             foodResults.isEmpty;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchFocusNode.dispose();
//     _foodController.dispose();
//     _quantityController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchFoodData(String query) async {
//     if (query.length < 3) {
//       setState(() {
//         foodResults = [];
//         _isSearchCardVisible =
//             _foodController.text.isEmpty && !_searchFocusNode.hasFocus;
//       });
//       return;
//     }
//     setState(() {
//       isSearching = true;
//       _isSearchCardVisible = false;
//     });
//     final Uri url = Uri.parse("$baseUrl?query=$query&api_key=$apiKey");

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         List<Map<String, dynamic>> fetchedFoods = [];
//         for (var item in data["foods"]) {
//           List nutrients = item["foodNutrients"];

//           double caloriesPer100g = _getNutrientValue(nutrients, "Energy");
//           double proteinPer100g = _getNutrientValue(nutrients, "Protein");
//           double fatPer100g = _getNutrientValue(nutrients, "Total lipid (fat)");
//           double carbsPer100g =
//               _getNutrientValue(nutrients, "Carbohydrate, by difference");

//           double servingSize = item["servingSize"] != null
//               ? double.parse(
//                   (item["servingSize"] as num).toDouble().toStringAsFixed(2))
//               : 100.0;
//           String rawUnit =
//               item["servingSizeUnit"] != null ? item["servingSizeUnit"] : "g";
//           String servingSizeUnit = _unitMapping[rawUnit] ?? rawUnit;

//           fetchedFoods.add({
//             "name": item["description"],
//             "caloriesPer100g": caloriesPer100g,
//             "proteinPer100g": proteinPer100g,
//             "fatPer100g": fatPer100g,
//             "carbsPer100g": carbsPer100g,
//             "servingSize": servingSize,
//             "servingSizeUnit": servingSizeUnit,
//           });
//         }
//         setState(() {
//           foodResults = fetchedFoods;
//           isSearching = false;
//           _isSearchCardVisible = false;
//         });
//       } else {
//         throw Exception("Failed to load data");
//       }
//     } catch (e) {
//       print("Error: $e");
//       setState(() {
//         foodResults = [];
//         isSearching = false;
//         _isSearchCardVisible =
//             _foodController.text.isEmpty && !_searchFocusNode.hasFocus;
//       });
//     }
//   }

//   double _getNutrientValue(List nutrients, String nutrientName) {
//     return (nutrients.firstWhere(
//               (n) => n["nutrientName"] == nutrientName,
//               orElse: () => {"value": 0},
//             )["value"] ??
//             0)
//         .toDouble();
//   }

//   void _selectPredefinedFood(String name, double calories, double protein,
//       double fat, double carbs, double servingSize, String servingSizeUnit) {
//     final double servingCalories = (calories * servingSize) / 100.0;
//     final double servingProtein = (protein * servingSize) / 100.0;
//     final double servingFat = (fat * servingSize) / 100.0;
//     final double servingCarbs = (carbs * servingSize) / 100.0;

//     print("Selected Food: $name");
//     print(
//         "API per 100g -> Calories: $calories, Protein: $protein, Fat: $fat, Carbs: $carbs");
//     print(
//         "Computed per ${servingSize.toStringAsFixed(2)} $servingSizeUnit -> Calories: ${servingCalories.toStringAsFixed(2)}, Protein: ${servingProtein.toStringAsFixed(2)}g, Fat: ${servingFat.toStringAsFixed(2)}g, Carbs: ${servingCarbs.toStringAsFixed(2)}g");

//     setState(() {
//       _foodController.text = name;
//       _selectedCaloriesPer100g = calories;
//       _selectedProteinPer100g = protein;
//       _selectedFatPer100g = fat;
//       _selectedCarbsPer100g = carbs;
//       _defaultServingSize = servingSize;
//       _defaultServingSizeUnit = servingSizeUnit;
//       _selectedInputMode =
//           (_defaultServingSizeUnit != "g") ? _defaultServingSizeUnit : "g";
//       _quantityController.text = _defaultServingSize.toStringAsFixed(2);
//       _calculateNutrients();
//       foodResults = [];
//       _isSearchCardVisible = false;
//     });
//   }

//   void _calculateNutrients() {
//     double quantity = double.tryParse(_quantityController.text) ?? 0.0;

//     print("User Entered Quantity: $quantity $_selectedInputMode");

//     double grams;
//     if (_selectedInputMode == "g") {
//       grams = quantity;
//     } else if (_selectedInputMode == "mg") {
//       grams = quantity / 1000.0;
//     } else {
//       grams = quantity * (_defaultServingSize / 100.0);
//     }

//     print("Converted Grams: $grams g");

//     setState(() {
//       _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100.0;
//       _calculatedProtein = (_selectedProteinPer100g * grams) / 100.0;
//       _calculatedFat = (_selectedFatPer100g * grams) / 100.0;
//       _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100.0;
//     });

//     print("Calculated Calories: $_calculatedCalories");
//     print("Calculated Protein: $_calculatedProtein g");
//     print("Calculated Fat: $_calculatedFat g");
//     print("Calculated Carbs: $_calculatedCarbs g");
//   }

//   void _addFoodEntry() {
//     String food = _foodController.text;
//     double quantityDouble = double.tryParse(_quantityController.text) ?? 0.0;
//     int quantity = quantityDouble.toInt();
//     if (food.isNotEmpty && quantityDouble > 0) {
//       widget.onFoodAdded(
//         food,
//         quantity,
//         _calculatedCalories.round(),
//         _calculatedProtein,
//         _calculatedFat,
//         _calculatedCarbs,
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please enter a food name and quantity',
//             style: GoogleFonts.poppins(color: Colors.white),
//           ),
//           backgroundColor: Colors.redAccent,
//           behavior: SnackBarBehavior.floating,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       );
//     }
//   }

//   // Custom button widget (from the first code)
//   Widget _buildButton({
//     required String text,
//     required VoidCallback onPressed,
//     IconData? icon,
//     Color gradientStart = const Color(0xFF4CAF50),
//     Color gradientEnd = const Color(0xFF2E7D32),
//   }) {
//     return Container(
//       width: double.infinity,
//       height: 50,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: LinearGradient(
//           colors: [gradientStart, gradientEnd],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: gradientStart.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon != null) ...[
//               Icon(icon, color: Colors.white, size: 20),
//               const SizedBox(width: 8),
//             ],
//             Text(
//               text,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Nutrient chip widget (from the first code)
//   Widget _nutrientChip(String label, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: lightGreen.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         '$label: $value',
//         style: GoogleFonts.poppins(
//           fontSize: 12,
//           color: lightGreen,
//         ),
//       ),
//     );
//   }

//   // Nutrition row widget (from the first code)
//   Widget _nutritionRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: textLight,
//             ),
//           ),
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: lightGreen,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> inputModes = ["g"];
//     if (_defaultServingSizeUnit != "g") {
//       inputModes.add(_defaultServingSizeUnit);
//     }
//     inputModes = inputModes.toSet().toList();

//     return Theme(
//       data: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: bgDark,
//         primaryColor: primaryGreen,
//         colorScheme: ColorScheme.dark(
//           primary: primaryGreen,
//           secondary: lightGreen,
//           surface: cardDark,
//           background: bgDark,
//         ),
//         appBarTheme: AppBarTheme(
//           backgroundColor: darkGreen,
//           elevation: 0,
//           centerTitle: true,
//           titleTextStyle: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: inputDark,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade800),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade800),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: primaryGreen, width: 2),
//           ),
//           hintStyle: TextStyle(color: Colors.grey.shade600),
//           labelStyle: TextStyle(color: textLight),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         ),
//         cardTheme: CardTheme(
//           color: cardDark,
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//       child: Scaffold(
//         resizeToAvoidBottomInset:
//             false, // Prevent Scaffold from resizing when keyboard opens
//         appBar: AppBar(
//           title: Text(
//             'Add Food Entry',
//             style: GoogleFonts.poppins(),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               // Search field for food name
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: cardDark,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextField(
//                         controller: _foodController,
//                         focusNode: _searchFocusNode,
//                         onChanged: _fetchFoodData,
//                         style: GoogleFonts.poppins(color: textLight),
//                         decoration: InputDecoration(
//                           labelText: 'Search Food Database',
//                           hintText: 'Type at least 3 characters',
//                           prefixIcon: Icon(
//                             Icons.search,
//                             color: lightGreen.withOpacity(0.7),
//                           ),
//                           suffixIcon: _foodController.text.isNotEmpty
//                               ? IconButton(
//                                   icon: Icon(
//                                     Icons.clear,
//                                     color: lightGreen.withOpacity(0.7),
//                                   ),
//                                   onPressed: () {
//                                     setState(() {
//                                       _foodController.clear();
//                                       foodResults = [];
//                                       _isSearchCardVisible =
//                                           !_searchFocusNode.hasFocus;
//                                     });
//                                   },
//                                 )
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // Loading indicator or results count
//                       if (isSearching)
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16.0),
//                             child: CircularProgressIndicator(
//                               color: primaryGreen,
//                             ),
//                           ),
//                         )
//                       else if (foodResults.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 8.0),
//                           child: Text(
//                             '${foodResults.length} results found',
//                             style: GoogleFonts.poppins(
//                               color: Colors.grey.shade400,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Main content area (scrollable)
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(
//                     left: 20.0,
//                     right: 20.0,
//                     bottom: 20.0 +
//                         MediaQuery.of(context)
//                             .viewInsets
//                             .bottom, // Add padding for keyboard
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       // "Search for Food" card with subtle, faded appearance
//                       AnimatedOpacity(
//                         opacity: _isSearchCardVisible ? 1.0 : 0.0,
//                         duration: const Duration(milliseconds: 300),
//                         child: _isSearchCardVisible
//                             ? Container(
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   color: cardDark.withOpacity(0.5),
//                                   borderRadius: BorderRadius.circular(16),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.restaurant_menu,
//                                       size: 60,
//                                       color: lightGreen.withOpacity(0.5),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Text(
//                                       'Search for Food',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.bold,
//                                         color: textLight.withOpacity(0.6),
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Find nutritional information for your meal',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 14,
//                                         color: Colors.grey.shade400
//                                             .withOpacity(0.6),
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : const SizedBox.shrink(),
//                       ),

//                       // Search results (using full available height)
//                       if (foodResults.isNotEmpty)
//                         ListView.builder(
//                           physics:
//                               const NeverScrollableScrollPhysics(), // Disable inner scrolling
//                           shrinkWrap:
//                               true, // Allow ListView to take only the space it needs
//                           itemCount: foodResults.length,
//                           itemBuilder: (context, index) {
//                             final food = foodResults[index];
//                             return Card(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               child: InkWell(
//                                 onTap: () {
//                                   _selectPredefinedFood(
//                                     food['name'],
//                                     food['caloriesPer100g'],
//                                     food['proteinPer100g'],
//                                     food['fatPer100g'],
//                                     food['carbsPer100g'],
//                                     food['servingSize'],
//                                     food['servingSizeUnit'],
//                                   );
//                                 },
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         food['name'],
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w500,
//                                           color: textLight,
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 12),
//                                       Text(
//                                         "Per 100g:",
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.bold,
//                                           color: textLight,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Wrap(
//                                         spacing: 8,
//                                         runSpacing: 8,
//                                         children: [
//                                           _nutrientChip("Calories",
//                                               "${food['caloriesPer100g'].toStringAsFixed(0)}"),
//                                           _nutrientChip("Protein",
//                                               "${food['proteinPer100g'].toStringAsFixed(1)}g"),
//                                           _nutrientChip("Fat",
//                                               "${food['fatPer100g'].toStringAsFixed(1)}g"),
//                                           _nutrientChip("Carbs",
//                                               "${food['carbsPer100g'].toStringAsFixed(1)}g"),
//                                         ],
//                                       ),
//                                       if (food['servingSize'] != 100.0) ...[
//                                         const SizedBox(height: 12),
//                                         Text(
//                                           "Serving Size ${food['servingSize'].toStringAsFixed(2)} ${food['servingSizeUnit']}:",
//                                           style: GoogleFonts.poppins(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                             color: textLight,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Wrap(
//                                           spacing: 8,
//                                           runSpacing: 8,
//                                           children: [
//                                             _nutrientChip("Calories",
//                                                 "${(food['caloriesPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}"),
//                                             _nutrientChip("Protein",
//                                                 "${(food['proteinPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
//                                             _nutrientChip("Fat",
//                                                 "${(food['fatPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
//                                             _nutrientChip("Carbs",
//                                                 "${(food['carbsPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
//                                           ],
//                                         ),
//                                       ],
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       else if (_foodController.text.isNotEmpty && !isSearching)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 20.0),
//                           child: Center(
//                             child: Text(
//                               'No results found',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),

//                       // Nutrition display when food is selected
//                       if (_foodController.text.isNotEmpty &&
//                           foodResults.isEmpty &&
//                           !isSearching)
//                         Container(
//                           padding: const EdgeInsets.all(20),
//                           margin: const EdgeInsets.only(top: 20),
//                           decoration: BoxDecoration(
//                             color: cardDark,
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: primaryGreen.withOpacity(0.5),
//                               width: 2,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.2),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     flex: 3,
//                                     child: TextField(
//                                       controller: _quantityController,
//                                       keyboardType: TextInputType.number,
//                                       onChanged: (_) => _calculateNutrients(),
//                                       style:
//                                           GoogleFonts.poppins(color: textLight),
//                                       decoration: InputDecoration(
//                                         labelText: _selectedInputMode == "g"
//                                             ? "Serving Size"
//                                             : "Number of $_selectedInputMode",
//                                         hintText: 'Enter amount',
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     flex: 2,
//                                     child: DropdownButtonFormField<String>(
//                                       value: _selectedInputMode,
//                                       onChanged: (newValue) {
//                                         setState(() {
//                                           _selectedInputMode = newValue!;
//                                           _calculateNutrients();
//                                         });
//                                       },
//                                       items: inputModes.map((mode) {
//                                         return DropdownMenuItem(
//                                           value: mode,
//                                           child: Text(
//                                             mode,
//                                             style: GoogleFonts.poppins(
//                                                 color: textLight),
//                                           ),
//                                         );
//                                       }).toList(),
//                                       decoration: InputDecoration(
//                                         labelText: 'Unit',
//                                         border: const OutlineInputBorder(),
//                                       ),
//                                       dropdownColor: cardDark,
//                                       style:
//                                           GoogleFonts.poppins(color: textLight),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Nutrition Facts',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: primaryGreen,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               _nutritionRow('Calories',
//                                   '${_calculatedCalories.toStringAsFixed(0)} kcal'),
//                               _nutritionRow('Protein',
//                                   '${_calculatedProtein.toStringAsFixed(1)} g'),
//                               _nutritionRow('Fat',
//                                   '${_calculatedFat.toStringAsFixed(1)} g'),
//                               _nutritionRow('Carbs',
//                                   '${_calculatedCarbs.toStringAsFixed(1)} g'),
//                               const SizedBox(height: 24),
//                               _buildButton(
//                                 text: 'Add to Diary',
//                                 onPressed: _addFoodEntry,
//                                 icon: Icons.add_circle,
//                                 gradientStart: primaryGreen,
//                                 gradientEnd: darkGreen,
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//Image Uploading
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

class FoodEntryScreen extends StatefulWidget {
  final Function(String, int, int, double, double, double, String?) onFoodAdded;

  const FoodEntryScreen({Key? key, required this.onFoodAdded})
      : super(key: key);

  @override
  _FoodEntryScreenState createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  String? _foodImage;

  // App theme colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color inputDark = const Color(0xFF2A2A2A);
  final Color textLight = const Color(0xFFE0E0E0);

  // Variables to store the original per-100g nutrient values
  double _selectedCaloriesPer100g = 0.0;
  double _selectedProteinPer100g = 0.0;
  double _selectedFatPer100g = 0.0;
  double _selectedCarbsPer100g = 0.0;

  // Default serving size values
  double _defaultServingSize = 100.0;
  String _defaultServingSizeUnit = "g";

  // Determines whether the user is entering input in grams ("g") or in the provided unit
  String _selectedInputMode = "g";

  // Calculated nutrient values based on the user's input
  double _calculatedCalories = 0.0;
  double _calculatedProtein = 0.0;
  double _calculatedFat = 0.0;
  double _calculatedCarbs = 0.0;

  List<Map<String, dynamic>> foodResults = [];
  bool isSearching = false;
  bool _isSearchCardVisible = true;

  static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
  static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

  // Mapping for units to more user-friendly labels
  final Map<String, String> _unitMapping = {
    "GRM": "g",
    "MLT": "ml",
    "MG": "mg",
  };

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchCardVisible =
            !_searchFocusNode.hasFocus && foodResults.isEmpty;
      });
    });

    _foodController.addListener(() {
      setState(() {
        _isSearchCardVisible = _foodController.text.isEmpty &&
            !_searchFocusNode.hasFocus &&
            foodResults.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _foodController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoodData(String query) async {
    if (query.length < 3) {
      setState(() {
        foodResults = [];
        _isSearchCardVisible =
            _foodController.text.isEmpty && !_searchFocusNode.hasFocus;
      });
      return;
    }
    setState(() {
      isSearching = true;
      _isSearchCardVisible = false;
    });
    final Uri url = Uri.parse("$baseUrl?query=$query&api_key=$apiKey");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> fetchedFoods = [];
        for (var item in data["foods"]) {
          List nutrients = item["foodNutrients"];

          double caloriesPer100g = _getNutrientValue(nutrients, "Energy");
          double proteinPer100g = _getNutrientValue(nutrients, "Protein");
          double fatPer100g = _getNutrientValue(nutrients, "Total lipid (fat)");
          double carbsPer100g =
              _getNutrientValue(nutrients, "Carbohydrate, by difference");

          double servingSize = item["servingSize"] != null
              ? double.parse(
                  (item["servingSize"] as num).toDouble().toStringAsFixed(2))
              : 100.0;
          String rawUnit =
              item["servingSizeUnit"] != null ? item["servingSizeUnit"] : "g";
          String servingSizeUnit = _unitMapping[rawUnit] ?? rawUnit;

          fetchedFoods.add({
            "name": item["description"],
            "caloriesPer100g": caloriesPer100g,
            "proteinPer100g": proteinPer100g,
            "fatPer100g": fatPer100g,
            "carbsPer100g": carbsPer100g,
            "servingSize": servingSize,
            "servingSizeUnit": servingSizeUnit,
          });
        }
        setState(() {
          foodResults = fetchedFoods;
          isSearching = false;
          _isSearchCardVisible = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        foodResults = [];
        isSearching = false;
        _isSearchCardVisible =
            _foodController.text.isEmpty && !_searchFocusNode.hasFocus;
      });
    }
  }

  double _getNutrientValue(List nutrients, String nutrientName) {
    return (nutrients.firstWhere(
              (n) => n["nutrientName"] == nutrientName,
              orElse: () => {"value": 0},
            )["value"] ??
            0)
        .toDouble();
  }

  void _selectPredefinedFood(String name, double calories, double protein,
      double fat, double carbs, double servingSize, String servingSizeUnit) {
    final double servingCalories = (calories * servingSize) / 100.0;
    final double servingProtein = (protein * servingSize) / 100.0;
    final double servingFat = (fat * servingSize) / 100.0;
    final double servingCarbs = (carbs * servingSize) / 100.0;

    print("Selected Food: $name");
    print(
        "API per 100g -> Calories: $calories, Protein: $protein, Fat: $fat, Carbs: $carbs");
    print(
        "Computed per ${servingSize.toStringAsFixed(2)} $servingSizeUnit -> Calories: ${servingCalories.toStringAsFixed(2)}, Protein: ${servingProtein.toStringAsFixed(2)}g, Fat: ${servingFat.toStringAsFixed(2)}g, Carbs: ${servingCarbs.toStringAsFixed(2)}g");

    setState(() {
      _foodController.text = name;
      _selectedCaloriesPer100g = calories;
      _selectedProteinPer100g = protein;
      _selectedFatPer100g = fat;
      _selectedCarbsPer100g = carbs;
      _defaultServingSize = servingSize;
      _defaultServingSizeUnit = servingSizeUnit;
      _selectedInputMode =
          (_defaultServingSizeUnit != "g") ? _defaultServingSizeUnit : "g";
      _quantityController.text = _defaultServingSize.toStringAsFixed(2);
      _calculateNutrients();
      foodResults = [];
      _isSearchCardVisible = false;
    });
  }

  void _calculateNutrients() {
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;

    print("User Entered Quantity: $quantity $_selectedInputMode");

    double grams;
    if (_selectedInputMode == "g") {
      grams = quantity;
    } else if (_selectedInputMode == "mg") {
      grams = quantity / 1000.0;
    } else {
      grams = quantity * (_defaultServingSize / 100.0);
    }

    print("Converted Grams: $grams g");

    setState(() {
      _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100.0;
      _calculatedProtein = (_selectedProteinPer100g * grams) / 100.0;
      _calculatedFat = (_selectedFatPer100g * grams) / 100.0;
      _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100.0;
    });

    print("Calculated Calories: $_calculatedCalories");
    print("Calculated Protein: $_calculatedProtein g");
    print("Calculated Fat: $_calculatedFat g");
    print("Calculated Carbs: $_calculatedCarbs g");
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
      }

      if (status.isGranted) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          try {
            // Read the original image bytes
            final originalBytes = await pickedFile.readAsBytes();
            print("Original image size: ${originalBytes.length} bytes");
            print("Image path: ${pickedFile.path}");

            // Try to compress the image
            List<int> compressedBytes;
            try {
              compressedBytes = await FlutterImageCompress.compressWithList(
                originalBytes,
                minHeight: 300,
                minWidth: 300,
                quality: 70,
                format: CompressFormat.jpeg,
              );
              print("Compressed image size: ${compressedBytes.length} bytes");
            } catch (compressionError) {
              print("Compression failed: $compressionError");
              // Fallback to original bytes if compression fails, but only if the size is reasonable
              if (originalBytes.length > 1024 * 1024) {
                // 1MB limit
                throw Exception(
                    "Image too large to process without compression");
              }
              compressedBytes = originalBytes;
              print(
                  "Using original image size: ${compressedBytes.length} bytes");
            }

            // Convert to base64
            setState(() {
              _foodImage = base64Encode(compressedBytes);
            });
          } catch (e, stackTrace) {
            print("Error processing image: $e");
            print("Stack trace: $stackTrace");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to process image: $e',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } else {
          print("No image picked");
        }
      } else {
        print(
            "Permission denied for ${source == ImageSource.camera ? 'camera' : 'gallery'}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission denied. Please grant ${source == ImageSource.camera ? "camera" : "gallery"} access.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error requesting permission: $e");
      print("Stack trace: $stackTrace");
      if (e.toString().contains("MissingPluginException")) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission handling is not properly set up. Please reinstall the app or contact support.',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to request permission: $e',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: lightGreen),
              title: Text(
                'Take a Photo',
                style: GoogleFonts.poppins(color: textLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: lightGreen),
              title: Text(
                'Choose from Gallery',
                style: GoogleFonts.poppins(color: textLight),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _addFoodEntry() {
    String food = _foodController.text;
    double quantityDouble = double.tryParse(_quantityController.text) ?? 0.0;
    int quantity = quantityDouble.toInt();
    if (food.isNotEmpty && quantityDouble > 0) {
      widget.onFoodAdded(
        food,
        quantity,
        _calculatedCalories.round(),
        _calculatedProtein,
        _calculatedFat,
        _calculatedCarbs,
        _foodImage,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a food name and quantity',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
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

  Widget _nutrientChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: lightGreen,
        ),
      ),
    );
  }

  Widget _nutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              fontWeight: FontWeight.w600,
              color: lightGreen,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> inputModes = ["g"];
    if (_defaultServingSizeUnit != "g") {
      inputModes.add(_defaultServingSizeUnit);
    }
    inputModes = inputModes.toSet().toList();

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
        cardTheme: CardTheme(
          color: cardDark,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Add Food Entry',
            style: GoogleFonts.poppins(),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
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
                      TextField(
                        controller: _foodController,
                        focusNode: _searchFocusNode,
                        onChanged: _fetchFoodData,
                        style: GoogleFonts.poppins(color: textLight),
                        decoration: InputDecoration(
                          labelText: 'Search Food Database',
                          hintText: 'Type at least 3 characters',
                          prefixIcon: Icon(
                            Icons.search,
                            color: lightGreen.withOpacity(0.7),
                          ),
                          suffixIcon: _foodController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: lightGreen.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _foodController.clear();
                                      foodResults = [];
                                      _isSearchCardVisible =
                                          !_searchFocusNode.hasFocus;
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isSearching)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: CircularProgressIndicator(
                              color: primaryGreen,
                            ),
                          ),
                        )
                      else if (foodResults.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '${foodResults.length} results found',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _isSearchCardVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: _isSearchCardVisible
                            ? Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardDark.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 60,
                                      color: lightGreen.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Search for Food',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textLight.withOpacity(0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Find nutritional information for your meal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade400
                                            .withOpacity(0.6),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (foodResults.isNotEmpty)
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: foodResults.length,
                          itemBuilder: (context, index) {
                            final food = foodResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  _selectPredefinedFood(
                                    food['name'],
                                    food['caloriesPer100g'],
                                    food['proteinPer100g'],
                                    food['fatPer100g'],
                                    food['carbsPer100g'],
                                    food['servingSize'],
                                    food['servingSizeUnit'],
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food['name'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textLight,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Per 100g:",
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _nutrientChip("Calories",
                                              "${food['caloriesPer100g'].toStringAsFixed(0)}"),
                                          _nutrientChip("Protein",
                                              "${food['proteinPer100g'].toStringAsFixed(1)}g"),
                                          _nutrientChip("Fat",
                                              "${food['fatPer100g'].toStringAsFixed(1)}g"),
                                          _nutrientChip("Carbs",
                                              "${food['carbsPer100g'].toStringAsFixed(1)}g"),
                                        ],
                                      ),
                                      if (food['servingSize'] != 100.0) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          "Serving Size ${food['servingSize'].toStringAsFixed(2)} ${food['servingSizeUnit']}:",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textLight,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _nutrientChip("Calories",
                                                "${(food['caloriesPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}"),
                                            _nutrientChip("Protein",
                                                "${(food['proteinPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
                                            _nutrientChip("Fat",
                                                "${(food['fatPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
                                            _nutrientChip("Carbs",
                                                "${(food['carbsPer100g'] * food['servingSize'] / 100.0).toStringAsFixed(2)}g"),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else if (_foodController.text.isNotEmpty && !isSearching)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Text(
                              'No results found',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      if (_foodController.text.isNotEmpty &&
                          foodResults.isEmpty &&
                          !isSearching)
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 20),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _quantityController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _calculateNutrients(),
                                      style:
                                          GoogleFonts.poppins(color: textLight),
                                      decoration: InputDecoration(
                                        labelText: _selectedInputMode == "g"
                                            ? "Serving Size"
                                            : "Number of $_selectedInputMode",
                                        hintText: 'Enter amount',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedInputMode,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedInputMode = newValue!;
                                          _calculateNutrients();
                                        });
                                      },
                                      items: inputModes.map((mode) {
                                        return DropdownMenuItem(
                                          value: mode,
                                          child: Text(
                                            mode,
                                            style: GoogleFonts.poppins(
                                                color: textLight),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Unit',
                                        border: const OutlineInputBorder(),
                                      ),
                                      dropdownColor: cardDark,
                                      style:
                                          GoogleFonts.poppins(color: textLight),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Nutrition Facts',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _nutritionRow('Calories',
                                  '${_calculatedCalories.toStringAsFixed(0)} kcal'),
                              _nutritionRow('Protein',
                                  '${_calculatedProtein.toStringAsFixed(1)} g'),
                              _nutritionRow('Fat',
                                  '${_calculatedFat.toStringAsFixed(1)} g'),
                              _nutritionRow('Carbs',
                                  '${_calculatedCarbs.toStringAsFixed(1)} g'),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildButton(
                                      text: 'Add to Diary',
                                      onPressed: _addFoodEntry,
                                      icon: Icons.add_circle,
                                      gradientStart: primaryGreen,
                                      gradientEnd: darkGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: Icon(
                                      _foodImage == null
                                          ? Icons.camera_alt
                                          : Icons.check_circle,
                                      color: _foodImage == null
                                          ? lightGreen
                                          : primaryGreen,
                                      size: 40,
                                    ),
                                    onPressed: _showImagePickerOptions,
                                    tooltip: 'Add Food Image',
                                  ),
                                ],
                              ),
                              if (_foodImage != null) ...[
                                const SizedBox(height: 12),
                                Center(
                                  child: Image.memory(
                                    base64Decode(_foodImage!),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        color: lightGreen,
                                        size: 100,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
