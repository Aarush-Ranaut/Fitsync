//works with everything
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
  final TextEditingController _gramsController = TextEditingController();

  // Variables to store the original per-100g nutrient values.
  double _selectedCaloriesPer100g = 0.0;
  double _selectedProteinPer100g = 0.0;
  double _selectedFatPer100g = 0.0;
  double _selectedCarbsPer100g = 0.0;

  // Calculated nutrient values based on grams input.
  double _calculatedCalories = 0.0;
  double _calculatedProtein = 0.0;
  double _calculatedFat = 0.0;
  double _calculatedCarbs = 0.0;

  List<Map<String, dynamic>> foodResults = [];
  bool isSearching = false;

  static const String apiKey = "6UgadxmxDGU8zKGrPQK8eHt2HYSiNMAGtyaswVLY";
  static const String baseUrl = "https://api.nal.usda.gov/fdc/v1/foods/search";

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

          fetchedFoods.add({
            "name": item["description"],
            "caloriesPer100g": caloriesPer100g,
            "proteinPer100g": proteinPer100g,
            "fatPer100g": fatPer100g,
            "carbsPer100g": carbsPer100g,
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

  void _selectPredefinedFood(
      String name, double calories, double protein, double fat, double carbs) {
    _foodController.text = name;
    // Store per 100g values.
    _selectedCaloriesPer100g = calories;
    _selectedProteinPer100g = protein;
    _selectedFatPer100g = fat;
    _selectedCarbsPer100g = carbs;
    // Do not pre-populate grams so the user can enter their own serving size.
    _gramsController.text = "";
    // Reset calculated nutrient values.
    setState(() {
      _calculatedCalories = 0.0;
      _calculatedProtein = 0.0;
      _calculatedFat = 0.0;
      _calculatedCarbs = 0.0;
      foodResults = [];
    });
  }

  void _calculateNutrients() {
    int grams = int.tryParse(_gramsController.text) ?? 0;
    setState(() {
      _calculatedCalories = (_selectedCaloriesPer100g * grams) / 100;
      _calculatedProtein = (_selectedProteinPer100g * grams) / 100;
      _calculatedFat = (_selectedFatPer100g * grams) / 100;
      _calculatedCarbs = (_selectedCarbsPer100g * grams) / 100;
    });
  }

  void _addFoodEntry() {
    String food = _foodController.text;
    int grams = int.tryParse(_gramsController.text) ?? 0;

    if (food.isNotEmpty && grams > 0) {
      widget.onFoodAdded(
        food,
        grams,
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
                labelText: 'Search (Results Per 100 gms)',
                hintText: 'Type to search or enter manually',
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
                        "Carbs: ${food['carbsPer100g']}g",
                      ),
                      onTap: () {
                        _selectPredefinedFood(
                          food['name'],
                          food['caloriesPer100g'],
                          food['proteinPer100g'],
                          food['fatPer100g'],
                          food['carbsPer100g'],
                        );
                      },
                    );
                  },
                ),
              ),
            // User inputs the serving size in grams.
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Grams'),
              onChanged: (_) => _calculateNutrients(),
            ),
            const SizedBox(height: 16),
            // Display calculated nutrient values as non-editable text.
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
