import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double _selectedWeight = 70.0;
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
        setState(() {
          _selectedWeight = (data['weight'] ?? 70.0).toDouble();
          _weightController.text = _selectedWeight.toStringAsFixed(1);
        });
      }
    }
  }

  Future<void> _syncWeightData() async {
    if (!_formKey.currentState!.validate()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        final double weight = double.parse(_weightController.text);
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Enter Your Weight (kg)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalTextInputFormatter()],
                    style: const TextStyle(
                        fontSize: 32,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 3),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      suffix: const Text(
                        'kg',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Invalid weight format';
                      }
                      if (parsed < 30 || parsed > 300) {
                        return 'Weight must be between 30 and 300 kg';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAdjustButton(Icons.remove, () => _adjustWeight(-0.1)),
                    const SizedBox(width: 20),
                    _buildAdjustButton(Icons.add, () => _adjustWeight(0.1)),
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
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.green,
      child: IconButton(
        icon: Icon(icon, size: 28, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  void _adjustWeight(double delta) {
    final current = double.tryParse(_weightController.text) ?? _selectedWeight;
    final newValue = (current + delta).clamp(30.0, 300.0);
    setState(() {
      _selectedWeight = newValue;
      _weightController.text = newValue.toStringAsFixed(1);
    });
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final RegExp regExp = RegExp(r'^\d*\.?\d{0,1}$');
    if (regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
