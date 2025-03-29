// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'weight_picker_page.dart';

// class HeightPickerPage extends StatefulWidget {
//   const HeightPickerPage({super.key});

//   @override
//   _HeightPickerPageState createState() => _HeightPickerPageState();
// }

// class _HeightPickerPageState extends State<HeightPickerPage> {
//   int _selectedHeight = 170; // Default height

//   Future<void> _syncHeightData() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final uid = user?.uid;

//     if (uid != null) {
//       try {
//         final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

//         // If the user document exists, check for height and sync
//         if (userDoc.exists) {
//           final data = userDoc.data() as Map<String, dynamic>;
//           if (data['height'] != null) {
//             // Sync if data exists
//             _selectedHeight = data['height'];
//           }
//         }

//         // Now, save or update the height in Firestore
//         await FirebaseFirestore.instance.collection('users').doc(uid).update({
//           'height': _selectedHeight,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Height saved successfully!")),
//         );

//         // Navigate to the next page (WeightPickerPage)
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => WeightPickerPage()),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error syncing height data: $e")),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("User not logged in.")),
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
//                 "Enter Your Height",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 height: 200,
//                 child: ListWheelScrollView.useDelegate(
//                   itemExtent: 50,
//                   perspective: 0.005,
//                   physics: const FixedExtentScrollPhysics(),
//                   onSelectedItemChanged: (index) {
//                     setState(() {
//                       _selectedHeight = 150 + index;
//                     });
//                   },
//                   childDelegate: ListWheelChildBuilderDelegate(
//                     builder: (context, index) {
//                       return Center(
//                         child: Text(
//                           '${150 + index}',
//                           style: TextStyle(
//                             fontSize: 24,
//                             color: _selectedHeight == 150 + index
//                                 ? Colors.green
//                                 : Colors.white,
//                           ),
//                         ),
//                       );
//                     },
//                     childCount: 100, // Ranges from 150 to 249
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _syncHeightData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     "Next",
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
import 'weight_picker_page.dart';

class HeightPickerPage extends StatefulWidget {
  final bool isFromEditProfile; // New parameter to determine navigation flow

  const HeightPickerPage({super.key, this.isFromEditProfile = false});

  @override
  _HeightPickerPageState createState() => _HeightPickerPageState();
}

class _HeightPickerPageState extends State<HeightPickerPage> {
  int _selectedHeight = 170; // Default height

  @override
  void initState() {
    super.initState();
    _loadInitialHeight();
  }

  Future<void> _loadInitialHeight() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user?.uid != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _selectedHeight = (data['height'] ?? 170).toInt();
        });
      }
    }
  }

  Future<void> _syncHeightData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      try {
        // Save or update the height in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'height': _selectedHeight,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Height saved successfully!")),
        );

        // Determine navigation based on isFromEditProfile
        if (widget.isFromEditProfile) {
          // Return the selected height to EditProfileScreen
          Navigator.pop(context, _selectedHeight);
        } else {
          // Navigate to WeightPickerPage for first-time user flow
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WeightPickerPage(isFromEditProfile: false),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error syncing height data: $e")),
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
                "Enter Your Height",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  perspective: 0.005,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHeight = 150 + index;
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          '${150 + index}',
                          style: TextStyle(
                            fontSize: 24,
                            color: _selectedHeight == 150 + index
                                ? Colors.green
                                : Colors.white,
                          ),
                        ),
                      );
                    },
                    childCount: 100, // Ranges from 150 to 249
                  ),
                  controller: FixedExtentScrollController(
                    initialItem:
                        _selectedHeight - 150, // Adjust for the offset (150)
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _syncHeightData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.isFromEditProfile ? "Save" : "Next",
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
