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

class FoodEntryScreen extends StatefulWidget {
  final Function(String, int, int, double, double, double) onFoodAdded;

  const FoodEntryScreen({Key? key, required this.onFoodAdded})
      : super(key: key);

  @override
  _FoodEntryScreenState createState() => _FoodEntryScreenState();
}

class _FoodEntryScreenState extends State<FoodEntryScreen> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

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
  //
  // Calculation logic:
  // - If input mode is "g": the entered quantity is directly in grams.
  // - If input mode is "mg": the entered quantity is the number of servings in mg.
  //   Total weight in grams = (quantity * defaultServingSize) / 1000.
  // - Otherwise (e.g. "ml" or "unit"): the entered quantity represents
  //   the number of servings; total grams = quantity * defaultServingSize.
  //
  // Test Cases:
  // 1. _defaultServingSize = 100, mode "g", quantity = 50  => grams = 50.
  // 2. _defaultServingSize = 200, mode "mg", quantity = 2  => grams = (2*200)/1000 = 0.4.
  // 3. _defaultServingSize = 60, mode "unit", quantity = 3 => grams = 3*60 = 180.
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

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field for food name.
            TextField(
              controller: _foodController,
              onChanged: _fetchFoodData,
              decoration: const InputDecoration(
                labelText: 'Search (Check Serving Size Carefully)',
                hintText: 'Type to search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            if (isSearching)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: CircularProgressIndicator(),
              ),
            if (foodResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: foodResults.length,
                  itemBuilder: (context, index) {
                    final food = foodResults[index];
                    return ListTile(
                      title: Text(food['name']),
                      subtitle: Text(
                        "Calories: ${food['caloriesPer100g']} kcal\n"
                        "Protein: ${food['proteinPer100g']}g | "
                        "Fat: ${food['fatPer100g']}g | "
                        "Carbs: ${food['carbsPer100g']}g\n"
                        "Serving: ${food['servingSize']} ${food['servingSizeUnit']}",
                      ),
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
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            // Row for serving input and mode selector.
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _selectedInputMode == "g"
                          ? "Serving Size in Grams or ML"
                          : "Number of ${_selectedInputMode}",
                    ),
                    onChanged: (_) => _calculateNutrients(),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedInputMode,
                  items: inputModes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedInputMode = newValue!;
                    });
                    _calculateNutrients();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display calculated nutrient values (non-editable).
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Calculated Nutrients:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Calories: ${_calculatedCalories.toStringAsFixed(2)}"),
                      Text(
                          "Protein: ${_calculatedProtein.toStringAsFixed(2)} g"),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fat: ${_calculatedFat.toStringAsFixed(2)} g"),
                      Text("Carbs: ${_calculatedCarbs.toStringAsFixed(2)} g"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFoodEntry,
              child: const Text('Add Food'),
            ),
          ],
        ),
      ),
    );
  }
}
