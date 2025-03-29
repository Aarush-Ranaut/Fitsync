// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../edit_profile_screen.dart';
// import '../home_screen.dart';

// class WeightPickerPage extends StatefulWidget {
//   const WeightPickerPage({super.key});

//   @override
//   _WeightPickerPageState createState() => _WeightPickerPageState();
// }

// class _WeightPickerPageState extends State<WeightPickerPage> {
//   double _selectedWeight = 70.0;
//   final TextEditingController _weightController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialWeight();
//   }

//   Future<void> _loadInitialWeight() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user?.uid != null) {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       if (userDoc.exists) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           _selectedWeight = (data['weight'] ?? 70.0).toDouble();
//           _weightController.text = _selectedWeight.toStringAsFixed(1);
//         });
//       }
//     }
//   }

//   Future<void> _syncWeightData() async {
//     if (!_formKey.currentState!.validate()) return;

//     final User? user = FirebaseAuth.instance.currentUser;
//     final uid = user?.uid;

//     if (uid != null) {
//       try {
//         final double weight = double.parse(_weightController.text);
//         await FirebaseFirestore.instance.collection('users').doc(uid).update({
//           'weight': weight,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Weight saved successfully!")),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HomeScreen()),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error saving weight: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Enter Your Weight (kg)",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextFormField(
//                     controller: _weightController,
//                     keyboardType:
//                         TextInputType.numberWithOptions(decimal: true),
//                     inputFormatters: [DecimalTextInputFormatter()],
//                     style: const TextStyle(
//                         fontSize: 32,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide:
//                             const BorderSide(color: Colors.green, width: 2),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide:
//                             const BorderSide(color: Colors.green, width: 2),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide:
//                             const BorderSide(color: Colors.green, width: 3),
//                       ),
//                       contentPadding: const EdgeInsets.all(20),
//                       suffix: const Text(
//                         'kg',
//                         style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your weight';
//                       }
//                       final parsed = double.tryParse(value);
//                       if (parsed == null) {
//                         return 'Invalid weight format';
//                       }
//                       if (parsed < 30 || parsed > 300) {
//                         return 'Weight must be between 30 and 300 kg';
//                       }
//                       return null;
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildAdjustButton(Icons.remove, () => _adjustWeight(-0.1)),
//                     const SizedBox(width: 20),
//                     _buildAdjustButton(Icons.add, () => _adjustWeight(0.1)),
//                   ],
//                 ),
//                 const SizedBox(height: 40),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _syncWeightData,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: const Text(
//                       "SAVE WEIGHT",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
//     return CircleAvatar(
//       radius: 28,
//       backgroundColor: Colors.green,
//       child: IconButton(
//         icon: Icon(icon, size: 28, color: Colors.black),
//         onPressed: onPressed,
//       ),
//     );
//   }

//   void _adjustWeight(double delta) {
//     final current = double.tryParse(_weightController.text) ?? _selectedWeight;
//     final newValue = (current + delta).clamp(30.0, 300.0);
//     setState(() {
//       _selectedWeight = newValue;
//       _weightController.text = newValue.toStringAsFixed(1);
//     });
//   }
// }

// class DecimalTextInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final RegExp regExp = RegExp(r'^\d*\.?\d{0,1}$');
//     if (regExp.hasMatch(newValue.text)) {
//       return newValue;
//     }
//     return oldValue;
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../edit_profile_screen.dart';
import '../home_screen.dart';

class WeightPickerPage extends StatefulWidget {
  const WeightPickerPage({super.key});

  @override
  _WeightPickerPageState createState() => _WeightPickerPageState();
}

class _WeightPickerPageState extends State<WeightPickerPage> {
  int _selectedKg = 70; // Default to 70 kg
  int _selectedGrams = 0; // Default to 0 grams (0.0)
  double _selectedWeight = 70.0; // Combined weight for display and saving

  @override
  void initState() {
    super.initState();
    _loadInitialWeight();
  }

  Future<void> _loadInitialWeight() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final double weight = (data['weight'] ?? 70.0).toDouble();
        setState(() {
          _selectedKg = weight.floor(); // Extract the whole number (kg)
          _selectedGrams = ((weight - _selectedKg) * 10)
              .round(); // Extract the decimal part (grams)
          _selectedWeight = weight; // Keep the combined weight
        });
      }
    }
  }

  Future<void> _syncWeightData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        // Combine kg and grams into a single double value
        final double weight = _selectedKg + (_selectedGrams / 10.0);
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'weight': weight,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Weight saved successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving weight: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the combined weight for display
    _selectedWeight = _selectedKg + (_selectedGrams / 10.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Select Your Weight",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Display the combined weight
              Text(
                '${_selectedWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              // Row for kg and grams pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kilograms Picker
                  Container(
                    width: 100,
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedKg = 30 + index; // Range: 30 to 300
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final kg = 30 + index;
                          return Center(
                            child: Text(
                              '$kg',
                              style: TextStyle(
                                fontSize: 32,
                                color: kg == _selectedKg
                                    ? Colors.green
                                    : Colors.white70,
                                fontWeight: kg == _selectedKg
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        childCount: 271, // 30 to 300 inclusive (300 - 30 + 1)
                      ),
                      controller: FixedExtentScrollController(
                        initialItem:
                            _selectedKg - 30, // Adjust for the offset (30)
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '.',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Grams Picker (0 to 9)
                  Container(
                    width: 60,
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 50,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedGrams = index; // Range: 0 to 9
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              '$index',
                              style: TextStyle(
                                fontSize: 32,
                                color: index == _selectedGrams
                                    ? Colors.green
                                    : Colors.white70,
                                fontWeight: index == _selectedGrams
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                        childCount: 10, // 0 to 9
                      ),
                      controller: FixedExtentScrollController(
                        initialItem: _selectedGrams,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _syncWeightData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "SAVE WEIGHT",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
