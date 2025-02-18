import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart';

class WeightPickerPage extends StatefulWidget {
  const WeightPickerPage({super.key});

  @override
  _WeightPickerPageState createState() => _WeightPickerPageState();
}

class _WeightPickerPageState extends State<WeightPickerPage> {
  int _selectedWeight = 70; // Default weight

  Future<void> _syncWeightData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        // If the user document exists, check for weight and sync
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data['weight'] != null) {
            // Sync if data exists
            _selectedWeight = data['weight'];
          }
        }

        // Now, save or update the weight in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'weight': _selectedWeight,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Weight saved successfully!")),
        );

        // Fetch user's first name and profile picture URL for redirection
        String firstName = '';
        String profilePictureUrl = '';
        final userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;
          firstName = userData['firstName'] ?? 'User';
          profilePictureUrl =
              userData['profileImage'] ?? ''; // Handle default image or empty
        }

        // Redirect to HomeScreen with the fetched user data
       Navigator.pushReplacement(
        context,
          MaterialPageRoute(
           builder: (context) => HomeScreen(
            username: firstName,
           profilePictureUrl: profilePictureUrl,
            ),
           ),
          );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error syncing weight data: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Your Weight",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 150,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 60,
                    perspective: 0.005,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        _selectedWeight = 50 + index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        return RotatedBox(
                          quarterTurns: -3,
                          child: Center(
                            child: Text(
                              '${50 + index}',
                              style: TextStyle(
                                fontSize: 24,
                                color: _selectedWeight == 50 + index
                                    ? Colors.green
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: 131, // Ranges from 50 to 180
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _syncWeightData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save",
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
