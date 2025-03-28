//works with everything
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
//   final TextEditingController _gramsController = TextEditingController();

//   // Variables to store the original per-100g nutrient values.
//   double _selectedCaloriesPer100g = 0.0;
//   double _selectedProteinPer100g = 0.0;
//   double _selectedFatPer100g = 0.0;
//   double _selectedCarbsPer100g = 0.0;

//   // Calculated nutrient values based on grams input.
//   double _calculatedCalories = 0.0;
//   double _calculatedProtein = 0.0;
//   double _calculatedFat = 0.0;
//   double _calculatedCarbs = 0.0;

//   List<Map<String, dynamic>> foodResults = [];
//   bool isSearching = false;

//   static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
//   static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

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

//           fetchedFoods.add({
//             "name": item["description"],
//             "caloriesPer100g": caloriesPer100g,
//             "proteinPer100g": proteinPer100g,
//             "fatPer100g": fatPer100g,
//             "carbsPer100g": carbsPer100g,
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

//   void _selectPredefinedFood(
//       String name, double calories, double protein, double fat, double carbs) {
//     _foodController.text = name;
//     // Store per 100g values.
//     _selectedCaloriesPer100g = calories;
//     _selectedProteinPer100g = protein;
//     _selectedFatPer100g = fat;
//     _selectedCarbsPer100g = carbs;
//     // Do not pre-populate grams so the user can enter their own serving size.
//     _gramsController.text = "";
//     // Reset calculated nutrient values.
//     setState(() {
//       _calculatedCalories = 0.0;
//       _calculatedProtein = 0.0;
//       _calculatedFat = 0.0;
//       _calculatedCarbs = 0.0;
//       foodResults = [];
//     });
//   }

//   void _calculateNutrients() {
//     int grams = int.tryParse(_gramsController.text) ?? 0;
//     setState(() {
//       _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100;
//       _calculatedProtein = (_selectedProteinPer100g * grams) / 100;
//       _calculatedFat = (_selectedFatPer100g * grams) / 100;
//       _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100;
//     });
//   }

//   void _addFoodEntry() {
//     String food = _foodController.text;
//     int grams = int.tryParse(_gramsController.text) ?? 0;

//     if (food.isNotEmpty && grams > 0) {
//       widget.onFoodAdded(
//         food,
//         grams,
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
//                 labelText: 'Search (Results Per 100 gms)',
//                 hintText: 'Type to search or enter manually',
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
//                       subtitle: Text(
//                         "Calories: ${food['caloriesPer100g']} kcal\n"
//                         "Protein: ${food['proteinPer100g']}g | "
//                         "Fat: ${food['fatPer100g']}g | "
//                         "Carbs: ${food['carbsPer100g']}g",
//                       ),
//                       onTap: () {
//                         _selectPredefinedFood(
//                           food['name'],
//                           food['caloriesPer100g'],
//                           food['proteinPer100g'],
//                           food['fatPer100g'],
//                           food['carbsPer100g'],
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             // User inputs the serving size in grams.
//             TextField(
//               controller: _gramsController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Grams'),
//               onChanged: (_) => _calculateNutrients(),
//             ),
//             const SizedBox(height: 16),
//             // Display calculated nutrient values as non-editable text.
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

//works with everything + units and grams
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class FoodEntryScreen extends StatefulWidget {
  final Function(String, int, int, double, double, double) onFoodAdded;

  const FoodEntryScreen({super.key, required this.onFoodAdded});

  @override
  _FoodEntryScreenState createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // App theme colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color inputDark = const Color(0xFF2A2A2A);
  final Color textLight = const Color(0xFFE0E0E0);

  // Variables to store the original per-100g nutrient values.
  double _selectedCaloriesPer100g = 0.0;
  double _selectedProteinPer100g = 0.0;
  double _selectedFatPer100g = 0.0;
  double _selectedCarbsPer100g = 0.0;

  // Default serving size values.
  // If the API does not provide a serving size, we fall back to 100.
  double _defaultServingSize = 100.0;
  String _defaultServingSizeUnit = "g"; // fallback unit

  // Determines whether the user is entering input in grams ("g")
  // or in the provided unit (e.g. "ml", "mg", "unit").
  String _selectedInputMode = "g";

  // Calculated nutrient values based on the user's input.
  double _calculatedCalories = 0.0;
  double _calculatedProtein = 0.0;
  double _calculatedFat = 0.0;
  double _calculatedCarbs = 0.0;

  List<Map<String, dynamic>> foodResults = [];
  bool isSearching = false;

  static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
  static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

  // Mapping for units to more user-friendly labels.
  final Map<String, String> _unitMapping = {
    "GRM": "g",
    "MLT": "ml",
    "MG": "mg",
    // Add more mappings as needed.
  };

  Future<void> _fetchFoodData(String query) async {
    if (query.length < 3) {
      setState(() => foodResults = []);
      return;
    }
    setState(() => isSearching = true);
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

          // Check if API provides serving size information.
          double servingSize = item["servingSize"] != null
              ? (item["servingSize"] as num).toDouble()
              : 100.0;
          // Get raw serving unit and convert it using _unitMapping if available.
          String rawUnit = item["servingSizeUnit"] ?? "g";
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
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        foodResults = [];
        isSearching = false;
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

  // When a food is selected, store its nutrient values and serving size info.
  void _selectPredefinedFood(String name, double calories, double protein,
      double fat, double carbs, double servingSize, String servingSizeUnit) {
    _foodController.text = name;
    _selectedCaloriesPer100g = calories;
    _selectedProteinPer100g = protein;
    _selectedFatPer100g = fat;
    _selectedCarbsPer100g = carbs;
    _defaultServingSize = servingSize;
    _defaultServingSizeUnit = servingSizeUnit;
    // Default input mode: if the provided unit is not grams, use that; otherwise, "g".
    _selectedInputMode =
        (_defaultServingSizeUnit != "g") ? _defaultServingSizeUnit : "g";
    // Clear previous quantity input.
    _quantityController.text = "";
    // Reset calculated nutrient values.
    setState(() {
      _calculatedCalories = 0.0;
      _calculatedProtein = 0.0;
      _calculatedFat = 0.0;
      _calculatedCarbs = 0.0;
      foodResults = [];
    });
  }

  // Calculates nutrients based on the user's serving input.
  void _calculateNutrients() {
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double grams;
    if (_selectedInputMode == "g") {
      grams = quantity.toDouble();
    } else if (_selectedInputMode == "mg") {
      // Convert mg to grams: one serving is _defaultServingSize mg.
      grams = (quantity * _defaultServingSize) / 1000.0;
    } else {
      // For other units (e.g. "ml" or "unit"), assume one serving equals _defaultServingSize grams.
      grams = quantity * _defaultServingSize;
    }
    setState(() {
      _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100;
      _calculatedProtein = (_selectedProteinPer100g * grams) / 100;
      _calculatedFat = (_selectedFatPer100g * grams) / 100;
      _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100;
    });
  }

  void _addFoodEntry() {
    String food = _foodController.text;
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (food.isNotEmpty && quantity > 0) {
      widget.onFoodAdded(
        food,
        quantity,
        _calculatedCalories.round(),
        _calculatedProtein,
        _calculatedFat,
        _calculatedCarbs,
      );
      Navigator.pop(context);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a food name and quantity',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build dropdown items based on available input modes.
    List<String> inputModes = ["g"];
    if (_defaultServingSizeUnit != "g") {
      inputModes.add(_defaultServingSizeUnit);
    }
    // Remove duplicates.
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
          labelStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        cardTheme: CardTheme(
          color: cardDark,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: Scaffold(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: lightGreen, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Search for Food',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textLight,
                              ),
                            ),
                            Text(
                              'Find nutritional information for your meal',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search field for food name
                TextField(
                  controller: _foodController,
                  onChanged: _fetchFoodData,
                  style: GoogleFonts.poppins(color: textLight),
                  decoration: InputDecoration(
                    labelText: 'Search Food Database',
                    hintText: 'Type at least 3 characters',
                    prefixIcon: Icon(Icons.search, color: lightGreen.withOpacity(0.7)),
                    suffixIcon: _foodController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _foodController.clear();
                                foodResults = [];
                              });
                            },
                          )
                        : null,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Loading indicator or results count
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
                
                // Search results
                if (foodResults.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: foodResults.length,
                      itemBuilder: (context, index) {
                        final food = foodResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _nutrientChip("Calories", "${food['caloriesPer100g'].toStringAsFixed(0)}"),
                          _nutrientChip("Protein", "${food['proteinPer100g'].toStringAsFixed(1)}g"),
                          _nutrientChip("Fat", "${food['fatPer100g'].toStringAsFixed(1)}g"),
                          _nutrientChip("Carbs", "${food['carbsPer100g'].toStringAsFixed(1)}g"),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
                );
                },
                ),
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
                  )
                else if (_foodController.text.isEmpty && !isSearching)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show manual entry fields when no search results are displayed
                        if (_foodController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: lightGreen.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: _quantityController,
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => _calculateNutrients(),
                                        style: GoogleFonts.poppins(color: textLight),
                                        decoration: InputDecoration(
                                          labelText: 'Quantity',
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
                                            child: Text(mode),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Unit',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for a food item',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // Nutrition display when food is selected
                if (_foodController.text.isNotEmpty && foodResults.isEmpty && !isSearching)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(12),
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
                                    style: GoogleFonts.poppins(color: textLight),
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
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
                                        child: Text(mode),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'Unit',
                                      border: OutlineInputBorder(),
                                    ),
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
                                color: textLight,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _nutritionRow('Calories', '${_calculatedCalories.toStringAsFixed(0)} kcal'),
                            _nutritionRow('Protein', '${_calculatedProtein.toStringAsFixed(1)} g'),
                            _nutritionRow('Fat', '${_calculatedFat.toStringAsFixed(1)} g'),
                            _nutritionRow('Carbs', '${_calculatedCarbs.toStringAsFixed(1)} g'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _addFoodEntry,
                        child: Text('ADD TO DIARY'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
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
              color: Colors.grey.shade300,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textLight,
            ),
          ),
        ],
      ),
    );
  }
}