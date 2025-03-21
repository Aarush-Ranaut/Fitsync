import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'exercise_selection.dart';
import 'food_entry_screen.dart';
import 'maintenance_calorie_screen.dart';

class CalorieTracker extends StatefulWidget {
  const CalorieTracker({Key? key}) : super(key: key);

  @override
  _CalorieTrackerState createState() => _CalorieTrackerState();
}

class _CalorieTrackerState extends State<CalorieTracker> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _proteinGoalController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _gramsController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();

  // Default selected date is today.
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int dailyGoal = 0;
  int dailyProteinGoal = 0;
  List<Map<String, dynamic>> foodEntries = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _fetchDailyGoals();
      await _fetchFoodEntries();
    }
  }

  Future<void> _fetchDailyGoals() async {
    if (userId == null) return;

    // Clear previous goals while loading
    setState(() {
      dailyGoal = 0;
      dailyProteinGoal = 0;
    });

    // First try to get goal for selected date
    DocumentSnapshot dateGoalDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_goal')
        .doc(selectedDate)
        .get();

    if (dateGoalDoc.exists) {
      _updateGoalsFromDoc(dateGoalDoc);
      return;
    }

    // If no goal for selected date, find most recent goal
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_goal')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      _updateGoalsFromDoc(doc);
      // Add explicit type casting and null check
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await _saveCurrentDateGoal(data);
      }
    } else {
      _askForDailyGoals();
    }
  }

// Also update _updateGoalsFromDoc to handle type casting
  void _updateGoalsFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    setState(() {
      dailyGoal = (data['finalDailyCalorieGoal'] as num?)?.toInt() ?? 0;
      dailyProteinGoal = (data['dailyProteinIntake'] as num?)?.toInt() ?? 0;
    });
  }

  Future<void> _saveCurrentDateGoal(Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_goal')
        .doc(selectedDate)
        .set({
      ...data,
      'date': selectedDate,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _askForDailyGoals() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Your Daily Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Daily Calorie Goal'),
              ),
              TextField(
                controller: _proteinGoalController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Daily Protein Goal (g)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateDailyGoals();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDailyGoals() async {
    if (userId == null) return;

    int calorieGoal = int.tryParse(_goalController.text) ?? dailyGoal;
    int proteinGoal =
        int.tryParse(_proteinGoalController.text) ?? dailyProteinGoal;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_goal')
        .doc(selectedDate)
        .set({
      'finalDailyCalorieGoal': calorieGoal.toDouble(),
      'dailyProteinIntake': proteinGoal.toDouble(),
      'date': selectedDate,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() {
      dailyGoal = calorieGoal;
      dailyProteinGoal = proteinGoal;
    });
    _goalController.clear();
    _proteinGoalController.clear();
  }

  Future<void> _fetchFoodEntries() async {
    if (userId == null) return;
    QuerySnapshot foodSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('calories')
        .where('date', isEqualTo: selectedDate)
        .get();

    setState(() {
      foodEntries = foodSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  Future<void> _addOrEditFoodEntry({
    String? docId,
    required String food,
    required int grams,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
  }) async {
    if (userId == null) return;

    if (docId == null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calories')
          .add({
        'date': selectedDate,
        'foodName': food,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      });
    } else {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calories')
          .doc(docId)
          .update({
        'foodName': food,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      });
    }

    _fetchFoodEntries();
  }

  void _editFoodEntry(Map<String, dynamic> food) {
    _foodController.text = food['foodName'];
    _gramsController.text = food['grams'].toString();
    _caloriesController.text = food['calories'].toString();
    _proteinController.text = food['protein']?.toString() ?? '0';
    _fatController.text = food['fat']?.toString() ?? '0';
    _carbsController.text = food['carbs']?.toString() ?? '0';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Food Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _foodController,
                  decoration: const InputDecoration(labelText: 'Food Name'),
                ),
                TextField(
                  controller: _gramsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Grams'),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories'),
                ),
                TextField(
                  controller: _proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Protein'),
                ),
                TextField(
                  controller: _fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Fat'),
                ),
                TextField(
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Carbs'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrEditFoodEntry(
                  docId: food['id'],
                  food: _foodController.text,
                  grams: int.tryParse(_gramsController.text) ?? 0,
                  calories: int.tryParse(_caloriesController.text) ?? 0,
                  protein: double.tryParse(_proteinController.text) ?? 0,
                  fat: double.tryParse(_fatController.text) ?? 0,
                  carbs: double.tryParse(_carbsController.text) ?? 0,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFoodEntry(String docId) async {
    if (userId == null) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calories')
        .doc(docId)
        .delete();
    _fetchFoodEntries();
  }

  void _showAddFoodEntryDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodEntryScreen(
          onFoodAdded: (
            String food,
            int grams,
            int calories,
            double protein,
            double fat,
            double carbs,
          ) {
            _addOrEditFoodEntry(
              food: food,
              grams: grams,
              calories: calories,
              protein: protein,
              fat: fat,
              carbs: carbs,
            );
          },
        ),
      ),
    );
  }

  Future<void> _addFoodEntry(
    String food,
    int grams,
    int calories,
    double protein,
    double fat,
    double carbs,
  ) async {
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('calories')
        .add({
      'date': selectedDate,
      'foodName': food,
      'grams': grams,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    });

    _fetchFoodEntries();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Refresh both goals and food entries when date changes
      await _fetchDailyGoals();
      await _fetchFoodEntries();
    }
  }

  void _showGoalOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Daily Goals'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose how you want to set your goals:',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _askForDailyGoals();
                },
                child: Text('Enter Manually'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintenanceCalorieScreen(),
                    ),
                  ).then((_) async {
                    // Force refresh after returning
                    await _fetchDailyGoals();
                    await _fetchFoodEntries();
                  });
                },
                child: Text('Calculate Automatically'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularProgressIndicator({
    required String label,
    required double progress,
    required String total,
    required String goal,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: progress.clamp(0, 1),
                strokeWidth: 8,
                color: progress >= 1 ? Colors.red : Colors.green,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  total,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "/ $goal",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate daily totals for each nutrient.
    final totalCalories = foodEntries.fold(
        0, (sum, item) => sum + (item['calories'] as num).toInt());
    final totalProtein = foodEntries.fold(
        0.0, (sum, item) => sum + (item['protein'] as num).toDouble());
    final totalFat = foodEntries.fold(
        0.0, (sum, item) => sum + (item['fat'] as num).toDouble());
    final totalCarbs = foodEntries.fold(
        0.0, (sum, item) => sum + (item['carbs'] as num).toDouble());

    double progressCalories = dailyGoal > 0 ? totalCalories / dailyGoal : 0;
    double progressProtein =
        dailyProteinGoal > 0 ? totalProtein / dailyProteinGoal : 0;

    return WillPopScope(
      onWillPop: () async {
        // Navigate to ExerciseSelectionScreen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
          (Route<dynamic> route) => false,
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Calorie Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
              tooltip: 'Select Date (History)',
            ),
          ],
        ),
        body: userId == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Display circular progress indicators for calories and protein.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircularProgressIndicator(
                          label: 'Calories',
                          progress: progressCalories,
                          total: totalCalories.toString(),
                          goal: dailyGoal.toString(),
                        ),
                        _buildCircularProgressIndicator(
                          label: 'Protein (g)',
                          progress: progressProtein,
                          total: totalProtein.toStringAsFixed(0),
                          goal: dailyProteinGoal.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Display total fat and carbs.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('Fat (g)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(totalFat.toStringAsFixed(0)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Carbs (g)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(totalCarbs.toStringAsFixed(0)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _showGoalOptions,
                        child: const Text('Edit Daily Goals')),
                    const SizedBox(height: 10),
                    Text('Selected Date: $selectedDate',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: foodEntries.length,
                        itemBuilder: (context, index) {
                          final food = foodEntries[index];
                          return Card(
                            child: ListTile(
                              title: Text(food['foodName']),
                              // In the ListView.builder itemBuilder:
                              subtitle: Text(
                                '${food['grams']}g - ${food['calories']} cal${food['protein'] != null ? '\nProtein: ${(food['protein'] as double).toStringAsFixed(2)}g, '
                                    'Fat: ${(food['fat'] as double).toStringAsFixed(2)}g, '
                                    'Carbs: ${(food['carbs'] as double).toStringAsFixed(2)}g' : ''}',
                              ),
                              onTap: () => _editFoodEntry(food),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteFoodEntry(food['id']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Text('Total Calories: $totalCalories / $dailyGoal',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFoodEntryDialog,
          child: const Icon(Icons.add),
          tooltip: 'Add Food Entry',
        ),
      ),
    );
  }
}
