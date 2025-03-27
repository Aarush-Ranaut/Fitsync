// // home_screen.dart
// import 'dart:convert';
// import 'dart:ui';
// import 'package:fitsync_app/auth/signin.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'edit_profile_screen.dart';
// import '../widgets/Camera_integrate.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? _profilePictureBase64;
//   String _firstName = "";

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

// Future<void> _fetchUserData() async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       if (userDoc.exists) {
//         final fullName = userDoc['firstName'] ?? 'Guest';
//         setState(() {
//           _firstName = fullName.split(' ')[0];
//           _profilePictureBase64 = userDoc['profileImage'] ?? '';
//         });
//       }
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error fetching data: $e")),
//     );
//   }
// }

//   void _logout(BuildContext context) {
//     FirebaseAuth.instance.signOut();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => SigninScreen()),
//       (route) => false,
//     );
//   }

//   void _navigateToEditProfile(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProfileScreen(userId: userId),
//       ),
//     );
//   }

//   void _showProfilePopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//           child: Dialog(
//             backgroundColor: Colors.transparent,
//             insetPadding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ClipOval(
//                   child: _profilePictureBase64 != null &&
//                           _profilePictureBase64!.isNotEmpty
//                       ? Image.memory(
//                           base64Decode(_profilePictureBase64!),
//                           width: 150,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         )
//                       : Image.asset(
//                           'assets/icons/ic_default_avatar.jpg',
//                           width: 150,
//                           height: 150,
//                           fit: BoxFit.cover,
//                         ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _firstName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.green,
//         unselectedItemColor: Colors.white,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
//         ],
//       ),
// floatingActionButton: FloatingActionButton(
//   onPressed: () => Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => const PostureCameraScreen()),
//   ),
//   backgroundColor: Colors.green,
//   child: const Icon(Icons.camera_alt, color: Colors.black),
// ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () => _logout(context),
//                     icon: const Icon(Icons.logout, color: Colors.white),
//                   ),
//                   GestureDetector(
//                     onTap: () => _showProfilePopup(context),
//                     child: CircleAvatar(
//                       radius: 24,
//                       backgroundImage: _profilePictureBase64 != null &&
//                               _profilePictureBase64!.isNotEmpty
//                           ? MemoryImage(base64Decode(_profilePictureBase64!))
//                           : const AssetImage(
//                                   'assets/icons/ic_default_avatar.jpg')
//                               as ImageProvider,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => _navigateToEditProfile(context),
//                     icon: const Icon(Icons.edit, color: Colors.white),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Jan 22, 2025',
//                 style: TextStyle(color: Colors.white, fontSize: 14),
//               ),
//               Text(
//                 _firstName,
//                 style: const TextStyle(
//                     color: Colors.green,
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:fitsync_app/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '../widgets/ai_integration.dart';
import 'workout_plan_home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profilePictureBase64;
  String _firstName = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final fullName = userDoc['firstName'] ?? 'Guest';
          setState(() {
            _firstName = fullName.split(' ')[0];
            _profilePictureBase64 = userDoc['profileImage'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
      (route) => false,
    );
  }

  void _navigateToEditProfile() {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(userId: userId)),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Different Screens based on Selected Index
  Widget _getBody() {
    switch (_selectedIndex) {
      case 2:
        return WorkoutPlanHomePage(); // Show Workout Plans
      default:
        return _buildHomeContent(); // Default Home Screen
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & User Name
          Text('Jan 22, 2025', style: TextStyle(color: Colors.white, fontSize: 14)),
          Text(_firstName, style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          // Stats Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard("Heart Rate", "69 BPM"),
              _buildStatCard("Calories", "320 kcal"),
            ],
          ),
          SizedBox(height: 30),

          // Tutorials
          Text('Tutorials', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          _buildTutorialsSection(),

          Spacer(),

          // AI Button
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AIIntegration(
                            apiKey: 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU',
                          )),
                );
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.smart_toy, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: 'Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _navigateToEditProfile,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: _profilePictureBase64 != null &&
                              _profilePictureBase64!.isNotEmpty
                          ? MemoryImage(base64Decode(_profilePictureBase64!))
                          : AssetImage('assets/icons/ic_default_avatar.jpg') as ImageProvider,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _getBody()), // Display Body Dynamically
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTutorialCard('BACK', 'assets/back_workout.jpg'),
        _buildTutorialCard('CHEST', 'assets/chest_workout.jpg'),
        Expanded(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialCard(String title, String imagePath) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black.withOpacity(0.6),
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

