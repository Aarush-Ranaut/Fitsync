// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'exercise_selection.dart';
// import 'food_entry_screen.dart';
// import 'maintenance_calorie_screen.dart';

// class CalorieTracker extends StatefulWidget {
//   const CalorieTracker({Key? key}) : super(key: key);

//   @override
//   _CalorieTrackerState createState() => _CalorieTrackerState();
// }

// class _CalorieTrackerState extends State<CalorieTracker> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _goalController = TextEditingController();
//   final TextEditingController _proteinGoalController = TextEditingController();
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _gramsController = TextEditingController();
//   final TextEditingController _caloriesController = TextEditingController();
//   final TextEditingController _proteinController = TextEditingController();
//   final TextEditingController _fatController = TextEditingController();
//   final TextEditingController _carbsController = TextEditingController();

//   // Default selected date is today.
//   String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   int dailyGoal = 0;
//   int dailyProteinGoal = 0;
//   List<Map<String, dynamic>> foodEntries = [];
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _getUser();
//   }

//   Future<void> _getUser() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         userId = user.uid;
//       });
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   Future<void> _fetchDailyGoals() async {
//     if (userId == null) return;

//     // Clear previous goals while loading
//     setState(() {
//       dailyGoal = 0;
//       dailyProteinGoal = 0;
//     });

//     // First try to get goal for selected date
//     DocumentSnapshot dateGoalDoc = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .get();

//     if (dateGoalDoc.exists) {
//       _updateGoalsFromDoc(dateGoalDoc);
//       return;
//     }

//     // If no goal for selected date, find most recent goal
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       final doc = querySnapshot.docs.first;
//       _updateGoalsFromDoc(doc);
//       // Add explicit type casting and null check
//       final data = doc.data() as Map<String, dynamic>?;
//       if (data != null) {
//         await _saveCurrentDateGoal(data);
//       }
//     } else {
//       _askForDailyGoals();
//     }
//   }

// // Also update _updateGoalsFromDoc to handle type casting
//   void _updateGoalsFromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>?;
//     if (data == null) return;

//     setState(() {
//       dailyGoal = (data['finalDailyCalorieGoal'] as num?)?.toInt() ?? 0;
//       dailyProteinGoal = (data['dailyProteinIntake'] as num?)?.toInt() ?? 0;
//     });
//   }

//   Future<void> _saveCurrentDateGoal(Map<String, dynamic> data) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       ...data,
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> _askForDailyGoals() async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Set Your Daily Goals'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _goalController,
//                 keyboardType: TextInputType.number,
//                 decoration:
//                     const InputDecoration(labelText: 'Daily Calorie Goal'),
//               ),
//               TextField(
//                 controller: _proteinGoalController,
//                 keyboardType: TextInputType.number,
//                 decoration:
//                     const InputDecoration(labelText: 'Daily Protein Goal (g)'),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _updateDailyGoals();
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _updateDailyGoals() async {
//     if (userId == null) return;

//     int calorieGoal = int.tryParse(_goalController.text) ?? dailyGoal;
//     int proteinGoal =
//         int.tryParse(_proteinGoalController.text) ?? dailyProteinGoal;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       'finalDailyCalorieGoal': calorieGoal.toDouble(),
//       'dailyProteinIntake': proteinGoal.toDouble(),
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     setState(() {
//       dailyGoal = calorieGoal;
//       dailyProteinGoal = proteinGoal;
//     });
//     _goalController.clear();
//     _proteinGoalController.clear();
//   }

//   Future<void> _fetchFoodEntries() async {
//     if (userId == null) return;
//     QuerySnapshot foodSnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .where('date', isEqualTo: selectedDate)
//         .get();

//     setState(() {
//       foodEntries = foodSnapshot.docs
//           .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
//           .toList();
//     });
//   }

//   Future<void> _addOrEditFoodEntry({
//     String? docId,
//     required String food,
//     required int grams,
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//   }) async {
//     if (userId == null) return;

//     if (docId == null) {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .add({
//         'date': selectedDate,
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     } else {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .doc(docId)
//           .update({
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     }

//     _fetchFoodEntries();
//   }

//   void _editFoodEntry(Map<String, dynamic> food) {
//     _foodController.text = food['foodName'];
//     _gramsController.text = food['grams'].toString();
//     _caloriesController.text = food['calories'].toString();
//     _proteinController.text = food['protein']?.toString() ?? '0';
//     _fatController.text = food['fat']?.toString() ?? '0';
//     _carbsController.text = food['carbs']?.toString() ?? '0';

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Edit Food Entry'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _foodController,
//                   decoration: const InputDecoration(labelText: 'Food Name'),
//                 ),
//                 TextField(
//                   controller: _gramsController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Grams'),
//                 ),
//                 TextField(
//                   controller: _caloriesController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Calories'),
//                 ),
//                 TextField(
//                   controller: _proteinController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Protein'),
//                 ),
//                 TextField(
//                   controller: _fatController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Fat'),
//                 ),
//                 TextField(
//                   controller: _carbsController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(labelText: 'Carbs'),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _addOrEditFoodEntry(
//                   docId: food['id'],
//                   food: _foodController.text,
//                   grams: int.tryParse(_gramsController.text) ?? 0,
//                   calories: int.tryParse(_caloriesController.text) ?? 0,
//                   protein: double.tryParse(_proteinController.text) ?? 0,
//                   fat: double.tryParse(_fatController.text) ?? 0,
//                   carbs: double.tryParse(_carbsController.text) ?? 0,
//                 );
//                 Navigator.pop(context);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deleteFoodEntry(String docId) async {
//     if (userId == null) return;
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .doc(docId)
//         .delete();
//     _fetchFoodEntries();
//   }

//   void _showAddFoodEntryDialog() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodEntryScreen(
//           onFoodAdded: (
//             String food,
//             int grams,
//             int calories,
//             double protein,
//             double fat,
//             double carbs,
//           ) {
//             _addOrEditFoodEntry(
//               food: food,
//               grams: grams,
//               calories: calories,
//               protein: protein,
//               fat: fat,
//               carbs: carbs,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _addFoodEntry(
//     String food,
//     int grams,
//     int calories,
//     double protein,
//     double fat,
//     double carbs,
//   ) async {
//     if (userId == null) return;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .add({
//       'date': selectedDate,
//       'foodName': food,
//       'grams': grams,
//       'calories': calories,
//       'protein': protein,
//       'fat': fat,
//       'carbs': carbs,
//     });

//     _fetchFoodEntries();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.parse(selectedDate),
//       firstDate: DateTime(2024, 1, 1),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = DateFormat('yyyy-MM-dd').format(picked);
//       });
//       // Refresh both goals and food entries when date changes
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   void _showGoalOptions() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Set Daily Goals'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Choose how you want to set your goals:',
//                   style: TextStyle(fontSize: 16)),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _askForDailyGoals();
//                 },
//                 child: Text('Enter Manually'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50),
//                 ),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MaintenanceCalorieScreen(),
//                     ),
//                   ).then((_) async {
//                     // Force refresh after returning
//                     await _fetchDailyGoals();
//                     await _fetchFoodEntries();
//                   });
//                 },
//                 child: Text('Calculate Automatically'),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: Size(double.infinity, 50),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCircularProgressIndicator({
//     required String label,
//     required double progress,
//     required String total,
//     required String goal,
//   }) {
//     return Column(
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               height: 80,
//               width: 80,
//               child: CircularProgressIndicator(
//                 value: progress.clamp(0, 1),
//                 strokeWidth: 8,
//                 color: progress >= 1 ? Colors.red : Colors.green,
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   total,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Text(
//                   "/ $goal",
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(label),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Calculate daily totals for each nutrient.
//     final totalCalories = foodEntries.fold(
//         0, (sum, item) => sum + (item['calories'] as num).toInt());
//     final totalProtein = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['protein'] as num).toDouble());
//     final totalFat = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['fat'] as num).toDouble());
//     final totalCarbs = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['carbs'] as num).toDouble());

//     double progressCalories = dailyGoal > 0 ? totalCalories / dailyGoal : 0;
//     double progressProtein =
//         dailyProteinGoal > 0 ? totalProtein / dailyProteinGoal : 0;

//     return WillPopScope(
//       onWillPop: () async {
//         // Navigate to ExerciseSelectionScreen and remove all previous routes
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
//           (Route<dynamic> route) => false,
//         );
//         return false; // Prevent default back behavior
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Daily Calorie Tracker'),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.calendar_today),
//               onPressed: () => _selectDate(context),
//               tooltip: 'Select Date (History)',
//             ),
//           ],
//         ),
//         body: userId == null
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     // Display circular progress indicators for calories and protein.
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildCircularProgressIndicator(
//                           label: 'Calories',
//                           progress: progressCalories,
//                           total: totalCalories.toString(),
//                           goal: dailyGoal.toString(),
//                         ),
//                         _buildCircularProgressIndicator(
//                           label: 'Protein (g)',
//                           progress: progressProtein,
//                           total: totalProtein.toStringAsFixed(0),
//                           goal: dailyProteinGoal.toString(),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     // Display total fat and carbs.
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Column(
//                           children: [
//                             const Text('Fat (g)',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16)),
//                             const SizedBox(height: 4),
//                             Text(totalFat.toStringAsFixed(0)),
//                           ],
//                         ),
//                         Column(
//                           children: [
//                             const Text('Carbs (g)',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16)),
//                             const SizedBox(height: 4),
//                             Text(totalCarbs.toStringAsFixed(0)),
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                         onPressed: _showGoalOptions,
//                         child: const Text('Edit Daily Goals')),
//                     const SizedBox(height: 10),
//                     Text('Selected Date: $selectedDate',
//                         style: const TextStyle(fontSize: 16)),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: foodEntries.length,
//                         itemBuilder: (context, index) {
//                           final food = foodEntries[index];
//                           return Card(
//                             child: ListTile(
//                               title: Text(food['foodName']),
//                               // In the ListView.builder itemBuilder:
//                               subtitle: Text(
//                                 '${food['grams']}g - ${food['calories']} cal${food['protein'] != null ? '\nProtein: ${(food['protein'] as double).toStringAsFixed(2)}g, '
//                                     'Fat: ${(food['fat'] as double).toStringAsFixed(2)}g, '
//                                     'Carbs: ${(food['carbs'] as double).toStringAsFixed(2)}g' : ''}',
//                               ),
//                               onTap: () => _editFoodEntry(food),
//                               trailing: IconButton(
//                                 icon:
//                                     const Icon(Icons.delete, color: Colors.red),
//                                 onPressed: () {
//                                   _deleteFoodEntry(food['id']);
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Text('Total Calories: $totalCalories / $dailyGoal',
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showAddFoodEntryDialog,
//           child: const Icon(Icons.add),
//           tooltip: 'Add Food Entry',
//         ),
//       ),
//     );
//   }
// }

//GUI Updated
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'exercise_selection.dart';
// import 'food_entry_screen.dart';
// import 'maintenance_calorie_screen.dart';

// class CalorieTracker extends StatefulWidget {
//   const CalorieTracker({Key? key}) : super(key: key);

//   @override
//   _CalorieTrackerState createState() => _CalorieTrackerState();
// }

// class _CalorieTrackerState extends State<CalorieTracker> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _goalController = TextEditingController();
//   final TextEditingController _proteinGoalController = TextEditingController();
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _gramsController = TextEditingController();
//   final TextEditingController _caloriesController = TextEditingController();
//   final TextEditingController _proteinController = TextEditingController();
//   final TextEditingController _fatController = TextEditingController();
//   final TextEditingController _carbsController = TextEditingController();

//   // App theme colors (same as the first code)
//   final Color primaryGreen = const Color(0xFF4CAF50);
//   final Color darkGreen = const Color(0xFF2E7D32);
//   final Color lightGreen = const Color(0xFFA5D6A7);
//   final Color bgDark = const Color(0xFF121212);
//   final Color cardDark = const Color(0xFF1E1E1E);
//   final Color textLight = const Color(0xFFE0E0E0);

//   // Default selected date is today.
//   String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   int dailyGoal = 0;
//   int dailyProteinGoal = 0;
//   List<Map<String, dynamic>> foodEntries = [];
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _getUser();
//   }

//   Future<void> _getUser() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         userId = user.uid;
//       });
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   Future<void> _fetchDailyGoals() async {
//     if (userId == null) return;

//     // Clear previous goals while loading
//     setState(() {
//       dailyGoal = 0;
//       dailyProteinGoal = 0;
//     });

//     // First try to get goal for selected date
//     DocumentSnapshot dateGoalDoc = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .get();

//     if (dateGoalDoc.exists) {
//       _updateGoalsFromDoc(dateGoalDoc);
//       return;
//     }

//     // If no goal for selected date, find most recent goal
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       final doc = querySnapshot.docs.first;
//       _updateGoalsFromDoc(doc);
//       final data = doc.data() as Map<String, dynamic>?;
//       if (data != null) {
//         await _saveCurrentDateGoal(data);
//       }
//     } else {
//       _askForDailyGoals();
//     }
//   }

//   void _updateGoalsFromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>?;
//     if (data == null) return;

//     setState(() {
//       dailyGoal = (data['finalDailyCalorieGoal'] as num?)?.toInt() ?? 0;
//       dailyProteinGoal = (data['dailyProteinIntake'] as num?)?.toInt() ?? 0;
//     });
//   }

//   Future<void> _saveCurrentDateGoal(Map<String, dynamic> data) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       ...data,
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> _askForDailyGoals() async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Set Your Daily Goals',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _goalController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: textLight),
//                 decoration: InputDecoration(
//                   labelText: 'Daily Calorie Goal',
//                   labelStyle: TextStyle(color: lightGreen),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen, width: 2),
//                   ),
//                 ),
//               ),
//               TextField(
//                 controller: _proteinGoalController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: textLight),
//                 decoration: InputDecoration(
//                   labelText: 'Daily Protein Goal (g)',
//                   labelStyle: TextStyle(color: lightGreen),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen, width: 2),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: lightGreen)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryGreen,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 _updateDailyGoals();
//                 Navigator.pop(context);
//               },
//               child: Text('Save', style: GoogleFonts.poppins()),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _updateDailyGoals() async {
//     if (userId == null) return;

//     int calorieGoal = int.tryParse(_goalController.text) ?? dailyGoal;
//     int proteinGoal =
//         int.tryParse(_proteinGoalController.text) ?? dailyProteinGoal;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       'finalDailyCalorieGoal': calorieGoal.toDouble(),
//       'dailyProteinIntake': proteinGoal.toDouble(),
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     setState(() {
//       dailyGoal = calorieGoal;
//       dailyProteinGoal = proteinGoal;
//     });
//     _goalController.clear();
//     _proteinGoalController.clear();
//   }

//   Future<void> _fetchFoodEntries() async {
//     if (userId == null) return;
//     QuerySnapshot foodSnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .where('date', isEqualTo: selectedDate)
//         .get();

//     setState(() {
//       foodEntries = foodSnapshot.docs
//           .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
//           .toList();
//     });
//   }

//   Future<void> _addOrEditFoodEntry({
//     String? docId,
//     required String food,
//     required int grams,
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//   }) async {
//     if (userId == null) return;

//     if (docId == null) {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .add({
//         'date': selectedDate,
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     } else {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .doc(docId)
//           .update({
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     }

//     _fetchFoodEntries();
//   }

//   void _editFoodEntry(Map<String, dynamic> food) {
//     _foodController.text = food['foodName'];
//     _gramsController.text = food['grams'].toString();
//     _caloriesController.text = food['calories'].toString();
//     _proteinController.text = food['protein']?.toString() ?? '0';
//     _fatController.text = food['fat']?.toString() ?? '0';
//     _carbsController.text = food['carbs']?.toString() ?? '0';

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Edit Food Entry',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _foodController,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Food Name',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 TextField(
//                   controller: _gramsController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Grams',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 TextField(
//                   controller: _caloriesController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Calories',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 TextField(
//                   controller: _proteinController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Protein',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 TextField(
//                   controller: _fatController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Fat',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 TextField(
//                   controller: _carbsController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Carbs',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: lightGreen)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryGreen,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 _addOrEditFoodEntry(
//                   docId: food['id'],
//                   food: _foodController.text,
//                   grams: int.tryParse(_gramsController.text) ?? 0,
//                   calories: int.tryParse(_caloriesController.text) ?? 0,
//                   protein: double.tryParse(_proteinController.text) ?? 0,
//                   fat: double.tryParse(_fatController.text) ?? 0,
//                   carbs: double.tryParse(_carbsController.text) ?? 0,
//                 );
//                 Navigator.pop(context);
//               },
//               child: Text('Save', style: GoogleFonts.poppins()),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deleteFoodEntry(String docId) async {
//     if (userId == null) return;

//     // Show confirmation dialog
//     bool confirm = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             backgroundColor: cardDark,
//             title: Text(
//               'Delete Entry',
//               style: GoogleFonts.poppins(
//                 color: textLight,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             content: Text(
//               'Are you sure you want to delete this food entry?',
//               style: TextStyle(color: textLight),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text('Cancel', style: TextStyle(color: lightGreen)),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   foregroundColor: Colors.white,
//                 ),
//                 onPressed: () => Navigator.pop(context, true),
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (confirm) {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .doc(docId)
//           .delete();
//       _fetchFoodEntries();
//     }
//   }

//   void _showAddFoodEntryDialog() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodEntryScreen(
//           onFoodAdded: (
//             String food,
//             int grams,
//             int calories,
//             double protein,
//             double fat,
//             double carbs,
//           ) {
//             _addOrEditFoodEntry(
//               food: food,
//               grams: grams,
//               calories: calories,
//               protein: protein,
//               fat: fat,
//               carbs: carbs,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _addFoodEntry(
//     String food,
//     int grams,
//     int calories,
//     double protein,
//     double fat,
//     double carbs,
//   ) async {
//     if (userId == null) return;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .add({
//       'date': selectedDate,
//       'foodName': food,
//       'grams': grams,
//       'calories': calories,
//       'protein': protein,
//       'fat': fat,
//       'carbs': carbs,
//     });

//     _fetchFoodEntries();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.parse(selectedDate),
//       firstDate: DateTime(2024, 1, 1),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: primaryGreen,
//               onPrimary: Colors.white,
//               surface: cardDark,
//               onSurface: textLight,
//             ),
//             dialogBackgroundColor: bgDark,
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = DateFormat('yyyy-MM-dd').format(picked);
//       });
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   void _showGoalOptions() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Set Daily Goals',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Choose how you want to set your goals:',
//                 style: GoogleFonts.poppins(
//                   color: textLight,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _askForDailyGoals();
//                 },
//                 child: Text(
//                   'Enter Manually',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MaintenanceCalorieScreen(),
//                     ),
//                   ).then((_) async {
//                     await _fetchDailyGoals();
//                     await _fetchFoodEntries();
//                   });
//                 },
//                 child: Text(
//                   'Calculate Automatically',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Circular progress indicator widget (from the first code)
//   Widget _buildCircularProgressIndicator({
//     required String label,
//     required double progress,
//     required String total,
//     required String goal,
//     required IconData icon,
//   }) {
//     Color progressColor;
//     if (progress >= 1) {
//       progressColor = Colors.redAccent;
//     } else if (progress >= 0.8) {
//       progressColor = Colors.orangeAccent;
//     } else {
//       progressColor = primaryGreen;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: lightGreen, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 height: 100,
//                 width: 100,
//                 child: CircularProgressIndicator(
//                   value: progress.clamp(0, 1),
//                   strokeWidth: 10,
//                   backgroundColor: Colors.grey.shade800,
//                   color: progressColor,
//                 ),
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     total,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: textLight,
//                     ),
//                   ),
//                   Text(
//                     "/ $goal",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Nutrient card widget (from the first code)
//   Widget _buildNutrientCard({
//     required String label,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: lightGreen, size: 20),
//           const SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey.shade400,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: GoogleFonts.poppins(
//                   color: textLight,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Calculate daily totals for each nutrient.
//     final totalCalories = foodEntries.fold(
//         0, (sum, item) => sum + (item['calories'] as num).toInt());
//     final totalProtein = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['protein'] as num).toDouble());
//     final totalFat = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['fat'] as num).toDouble());
//     final totalCarbs = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['carbs'] as num).toDouble());

//     double progressCalories = dailyGoal > 0 ? totalCalories / dailyGoal : 0;
//     double progressProtein =
//         dailyProteinGoal > 0 ? totalProtein / dailyProteinGoal : 0;

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
//           (Route<dynamic> route) => false,
//         );
//         return false;
//       },
//       child: Theme(
//         data: ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: bgDark,
//           primaryColor: primaryGreen,
//           colorScheme: ColorScheme.dark(
//             primary: primaryGreen,
//             secondary: lightGreen,
//             surface: cardDark,
//             background: bgDark,
//           ),
//           appBarTheme: AppBarTheme(
//             backgroundColor: darkGreen,
//             elevation: 0,
//             centerTitle: true,
//             titleTextStyle: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: cardDark,
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           floatingActionButtonTheme: FloatingActionButtonThemeData(
//             backgroundColor: primaryGreen,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryGreen,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text(
//               'NutriTrack',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.calendar_today),
//                 onPressed: () => _selectDate(context),
//                 tooltip: 'Select Date (History)',
//               ),
//             ],
//           ),
//           body: userId == null
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: primaryGreen,
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Date display
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: cardDark,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.calendar_today,
//                                   color: lightGreen, size: 18),
//                               const SizedBox(width: 8),
//                               Text(
//                                 DateFormat('EEEE, MMMM d')
//                                     .format(DateTime.parse(selectedDate)),
//                                 style: GoogleFonts.poppins(
//                                   color: textLight,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Progress indicators
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildCircularProgressIndicator(
//                                 label: 'Calories',
//                                 progress: progressCalories,
//                                 total: totalCalories.toString(),
//                                 goal: dailyGoal.toString(),
//                                 icon: Icons.local_fire_department,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildCircularProgressIndicator(
//                                 label: 'Protein',
//                                 progress: progressProtein,
//                                 total: totalProtein.toStringAsFixed(0),
//                                 goal: dailyProteinGoal.toString(),
//                                 icon: Icons.fitness_center,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Macronutrients row
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildNutrientCard(
//                                 label: 'Fat (g)',
//                                 value: totalFat.toStringAsFixed(0),
//                                 icon: Icons.opacity,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _buildNutrientCard(
//                                 label: 'Carbs (g)',
//                                 value: totalCarbs.toStringAsFixed(0),
//                                 icon: Icons.grain,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Goals button
//                         ElevatedButton.icon(
//                           onPressed: _showGoalOptions,
//                           icon: const Icon(Icons.edit),
//                           label: Text(
//                             'Edit Daily Goals',
//                             style: GoogleFonts.poppins(),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size(double.infinity, 48),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Food entries section
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Today's Food",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: textLight,
//                               ),
//                             ),
//                             Text(
//                               '${foodEntries.length} items',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),

//                         // Food entries list
//                         foodEntries.isEmpty
//                             ? Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: cardDark,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border:
//                                       Border.all(color: Colors.grey.shade800),
//                                 ),
//                                 child: Center(
//                                   child: Column(
//                                     children: [
//                                       Icon(
//                                         Icons.no_food,
//                                         size: 48,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         'No food entries yet',
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.grey.shade400,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Tap the + button to add your first meal',
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.grey.shade600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             : ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: foodEntries.length,
//                                 separatorBuilder: (context, index) =>
//                                     const SizedBox(height: 8),
//                                 itemBuilder: (context, index) {
//                                   final food = foodEntries[index];
//                                   return Card(
//                                     margin: EdgeInsets.zero,
//                                     child: ListTile(
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 8,
//                                       ),
//                                       leading: Container(
//                                         width: 48,
//                                         height: 48,
//                                         decoration: BoxDecoration(
//                                           color: lightGreen.withOpacity(0.2),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Icon(
//                                           Icons.restaurant,
//                                           color: lightGreen,
//                                         ),
//                                       ),
//                                       title: Text(
//                                         food['foodName'],
//                                         style: GoogleFonts.poppins(
//                                           fontWeight: FontWeight.w600,
//                                           color: textLight,
//                                         ),
//                                       ),
//                                       subtitle: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 '${food['calories']} cal',
//                                                 style: GoogleFonts.poppins(
//                                                   color: primaryGreen,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 ' • ${food['grams']}g',
//                                                 style: TextStyle(
//                                                     color:
//                                                         Colors.grey.shade400),
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             'P: ${(food['protein'] as num).toDouble().toStringAsFixed(2)}g • F: ${(food['fat'] as num).toDouble().toStringAsFixed(2)}g • C: ${(food['carbs'] as num).toDouble().toStringAsFixed(2)}g',
//                                             style: TextStyle(
//                                               color: Colors.grey.shade500,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       trailing: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(
//                                               Icons.edit,
//                                               color: lightGreen,
//                                               size: 20,
//                                             ),
//                                             onPressed: () =>
//                                                 _editFoodEntry(food),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(
//                                               Icons.delete_outline,
//                                               color: Colors.redAccent,
//                                               size: 20,
//                                             ),
//                                             onPressed: () {
//                                               _deleteFoodEntry(food['id']);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: _showAddFoodEntryDialog,
//             tooltip: 'Add Food Entry',
//             icon: const Icon(Icons.add),
//             label: Text(
//               'Add Food',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//GUI Updated
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'exercise_selection.dart';
// import 'food_entry_screen.dart';
// import 'maintenance_calorie_screen.dart';

// class CalorieTracker extends StatefulWidget {
//   const CalorieTracker({Key? key}) : super(key: key);

//   @override
//   _CalorieTrackerState createState() => _CalorieTrackerState();
// }

// class _CalorieTrackerState extends State<CalorieTracker> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   final TextEditingController _goalController = TextEditingController();
//   final TextEditingController _proteinGoalController = TextEditingController();
//   final TextEditingController _foodController = TextEditingController();
//   final TextEditingController _gramsController = TextEditingController();
//   final TextEditingController _caloriesController = TextEditingController();
//   final TextEditingController _proteinController = TextEditingController();
//   final TextEditingController _fatController = TextEditingController();
//   final TextEditingController _carbsController = TextEditingController();

//   // App theme colors (same as the first code)
//   final Color primaryGreen = const Color(0xFF4CAF50);
//   final Color darkGreen = const Color(0xFF2E7D32);
//   final Color lightGreen = const Color(0xFFA5D6A7);
//   final Color bgDark = const Color(0xFF121212);
//   final Color cardDark = const Color(0xFF1E1E1E);
//   final Color textLight = const Color(0xFFE0E0E0);

//   // Default selected date is today.
//   String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   int dailyGoal = 0;
//   int dailyProteinGoal = 0;
//   List<Map<String, dynamic>> foodEntries = [];
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _getUser();
//   }

//   Future<void> _getUser() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       setState(() {
//         userId = user.uid;
//       });
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   Future<void> _fetchDailyGoals() async {
//     if (userId == null) return;

//     // Clear previous goals while loading
//     setState(() {
//       dailyGoal = 0;
//       dailyProteinGoal = 0;
//     });

//     // First try to get goal for selected date
//     DocumentSnapshot dateGoalDoc = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .get();

//     if (dateGoalDoc.exists) {
//       _updateGoalsFromDoc(dateGoalDoc);
//       return;
//     }

//     // If no goal for selected date, find most recent goal
//     QuerySnapshot querySnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       final doc = querySnapshot.docs.first;
//       _updateGoalsFromDoc(doc);
//       final data = doc.data() as Map<String, dynamic>?;
//       if (data != null) {
//         await _saveCurrentDateGoal(data);
//       }
//     } else {
//       _askForDailyGoals();
//     }
//   }

//   void _updateGoalsFromDoc(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>?;
//     if (data == null) return;

//     setState(() {
//       dailyGoal = (data['finalDailyCalorieGoal'] as num?)?.toInt() ?? 0;
//       dailyProteinGoal = (data['dailyProteinIntake'] as num?)?.toInt() ?? 0;
//     });
//   }

//   Future<void> _saveCurrentDateGoal(Map<String, dynamic> data) async {
//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       ...data,
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> _askForDailyGoals() async {
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Set Your Daily Goals',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _goalController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: textLight),
//                 decoration: InputDecoration(
//                   labelText: 'Daily Calorie Goal',
//                   labelStyle: TextStyle(color: lightGreen),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen, width: 2),
//                   ),
//                 ),
//               ),
//               TextField(
//                 controller: _proteinGoalController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(color: textLight),
//                 decoration: InputDecoration(
//                   labelText: 'Daily Protein Goal (g)',
//                   labelStyle: TextStyle(color: lightGreen),
//                   enabledBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen),
//                   ),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: BorderSide(color: primaryGreen, width: 2),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: lightGreen)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryGreen,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 _updateDailyGoals();
//                 Navigator.pop(context);
//               },
//               child: Text('Save', style: GoogleFonts.poppins()),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _updateDailyGoals() async {
//     if (userId == null) return;

//     int calorieGoal = int.tryParse(_goalController.text) ?? dailyGoal;
//     int proteinGoal =
//         int.tryParse(_proteinGoalController.text) ?? dailyProteinGoal;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calorie_goal')
//         .doc(selectedDate)
//         .set({
//       'finalDailyCalorieGoal': calorieGoal.toDouble(),
//       'dailyProteinIntake': proteinGoal.toDouble(),
//       'date': selectedDate,
//       'timestamp': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     setState(() {
//       dailyGoal = calorieGoal;
//       dailyProteinGoal = proteinGoal;
//     });
//     _goalController.clear();
//     _proteinGoalController.clear();
//   }

//   Future<void> _fetchFoodEntries() async {
//     if (userId == null) return;
//     QuerySnapshot foodSnapshot = await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .where('date', isEqualTo: selectedDate)
//         .get();

//     setState(() {
//       foodEntries = foodSnapshot.docs
//           .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
//           .toList();
//     });
//   }

//   Future<void> _addOrEditFoodEntry({
//     String? docId,
//     required String food,
//     required int grams,
//     required int calories,
//     required double protein,
//     required double fat,
//     required double carbs,
//   }) async {
//     if (userId == null) return;

//     if (docId == null) {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .add({
//         'date': selectedDate,
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     } else {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .doc(docId)
//           .update({
//         'foodName': food,
//         'grams': grams,
//         'calories': calories,
//         'protein': protein,
//         'fat': fat,
//         'carbs': carbs,
//       });
//     }

//     _fetchFoodEntries();
//   }

//   void _editFoodEntry(Map<String, dynamic> food) {
//     // Set the initial grams value in the controller
//     _gramsController.text = food['grams'].toString();

//     // Calculate per-gram values for calories, protein, fat, and carbs
//     final int originalGrams = food['grams'] as int;
//     final int originalCalories = food['calories'] as int;
//     final double originalProtein = (food['protein'] as num).toDouble();
//     final double originalFat = (food['fat'] as num).toDouble();
//     final double originalCarbs = (food['carbs'] as num).toDouble();

//     // Avoid division by zero
//     if (originalGrams == 0) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Error',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Text(
//             'Cannot edit this entry because the original weight is 0 grams.',
//             style: TextStyle(color: textLight),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK', style: TextStyle(color: lightGreen)),
//             ),
//           ],
//         ),
//       );
//       return;
//     }

//     // Calculate per-gram values
//     final double caloriesPerGram = originalCalories / originalGrams;
//     final double proteinPerGram = originalProtein / originalGrams;
//     final double fatPerGram = originalFat / originalGrams;
//     final double carbsPerGram = originalCarbs / originalGrams;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Edit Food Entry',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Display food name (non-editable)
//                 Text(
//                   'Food Name: ${food['foodName']}',
//                   style: GoogleFonts.poppins(
//                     color: textLight,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Editable grams field
//                 TextField(
//                   controller: _gramsController,
//                   keyboardType: TextInputType.number,
//                   style: TextStyle(color: textLight),
//                   decoration: InputDecoration(
//                     labelText: 'Grams',
//                     labelStyle: TextStyle(color: lightGreen),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen),
//                     ),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: primaryGreen, width: 2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Cancel', style: TextStyle(color: lightGreen)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryGreen,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () {
//                 // Parse the new grams value
//                 final int newGrams =
//                     int.tryParse(_gramsController.text) ?? originalGrams;

//                 // Recalculate nutrients based on the new grams
//                 final int newCalories = (caloriesPerGram * newGrams).round();
//                 final double newProtein = proteinPerGram * newGrams;
//                 final double newFat = fatPerGram * newGrams;
//                 final double newCarbs = carbsPerGram * newGrams;

//                 // Update the food entry with the new values
//                 _addOrEditFoodEntry(
//                   docId: food['id'],
//                   food: food['foodName'],
//                   grams: newGrams,
//                   calories: newCalories,
//                   protein: newProtein,
//                   fat: newFat,
//                   carbs: newCarbs,
//                 );
//                 Navigator.pop(context);
//               },
//               child: Text('Save', style: GoogleFonts.poppins()),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deleteFoodEntry(String docId) async {
//     if (userId == null) return;

//     // Show confirmation dialog
//     bool confirm = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             backgroundColor: cardDark,
//             title: Text(
//               'Delete Entry',
//               style: GoogleFonts.poppins(
//                 color: textLight,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             content: Text(
//               'Are you sure you want to delete this food entry?',
//               style: TextStyle(color: textLight),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text('Cancel', style: TextStyle(color: lightGreen)),
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.redAccent,
//                   foregroundColor: Colors.white,
//                 ),
//                 onPressed: () => Navigator.pop(context, true),
//                 child: Text('Delete'),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (confirm) {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('calories')
//           .doc(docId)
//           .delete();
//       _fetchFoodEntries();
//     }
//   }

//   void _showAddFoodEntryDialog() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => FoodEntryScreen(
//           onFoodAdded: (
//             String food,
//             int grams,
//             int calories,
//             double protein,
//             double fat,
//             double carbs,
//           ) {
//             _addOrEditFoodEntry(
//               food: food,
//               grams: grams,
//               calories: calories,
//               protein: protein,
//               fat: fat,
//               carbs: carbs,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _addFoodEntry(
//     String food,
//     int grams,
//     int calories,
//     double protein,
//     double fat,
//     double carbs,
//   ) async {
//     if (userId == null) return;

//     await _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('calories')
//         .add({
//       'date': selectedDate,
//       'foodName': food,
//       'grams': grams,
//       'calories': calories,
//       'protein': protein,
//       'fat': fat,
//       'carbs': carbs,
//     });

//     _fetchFoodEntries();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.parse(selectedDate),
//       firstDate: DateTime(2024, 1, 1),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.dark(
//               primary: primaryGreen,
//               onPrimary: Colors.white,
//               surface: cardDark,
//               onSurface: textLight,
//             ),
//             dialogBackgroundColor: bgDark,
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = DateFormat('yyyy-MM-dd').format(picked);
//       });
//       await _fetchDailyGoals();
//       await _fetchFoodEntries();
//     }
//   }

//   void _showGoalOptions() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: cardDark,
//           title: Text(
//             'Set Daily Goals',
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Choose how you want to set your goals:',
//                 style: GoogleFonts.poppins(
//                   color: textLight,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _askForDailyGoals();
//                 },
//                 child: Text(
//                   'Enter Manually',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MaintenanceCalorieScreen(),
//                     ),
//                   ).then((_) async {
//                     await _fetchDailyGoals();
//                     await _fetchFoodEntries();
//                   });
//                 },
//                 child: Text(
//                   'Calculate Automatically',
//                   style: GoogleFonts.poppins(),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Circular progress indicator widget (from the first code)
//   Widget _buildCircularProgressIndicator({
//     required String label,
//     required double progress,
//     required String total,
//     required String goal,
//     required IconData icon,
//   }) {
//     Color progressColor;
//     if (progress >= 1) {
//       progressColor = Colors.redAccent;
//     } else if (progress >= 0.8) {
//       progressColor = Colors.orangeAccent;
//     } else {
//       progressColor = primaryGreen;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: lightGreen, size: 24),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: textLight,
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               SizedBox(
//                 height: 100,
//                 width: 100,
//                 child: CircularProgressIndicator(
//                   value: progress.clamp(0, 1),
//                   strokeWidth: 10,
//                   backgroundColor: Colors.grey.shade800,
//                   color: progressColor,
//                 ),
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     total,
//                     style: GoogleFonts.poppins(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                       color: textLight,
//                     ),
//                   ),
//                   Text(
//                     "/ $goal",
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey.shade400,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Nutrient card widget (from the first code)
//   Widget _buildNutrientCard({
//     required String label,
//     required String value,
//     required IconData icon,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: cardDark,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: lightGreen, size: 20),
//           const SizedBox(width: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.poppins(
//                   color: Colors.grey.shade400,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: GoogleFonts.poppins(
//                   color: textLight,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Calculate daily totals for each nutrient.
//     final totalCalories = foodEntries.fold(
//         0, (sum, item) => sum + (item['calories'] as num).toInt());
//     final totalProtein = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['protein'] as num).toDouble());
//     final totalFat = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['fat'] as num).toDouble());
//     final totalCarbs = foodEntries.fold(
//         0.0, (sum, item) => sum + (item['carbs'] as num).toDouble());

//     double progressCalories = dailyGoal > 0 ? totalCalories / dailyGoal : 0;
//     double progressProtein =
//         dailyProteinGoal > 0 ? totalProtein / dailyProteinGoal : 0;

//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
//           (Route<dynamic> route) => false,
//         );
//         return false;
//       },
//       child: Theme(
//         data: ThemeData.dark().copyWith(
//           scaffoldBackgroundColor: bgDark,
//           primaryColor: primaryGreen,
//           colorScheme: ColorScheme.dark(
//             primary: primaryGreen,
//             secondary: lightGreen,
//             surface: cardDark,
//             background: bgDark,
//           ),
//           appBarTheme: AppBarTheme(
//             backgroundColor: darkGreen,
//             elevation: 0,
//             centerTitle: true,
//             titleTextStyle: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           cardTheme: CardTheme(
//             color: cardDark,
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           floatingActionButtonTheme: FloatingActionButtonThemeData(
//             backgroundColor: primaryGreen,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//           ),
//           elevatedButtonTheme: ElevatedButtonThemeData(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: primaryGreen,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Text(
//               'NutriTrack',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.calendar_today),
//                 onPressed: () => _selectDate(context),
//                 tooltip: 'Select Date (History)',
//               ),
//             ],
//           ),
//           body: userId == null
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: primaryGreen,
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Date display
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 16),
//                           decoration: BoxDecoration(
//                             color: cardDark,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.calendar_today,
//                                   color: lightGreen, size: 18),
//                               const SizedBox(width: 8),
//                               Text(
//                                 DateFormat('EEEE, MMMM d')
//                                     .format(DateTime.parse(selectedDate)),
//                                 style: GoogleFonts.poppins(
//                                   color: textLight,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Progress indicators
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildCircularProgressIndicator(
//                                 label: 'Calories',
//                                 progress: progressCalories,
//                                 total: totalCalories.toString(),
//                                 goal: dailyGoal.toString(),
//                                 icon: Icons.local_fire_department,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildCircularProgressIndicator(
//                                 label: 'Protein',
//                                 progress: progressProtein,
//                                 total: totalProtein.toStringAsFixed(0),
//                                 goal: dailyProteinGoal.toString(),
//                                 icon: Icons.fitness_center,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Macronutrients row
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildNutrientCard(
//                                 label: 'Fat (g)',
//                                 value: totalFat.toStringAsFixed(0),
//                                 icon: Icons.opacity,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _buildNutrientCard(
//                                 label: 'Carbs (g)',
//                                 value: totalCarbs.toStringAsFixed(0),
//                                 icon: Icons.grain,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 24),

//                         // Goals button
//                         ElevatedButton.icon(
//                           onPressed: _showGoalOptions,
//                           icon: const Icon(Icons.edit),
//                           label: Text(
//                             'Edit Daily Goals',
//                             style: GoogleFonts.poppins(),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size(double.infinity, 48),
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Food entries section
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Today's Food",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: textLight,
//                               ),
//                             ),
//                             Text(
//                               '${foodEntries.length} items',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.grey.shade400,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),

//                         // Food entries list
//                         foodEntries.isEmpty
//                             ? Container(
//                                 padding: const EdgeInsets.all(24),
//                                 decoration: BoxDecoration(
//                                   color: cardDark,
//                                   borderRadius: BorderRadius.circular(12),
//                                   border:
//                                       Border.all(color: Colors.grey.shade800),
//                                 ),
//                                 child: Center(
//                                   child: Column(
//                                     children: [
//                                       Icon(
//                                         Icons.no_food,
//                                         size: 48,
//                                         color: Colors.grey.shade600,
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Text(
//                                         'No food entries yet',
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.grey.shade400,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Tap the + button to add your first meal',
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.grey.shade600,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             : ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount: foodEntries.length,
//                                 separatorBuilder: (context, index) =>
//                                     const SizedBox(height: 8),
//                                 itemBuilder: (context, index) {
//                                   final food = foodEntries[index];
//                                   return Card(
//                                     margin: EdgeInsets.zero,
//                                     child: ListTile(
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 8,
//                                       ),
//                                       leading: Container(
//                                         width: 48,
//                                         height: 48,
//                                         decoration: BoxDecoration(
//                                           color: lightGreen.withOpacity(0.2),
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         child: Icon(
//                                           Icons.restaurant,
//                                           color: lightGreen,
//                                         ),
//                                       ),
//                                       title: Text(
//                                         food['foodName'],
//                                         style: GoogleFonts.poppins(
//                                           fontWeight: FontWeight.w600,
//                                           color: textLight,
//                                         ),
//                                       ),
//                                       subtitle: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               Text(
//                                                 '${food['calories']} cal',
//                                                 style: GoogleFonts.poppins(
//                                                   color: primaryGreen,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 ' • ${food['grams']}g',
//                                                 style: TextStyle(
//                                                     color:
//                                                         Colors.grey.shade400),
//                                               ),
//                                             ],
//                                           ),
//                                           const SizedBox(height: 4),
//                                           Text(
//                                             'P: ${(food['protein'] as num).toDouble().toStringAsFixed(2)}g • F: ${(food['fat'] as num).toDouble().toStringAsFixed(2)}g • C: ${(food['carbs'] as num).toDouble().toStringAsFixed(2)}g',
//                                             style: TextStyle(
//                                               color: Colors.grey.shade500,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       trailing: Row(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           IconButton(
//                                             icon: Icon(
//                                               Icons.edit,
//                                               color: lightGreen,
//                                               size: 20,
//                                             ),
//                                             onPressed: () =>
//                                                 _editFoodEntry(food),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(
//                                               Icons.delete_outline,
//                                               color: Colors.redAccent,
//                                               size: 20,
//                                             ),
//                                             onPressed: () {
//                                               _deleteFoodEntry(food['id']);
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//           floatingActionButton: FloatingActionButton.extended(
//             onPressed: _showAddFoodEntryDialog,
//             tooltip: 'Add Food Entry',
//             icon: const Icon(Icons.add),
//             label: Text(
//               'Add Food',
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // App theme colors
  final Color primaryGreen = const Color(0xFF4CAF50);
  final Color darkGreen = const Color(0xFF2E7D32);
  final Color lightGreen = const Color(0xFFA5D6A7);
  final Color bgDark = const Color(0xFF121212);
  final Color cardDark = const Color(0xFF1E1E1E);
  final Color textLight = const Color(0xFFE0E0E0);

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

    setState(() {
      dailyGoal = 0;
      dailyProteinGoal = 0;
    });

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
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await _saveCurrentDateGoal(data);
      }
    } else {
      _askForDailyGoals();
    }
  }

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
          backgroundColor: cardDark,
          title: Text(
            'Set Your Daily Goals',
            style: GoogleFonts.poppins(
              color: textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Daily Calorie Goal',
                  labelStyle: TextStyle(color: lightGreen),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryGreen),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
              TextField(
                controller: _proteinGoalController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textLight),
                decoration: InputDecoration(
                  labelText: 'Daily Protein Goal (g)',
                  labelStyle: TextStyle(color: lightGreen),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryGreen),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryGreen, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: lightGreen)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _updateDailyGoals();
                Navigator.pop(context);
              },
              child: Text('Save', style: GoogleFonts.poppins()),
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
    try {
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
    } catch (e) {
      print("Error fetching food entries: $e");
      setState(() {
        foodEntries = [];
      });
    }
  }

  Future<void> _addOrEditFoodEntry({
    String? docId,
    required String food,
    required int grams,
    required int calories,
    required double protein,
    required double fat,
    required double carbs,
    String? image,
  }) async {
    if (userId == null) return;

    try {
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
          'image': image ?? '',
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
          'image': image ?? '',
        });
      }

      await _fetchFoodEntries();
    } catch (e) {
      print("Error adding/editing food entry: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save food entry',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _editFoodEntry(Map<String, dynamic> food) {
    _gramsController.text = food['grams'].toString();

    final int originalGrams = food['grams'] as int;
    final int originalCalories = food['calories'] as int;
    final double originalProtein = (food['protein'] as num).toDouble();
    final double originalFat = (food['fat'] as num).toDouble();
    final double originalCarbs = (food['carbs'] as num).toDouble();
    final String? existingImage = food['image'] as String?;

    if (originalGrams == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: cardDark,
          title: Text(
            'Error',
            style: GoogleFonts.poppins(
              color: textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Cannot edit this entry because the original weight is 0 grams.',
            style: TextStyle(color: textLight),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: lightGreen)),
            ),
          ],
        ),
      );
      return;
    }

    final double caloriesPerGram = originalCalories / originalGrams;
    final double proteinPerGram = originalProtein / originalGrams;
    final double fatPerGram = originalFat / originalGrams;
    final double carbsPerGram = originalCarbs / originalGrams;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardDark,
          title: Text(
            'Edit Food Entry',
            style: GoogleFonts.poppins(
              color: textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Name: ${food['foodName']}',
                  style: GoogleFonts.poppins(
                    color: textLight,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _gramsController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: textLight),
                  decoration: InputDecoration(
                    labelText: 'Grams',
                    labelStyle: TextStyle(color: lightGreen),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryGreen),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryGreen, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: lightGreen)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final int newGrams =
                    int.tryParse(_gramsController.text) ?? originalGrams;

                final int newCalories = (caloriesPerGram * newGrams).round();
                final double newProtein = proteinPerGram * newGrams;
                final double newFat = fatPerGram * newGrams;
                final double newCarbs = carbsPerGram * newGrams;

                _addOrEditFoodEntry(
                  docId: food['id'],
                  food: food['foodName'],
                  grams: newGrams,
                  calories: newCalories,
                  protein: newProtein,
                  fat: newFat,
                  carbs: newCarbs,
                  image: existingImage,
                );
                Navigator.pop(context);
              },
              child: Text('Save', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFoodEntry(String docId) async {
    if (userId == null) return;

    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardDark,
            title: Text(
              'Delete Entry',
              style: GoogleFonts.poppins(
                color: textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this food entry?',
              style: TextStyle(color: textLight),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: lightGreen)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('calories')
            .doc(docId)
            .delete();
        await _fetchFoodEntries();
      } catch (e) {
        print("Error deleting food entry: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete food entry',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
            String? image,
          ) {
            _addOrEditFoodEntry(
              food: food,
              grams: grams,
              calories: calories,
              protein: protein,
              fat: fat,
              carbs: carbs,
              image: image,
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: cardDark,
              onSurface: textLight,
            ),
            dialogBackgroundColor: bgDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      await _fetchDailyGoals();
      await _fetchFoodEntries();
    }
  }

  void _showGoalOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardDark,
          title: Text(
            'Set Daily Goals',
            style: GoogleFonts.poppins(
              color: textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose how you want to set your goals:',
                style: GoogleFonts.poppins(
                  color: textLight,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _askForDailyGoals();
                },
                child: Text(
                  'Enter Manually',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MaintenanceCalorieScreen(),
                    ),
                  ).then((_) async {
                    await _fetchDailyGoals();
                    await _fetchFoodEntries();
                  });
                },
                child: Text(
                  'Calculate Automatically',
                  style: GoogleFonts.poppins(),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
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
    required IconData icon,
  }) {
    Color progressColor;
    if (progress >= 1) {
      progressColor = Colors.redAccent;
    } else if (progress >= 0.8) {
      progressColor = Colors.orangeAccent;
    } else {
      progressColor = primaryGreen;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: lightGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: textLight,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade800,
                  color: progressColor,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    total,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: textLight,
                    ),
                  ),
                  Text(
                    "/ $goal",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: lightGreen, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ExerciseSelectionScreen()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Theme(
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
          cardTheme: CardTheme(
            color: cardDark,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'NutriTrack',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
                tooltip: 'Select Date (History)',
              ),
            ],
          ),
          body: userId == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: primaryGreen,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today,
                                  color: lightGreen, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(DateTime.parse(selectedDate)),
                                style: GoogleFonts.poppins(
                                  color: textLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCircularProgressIndicator(
                                label: 'Calories',
                                progress: progressCalories,
                                total: totalCalories.toString(),
                                goal: dailyGoal.toString(),
                                icon: Icons.local_fire_department,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCircularProgressIndicator(
                                label: 'Protein',
                                progress: progressProtein,
                                total: totalProtein.toStringAsFixed(0),
                                goal: dailyProteinGoal.toString(),
                                icon: Icons.fitness_center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNutrientCard(
                                label: 'Fat (g)',
                                value: totalFat.toStringAsFixed(0),
                                icon: Icons.opacity,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNutrientCard(
                                label: 'Carbs (g)',
                                value: totalCarbs.toStringAsFixed(0),
                                icon: Icons.grain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showGoalOptions,
                          icon: const Icon(Icons.edit),
                          label: Text(
                            'Edit Daily Goals',
                            style: GoogleFonts.poppins(),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Today's Food",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textLight,
                              ),
                            ),
                            Text(
                              '${foodEntries.length} items',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        foodEntries.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: cardDark,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade800),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.no_food,
                                        size: 48,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No food entries yet',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade400,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap the + button to add your first meal',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: foodEntries.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final food = foodEntries[index];
                                  final String? foodImage = food['image'] as String?;
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: lightGreen.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: foodImage != null && foodImage.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.memory(
                                                  base64Decode(foodImage),
                                                  fit: BoxFit.cover,
                                                  width: 48,
                                                  height: 48,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    print("Error loading image for ${food['foodName']}: $error");
                                                    return Icon(
                                                      Icons.restaurant,
                                                      color: lightGreen,
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.restaurant,
                                                color: lightGreen,
                                              ),
                                      ),
                                      title: Text(
                                        food['foodName'] ?? 'Unknown Food',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: textLight,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                '${food['calories'] ?? 0} cal',
                                                style: GoogleFonts.poppins(
                                                  color: primaryGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                ' • ${food['grams'] ?? 0}g',
                                                style: TextStyle(
                                                    color:
                                                        Colors.grey.shade400),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'P: ${(food['protein'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}g • F: ${(food['fat'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}g • C: ${(food['carbs'] as num?)?.toDouble().toStringAsFixed(2) ?? '0.00'}g',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: lightGreen,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _editFoodEntry(food),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              _deleteFoodEntry(food['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddFoodEntryDialog,
            tooltip: 'Add Food Entry',
            icon: const Icon(Icons.add),
            label: Text(
              'Add Food',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}