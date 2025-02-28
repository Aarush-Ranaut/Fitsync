import 'package:flutter/material.dart';

class CalorieCalculator extends StatefulWidget {
  @override
  _CalorieCalculatorState createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<CalorieCalculator> {
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _result = "";
  String _exampleCalculation = "";

  /// **Method to Calculate Calories**
  void _calculateCalories() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    double caloriesPer100g = double.tryParse(_calorieController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;
    double totalCalories = (caloriesPer100g / 100) * weight;

    setState(() {
      _result = "Total Calories: ${totalCalories.toStringAsFixed(2)} kcal";
      _exampleCalculation =
          "If a food item has ${caloriesPer100g.toStringAsFixed(2)} kcal per 100g, "
          "and you consume ${weight.toStringAsFixed(2)}g of it, then total calories will be:\n\n"
          "Total Calories = (${caloriesPer100g.toStringAsFixed(2)} kcal ÷ 100) × ${weight.toStringAsFixed(2)}g = "
          "${totalCalories.toStringAsFixed(2)} kcal";
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Hide keyboard when tapping outside
      },
      child: Scaffold(
        appBar: AppBar(title: Text("Calorie Calculator")),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // **Title**
              Text(
                "Calorie Calculator",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // **Calories per 100g Input**
              Text("Calories per 100g (kcal)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _calorieController,
                      keyboardType: TextInputType.number,
                      textInputAction:
                          TextInputAction.done, // Hide keyboard on "Done"
                      decoration: InputDecoration(
                        hintText: "e.g. 250",
                        border: OutlineInputBorder(),
                      ),
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("kcal", style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 20),

              // **Weight Input**
              Text("Serving Size (Weight in grams)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      textInputAction:
                          TextInputAction.done, // Hide keyboard on "Done"
                      decoration: InputDecoration(
                        hintText: "e.g. 150",
                        border: OutlineInputBorder(),
                      ),
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("g", style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 20),

              // **Calculate Button**
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateCalories,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Calculate"),
                ),
              ),
              SizedBox(height: 20),

              // **Result Text**
              Center(
                child: Text(
                  _result,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),

              // **Example Image (Optional)**
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 400,
                  child: Image.asset(
                    'assets/images/calorie_ex.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // **Example Calculation**
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Example Calculation:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _exampleCalculation.isNotEmpty
                          ? _exampleCalculation
                          : "If a food item has 250 kcal per 100g, and you consume 150g of it, "
                              "then total calories will be calculated as:\n\n"
                              "Total Calories = (250 kcal ÷ 100) × 150g = 375 kcal",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
