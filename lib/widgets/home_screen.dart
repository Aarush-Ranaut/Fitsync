//Basic WOkring UI
// import 'dart:convert';
// import 'dart:ui';
// import 'package:fitsync_app/auth/signin.dart';
// import 'package:fitsync_app/widgets/exercise_selection.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'edit_profile_screen.dart';
// import '../widgets/ai_integration.dart';

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

//   Future<void> _fetchUserData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           final fullName = userDoc['firstName'] ?? 'Guest';
//           setState(() {
//             _firstName = fullName.split(' ')[0];
//             _profilePictureBase64 = userDoc['profileImage'] ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching data: $e")),
//       );
//     }
//   }

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
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FloatingActionButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ExerciseSelectionScreen()),
//             ),
//             backgroundColor: Colors.green,
//             child: const Icon(Icons.camera_alt, color: Colors.black),
//           ),
//           const SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => const AIIntegration(
//                         apiKey: 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU',
//                       )),
//             ),
//             backgroundColor: Colors.green,
//             child: const Icon(Icons.smart_toy, color: Colors.black),
//           ),
//         ],
//       ),
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

import 'package:fitsync_app/widgets/exercise_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'edit_profile_screen.dart';
import '../widgets/ai_integration.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeScreen extends StatefulWidget {
  final String? username;
  final String? profilePictureUrl;

  const HomeScreen({super.key, this.username, this.profilePictureUrl});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final limeGreenColor = const Color(0xFF90FF42);

  static const List<NavigationItemData> _navigationItems = [
    NavigationItemData(iconPath: 'assets/images/home.png', label: 'Home'),
    NavigationItemData(iconPath: 'assets/images/camera.png', label: 'Camera'),
    NavigationItemData(iconPath: 'assets/images/watch.png', label: 'Watch'),
    NavigationItemData(iconPath: 'assets/images/profile.png', label: 'Profile'),
  ];

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"firstName": "Guest", "profileImage": ""};
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) return {"firstName": "Guest", "profileImage": ""};

    return {
      "firstName": userDoc['firstName'] ?? "Guest",
      "profileImage": userDoc['profileImage'] ?? "",
    };
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          // Home
          break;
        case 1:
          _navigateToCamera(context);
          break;
        case 2:
          // Watch
          break;
        case 3:
          _navigateToEditProfile(context);
          break;
      }
    });
  }

  void _navigateToEditProfile(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: userId),
      ),
    );
  }

  void _navigateToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseSelectionScreen(),
      ),
    );
  }

  void _navigateToAIIntegration(BuildContext context) {
    String apiKey = 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIIntegration(apiKey: apiKey),
      ),
    );
  }

  Widget _buildGaugeMeter() {
    return SizedBox(
      width: 80,
      height: 80,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 180,
            endAngle: 0,
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.12,
              thicknessUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.bothCurve,
              gradient: const SweepGradient(
                colors: [Colors.blue, Colors.green],
                stops: [0.25, 0.75],
              ),
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: 75,
                needleLength: 0.7,
                lengthUnit: GaugeSizeUnit.factor,
                needleColor: Colors.redAccent,
                needleEndWidth: 4,
                knobStyle: const KnobStyle(
                  color: Colors.white,
                  borderColor: Colors.redAccent,
                  borderWidth: 2,
                  sizeUnit: GaugeSizeUnit.factor,
                  knobRadius: 0.06,
                ),
                enableAnimation: true,
                animationType: AnimationType.ease,
                animationDuration: 1200,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: limeGreenColor.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            child: _buildGaugeMeter(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHealthInfo(Icons.favorite, 'BPM', '72'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: limeGreenColor.withOpacity(0.08),
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: limeGreenColor, size: 20),
        ),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  color: limeGreenColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorials() {
    List<Map<String, dynamic>> tutorials = [
      {
        "title": "BACK",
        "image": "assets/images/back_workout.png",
        "color": const Color(0xFFFFE5D9), // Light peach
      },
      {
        "title": "CHEST",
        "image": "assets/images/chest_workout.png",
        "color": const Color(0xFFFFFFB3), // Light yellow
      },
      {
        "title": "LEGS",
        "image": "assets/images/legs_workout.jpg",
        "color": const Color(0xFFCFFF95), // Light green
      },
      {
        "title": "ARMS",
        "image": "assets/images/arms_workout.jpg",
        "color": const Color(0xFFD0A9F5), // Light purple
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tutorials",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: tutorial["color"] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        tutorial["title"] as String,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          tutorial["image"] as String,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fetchUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF90FF42)),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Error loading data",
                          style: TextStyle(color: Colors.red, fontSize: 22),
                        ),
                      );
                    }

                    String firstName = snapshot.data?['firstName'] ?? "Guest";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          intl.DateFormat('MMM dd, yyyy')
                              .format(DateTime.now()),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              firstName,
                              style: TextStyle(
                                color: limeGreenColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: limeGreenColor,
                                  size: 24,
                                ),
                                onPressed: () {
                                  print('Notification button pressed');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildHealthCard(),
                        const SizedBox(height: 20),
                        _buildTutorials(),
                        const SizedBox(height: 80), // Reduce bottom padding
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar (Moved Further Down)
          Positioned(
            left: 0,
            right: 0,
            bottom: 10, // Adjusted for lower positioning
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.85),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_navigationItems.length, (index) {
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedIndex == index
                            ? limeGreenColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            _navigationItems[index].iconPath,
                            width: 24,
                            height: 24,
                            color: _selectedIndex == index
                                ? limeGreenColor
                                : Colors.white70,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _navigationItems[index].label,
                            style: TextStyle(
                              color: _selectedIndex == index
                                  ? limeGreenColor
                                  : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // AI Chat Button
          Positioned(
            right: 20,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: limeGreenColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _navigateToAIIntegration(context),
                backgroundColor: limeGreenColor,
                child: const Icon(Icons.chat, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItemData {
  final String iconPath;
  final String label;

  const NavigationItemData({required this.iconPath, required this.label});
}
