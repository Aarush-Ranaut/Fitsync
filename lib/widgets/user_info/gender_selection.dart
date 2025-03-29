// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'height_picker_page.dart';

// class GenderSelectionScreen extends StatefulWidget {
//   const GenderSelectionScreen({super.key});

//   @override
//   _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
// }

// class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
//   String? selectedGender;

//   // Save selected gender to Firestore
//   Future<void> _saveGender() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final uid = user?.uid;

//     if (uid == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not logged in")),
//       );
//       return;
//     }

//     if (selectedGender != null) {
//       try {
//         await FirebaseFirestore.instance.collection('users').doc(uid).update({
//           'gender': selectedGender,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Gender saved successfully!")),
//         );

//         // Navigate to the height selection screen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => HeightPickerPage()),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error saving gender: $e")),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a gender.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 "Select Your Gender",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedGender = "Male";
//                       });
//                     },
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: selectedGender == "Male"
//                               ? Colors.green
//                               : Colors.grey[800],
//                           child: const Icon(
//                             Icons.male,
//                             size: 50,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           "Male",
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedGender = "Female";
//                       });
//                     },
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 50,
//                           backgroundColor: selectedGender == "Female"
//                               ? Colors.green
//                               : Colors.grey[800],
//                           child: const Icon(
//                             Icons.female,
//                             size: 50,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                           "Female",
//                           style: TextStyle(
//                             fontSize: 18,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveGender,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Continue",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'height_picker_page.dart';

class GenderSelectionScreen extends StatefulWidget {
  final bool isFromEditProfile; // New parameter to determine navigation flow

  const GenderSelectionScreen({super.key, this.isFromEditProfile = false});

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadInitialGender();
  }

  Future<void> _loadInitialGender() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          selectedGender = data['gender'];
        });
      }
    }
  }

  Future<void> _saveGender() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (selectedGender != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'gender': selectedGender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gender saved successfully!")),
        );

        // Determine navigation based on isFromEditProfile
        if (widget.isFromEditProfile) {
          // Return the selected gender to EditProfileScreen
          Navigator.pop(context, selectedGender);
        } else {
          // Navigate to HeightPickerPage for first-time user flow
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HeightPickerPage(isFromEditProfile: false),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving gender: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender.")),
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
                "Select Your Gender",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = "Male";
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: selectedGender == "Male"
                              ? Colors.green
                              : Colors.grey[800],
                          child: const Icon(
                            Icons.male,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Male",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = "Female";
                      });
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: selectedGender == "Female"
                              ? Colors.green
                              : Colors.grey[800],
                          child: const Icon(
                            Icons.female,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Female",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveGender,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.isFromEditProfile ? "Save" : "Continue",
                    style: const TextStyle(
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
