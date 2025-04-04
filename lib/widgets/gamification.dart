// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:convert'; // For base64 decoding
// import 'edit_profile_screen.dart';

// class GamificationScreen extends StatefulWidget {
//   const GamificationScreen({Key? key}) : super(key: key);

//   @override
//   _GamificationScreenState createState() => _GamificationScreenState();
// }

// class _GamificationScreenState extends State<GamificationScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? userId;
//   String firstName = 'User'; // Default value
//   String? profilePicture; // For base64 encoded profile picture
//   int experience = 0;
//   int level = 1;
//   int totalPoints = 0;
//   int streak = 0;
//   List<String> achievements = []; // List of achieved milestones
//   final List<String> milestoneLabels = [
//     '1 Day',
//     '1 Week',
//     '10 Days',
//     '20 Days',
//     '1 Month',
//     '2 Months',
//     '3 Months',
//     '6 Months',
//     '1 Year'
//   ];

//   @override
//   void initState() {
//     super.initState();
//     userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId != null) {
//       _fetchUserData();
//       _fetchGamificationData();
//     }
//   }

//   // Fetch user data (firstName and profileImage)
//   Future<void> _fetchUserData() async {
//     try {
//       final DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(userId).get();

//       if (userDoc.exists) {
//         final data = userDoc.data() as Map<String, dynamic>;
//         setState(() {
//           firstName = data['firstName'] ?? 'User';
//           profilePicture = data['profileImage'];
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching user data: $e")),
//       );
//     }
//   }

//   // Fetch gamification data (experience, level, totalPoints, streak, achievements)
//   Future<void> _fetchGamificationData() async {
//     try {
//       final DocumentSnapshot gamificationDoc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('gamification')
//           .doc('data')
//           .get();

//       if (gamificationDoc.exists) {
//         final data = gamificationDoc.data() as Map<String, dynamic>;
//         setState(() {
//           experience = data['experience'] ?? 0;
//           level = data['level'] ?? 1;
//           totalPoints = data['totalPoints'] ?? 0;
//           streak = data['streak'] ?? 0;
//           achievements = List<String>.from(data['achievements'] ?? []);
//         });
//       } else {
//         // If no gamification data exists, initialize it
//         await _initializeGamificationData();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error fetching gamification data: $e")),
//       );
//     }
//   }

//   // Initialize gamification data if it doesn't exist
//   Future<void> _initializeGamificationData() async {
//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('gamification')
//           .doc('data')
//           .set({
//         'experience': 0,
//         'level': 1,
//         'totalPoints': 0,
//         'streak': 0,
//         'achievements': [],
//         'lastCheckIn': null, // To track the last streak check-in
//       });
//       setState(() {
//         experience = 0;
//         level = 1;
//         totalPoints = 0;
//         streak = 0;
//         achievements = [];
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error initializing gamification data: $e")),
//       );
//     }
//   }

//   // Handle streak check-in
//   Future<void> _checkStreak() async {
//     try {
//       final DocumentReference gamificationRef = _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('gamification')
//           .doc('data');

//       final DocumentSnapshot gamificationDoc = await gamificationRef.get();
//       final data = gamificationDoc.data() as Map<String, dynamic>?;
//       final DateTime now = DateTime.now();
//       DateTime? lastCheckIn;

//       if (data != null && data['lastCheckIn'] != null) {
//         lastCheckIn = DateTime.parse(data['lastCheckIn']);
//       }

//       int newStreak = streak;
//       List<String> newAchievements = List.from(achievements);

//       if (lastCheckIn == null) {
//         // First check-in
//         newStreak = 1;
//       } else {
//         final difference = now.difference(lastCheckIn).inDays;
//         if (difference == 1) {
//           // Consecutive day
//           newStreak = streak + 1;
//         } else if (difference > 1) {
//           // Missed a day, reset streak
//           newStreak = 1;
//         } else {
//           // Same day, no change
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("You already checked in today!")),
//           );
//           return;
//         }
//       }

//       // Update achievements based on streak
//       if (newStreak >= 1 && !newAchievements.contains('1 Day')) {
//         newAchievements.add('1 Day');
//       }
//       if (newStreak >= 7 && !newAchievements.contains('1 Week')) {
//         newAchievements.add('1 Week');
//       }
//       if (newStreak >= 10 && !newAchievements.contains('10 Days')) {
//         newAchievements.add('10 Days');
//       }
//       if (newStreak >= 20 && !newAchievements.contains('20 Days')) {
//         newAchievements.add('20 Days');
//       }
//       if (newStreak >= 30 && !newAchievements.contains('1 Month')) {
//         newAchievements.add('1 Month');
//       }
//       if (newStreak >= 60 && !newAchievements.contains('2 Months')) {
//         newAchievements.add('2 Months');
//       }
//       if (newStreak >= 90 && !newAchievements.contains('3 Months')) {
//         newAchievements.add('3 Months');
//       }
//       if (newStreak >= 180 && !newAchievements.contains('6 Months')) {
//         newAchievements.add('6 Months');
//       }
//       if (newStreak >= 365 && !newAchievements.contains('1 Year')) {
//         newAchievements.add('1 Year');
//       }

//       // Update experience and total points
//       int newExperience = experience + 10; // Add 10 XP per check-in
//       int newLevel = (newExperience ~/ 1000) + 1; // Level up every 1000 XP
//       int newTotalPoints = totalPoints + 10; // Add 10 points per check-in

//       // Update Firestore
//       await gamificationRef.update({
//         'streak': newStreak,
//         'achievements': newAchievements,
//         'lastCheckIn': now.toIso8601String(),
//         'experience': newExperience,
//         'level': newLevel,
//         'totalPoints': newTotalPoints,
//       });

//       setState(() {
//         streak = newStreak;
//         achievements = newAchievements;
//         experience = newExperience;
//         level = newLevel;
//         totalPoints = newTotalPoints;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Streak updated!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error updating streak: $e")),
//       );
//     }
//   }

//   // Navigation function for Edit Profile
//   void _navigateToEditProfile(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => EditProfileScreen(userId: userId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A3B1C), // Dark green background
//       body: SafeArea(
//         child: Column(
//           children: [
//             // App bar with title
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Profile & Achievements',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//             Expanded(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                   child: Column(
//                     children: [
//                       // Profile Card
//                       Container(
//                         margin: const EdgeInsets.symmetric(vertical: 12.0),
//                         padding: const EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 // Profile avatar with glowing border
//                                 Container(
//                                   width: 60,
//                                   height: 60,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.grey.shade700,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.green.withOpacity(0.8),
//                                         blurRadius: 8,
//                                         spreadRadius: 1,
//                                       ),
//                                     ],
//                                     border: Border.all(
//                                       color: Colors.green,
//                                       width: 2,
//                                     ),
//                                   ),
//                                   child: profilePicture != null &&
//                                           profilePicture!.isNotEmpty
//                                       ? ClipOval(
//                                           child: Image.memory(
//                                             base64Decode(profilePicture!),
//                                             fit: BoxFit.cover,
//                                             width: 60,
//                                             height: 60,
//                                           ),
//                                         )
//                                       : const Icon(
//                                           Icons.person,
//                                           color: Colors.white,
//                                           size: 40,
//                                         ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       firstName,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Colors.transparent,
//                                         borderRadius: BorderRadius.circular(16),
//                                         border: Border.all(
//                                           color: Colors.green,
//                                           width: 2,
//                                         ),
//                                       ),
//                                       child: Text(
//                                         'Level $level',
//                                         style: TextStyle(
//                                           color: Colors.green,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 IconButton(
//                                   icon: const Icon(
//                                     Icons.edit,
//                                     color: Colors.white,
//                                   ),
//                                   onPressed: () =>
//                                       _navigateToEditProfile(context),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Text(
//                               'Total Points: $totalPoints',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Experience',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   '$experience/1000',
//                                   style: TextStyle(
//                                     color: Colors.green,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 6),
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: LinearProgressIndicator(
//                                 value: experience / 1000,
//                                 minHeight: 8,
//                                 backgroundColor: Colors.grey.shade700,
//                                 valueColor: const AlwaysStoppedAnimation<Color>(
//                                     Colors.green),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Achievements Card
//                       Container(
//                         margin: const EdgeInsets.symmetric(vertical: 12.0),
//                         padding: const EdgeInsets.all(16.0),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: const Icon(
//                                     Icons.emoji_events,
//                                     color: Colors.green,
//                                     size: 28,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   'Achievements',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 16),

//                             // Streak container
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade900,
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(6),
//                                     decoration: BoxDecoration(
//                                       color: Colors.orange.withOpacity(0.2),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     child: const Icon(
//                                       Icons.local_fire_department,
//                                       color: Colors.orange,
//                                       size: 24,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     'Streak: $streak days',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const Spacer(),
//                                   ElevatedButton(
//                                     onPressed: _checkStreak,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.green,
//                                       foregroundColor: Colors.black,
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 20,
//                                         vertical: 10,
//                                       ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'Check',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             const SizedBox(height: 16),

//                             // Achievement milestones grid
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: milestoneLabels.map((label) {
//                                 return _buildAchievementChip(
//                                     label, achievements.contains(label));
//                               }).toList(),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Go to Workout Button
//                       Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.symmetric(vertical: 12.0),
//                         child: ElevatedButton.icon(
//                           icon: const Icon(
//                             Icons.fitness_center,
//                             color: Colors.black,
//                             size: 20,
//                           ),
//                           label: Text(
//                             'Go to Workout',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAchievementChip(String text, bool achieved) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: achieved ? Colors.green.withOpacity(0.2) : Colors.grey.shade800,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 16,
//             height: 16,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: achieved ? Colors.green : Colors.grey.shade500,
//                 width: 2,
//               ),
//               color: achieved ? Colors.green : Colors.transparent,
//             ),
//             child: achieved
//                 ? const Icon(
//                     Icons.check,
//                     size: 12,
//                     color: Colors.black,
//                   )
//                 : null,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'edit_profile_screen.dart';
import 'marketplace_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/session_tracker.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({Key? key}) : super(key: key);

  @override
  _GamificationScreenState createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  String firstName = 'User';
  String? profilePicture;
  int experience = 0;
  int level = 1;
  int totalPoints = 0;
  int streak = 0;
  List<String> achievements = [];
  Timestamp? lastCheckIn;
  List<double> dailyTimeSpent = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  List<String> dayLabels = [];

  final Map<String, IconData> milestoneTrophies = {
    '1 Day': Icons.emoji_events,
    '1 Week': Icons.local_activity,
    '10 Days': Icons.star,
    '20 Days': Icons.military_tech,
    '1 Month': Icons.workspace_premium,
    '2 Months': Icons.verified,
    '3 Months': Icons.favorite,
    '6 Months': Icons.diamond,
    '1 Year': Icons.crop,
  };

  final List<String> milestoneLabels = [
    '1 Day',
    '1 Week',
    '10 Days',
    '20 Days',
    '1 Month',
    '2 Months',
    '3 Months',
    '6 Months',
    '1 Year'
  ];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _fetchUserData();
      _fetchGamificationData();
    }
    _generateDayLabels();
  }

  void _generateDayLabels() {
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // 0 (Mon) to 6 (Sun)
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> labels = [];
    for (int i = 0; i < 7; i++) {
      int dayIndex = (currentDayIndex - 6 + i) % 7;
      if (dayIndex < 0) dayIndex += 7;
      labels.add(days[dayIndex]);
    }
    setState(() {
      dayLabels = labels;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          firstName = data['firstName'] ?? 'User';
          profilePicture = data['profileImage'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> _fetchGamificationData() async {
    try {
      final DocumentSnapshot gamificationDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification')
          .doc('data')
          .get();

      if (gamificationDoc.exists) {
        final data = gamificationDoc.data() as Map<String, dynamic>;
        setState(() {
          experience = data['experience'] ?? 0;
          level = data['level'] ?? 1;
          totalPoints = data['totalPoints'] ?? 0;
          streak = data['streak'] ?? 0;
          achievements = List<String>.from(data['achievements'] ?? []);

          final lastCheckInValue = data['lastCheckIn'];
          if (lastCheckInValue is Timestamp) {
            lastCheckIn = lastCheckInValue;
          } else if (lastCheckInValue is String) {
            try {
              lastCheckIn =
                  Timestamp.fromDate(DateTime.parse(lastCheckInValue));
            } catch (e) {
              lastCheckIn = null; // Fallback if parsing fails
            }
          } else {
            lastCheckIn = null;
          }
        });
        _checkStreakStatus();
      } else {
        await _initializeGamificationData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching gamification data: $e")),
      );
    }
  }

  Future<void> _initializeGamificationData() async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification')
          .doc('data')
          .set({
        'experience': 0,
        'level': 1,
        'totalPoints': 0,
        'streak': 0,
        'achievements': [],
        'lastCheckIn': null,
      });
      setState(() {
        experience = 0;
        level = 1;
        totalPoints = 0;
        streak = 0;
        achievements = [];
        lastCheckIn = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing gamification data: $e")),
      );
    }
  }

  void _checkStreakStatus() {
    if (lastCheckIn == null) return;

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime lastCheckInDate = lastCheckIn!.toDate();
    DateTime lastCheckInDay = DateTime(
        lastCheckInDate.year, lastCheckInDate.month, lastCheckInDate.day);

    int daysDifference = today.difference(lastCheckInDay).inDays;
    if (daysDifference > 1) {
      setState(() {
        streak = 0;
        achievements.clear();
      });
      _firestore
          .collection('users')
          .doc(userId)
          .collection('gamification')
          .doc('data')
          .update({
        'streak': 0,
        'achievements': [],
      });
    }
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

  void _navigateToMarketplace(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketplaceScreen(experience: experience),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3B1C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile & Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () => _navigateToEditProfile(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade700,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          child: profilePicture != null &&
                                  profilePicture!.isNotEmpty
                              ? ClipOval(
                                  child: Image.memory(
                                    base64Decode(profilePicture!),
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Level $level',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Total Points: $totalPoints',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'XP: $experience/1000',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 100,
                                        child: LinearProgressIndicator(
                                          value: experience / 1000,
                                          minHeight: 6,
                                          backgroundColor: Colors.grey.shade700,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                  Color>(Colors.green),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Trophy Case',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Streak: $streak days',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: milestoneLabels.length,
                          itemBuilder: (context, index) {
                            final label = milestoneLabels[index];
                            final achieved = achievements.contains(label);
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: achieved
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.grey.shade800,
                                  ),
                                  child: Icon(
                                    achieved
                                        ? milestoneTrophies[label]
                                        : Icons.lock,
                                    color: achieved
                                        ? Colors.yellow
                                        : Colors.grey.shade500,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Time Spent (Minutes)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<double>>(
                          stream: SessionTracker().streamDailyTimeSpent(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return const Text(
                                'Error loading time data',
                                style: TextStyle(color: Colors.red),
                              );
                            }

                            dailyTimeSpent = snapshot.data ??
                                [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
                            double maxY = dailyTimeSpent.isNotEmpty
                                ? (dailyTimeSpent
                                            .reduce((a, b) => a > b ? a : b) *
                                        1.2)
                                    .ceilToDouble()
                                : 10.0;
                            if (maxY < 10) maxY = 10.0;

                            return SizedBox(
                              height: 150,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: maxY,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${rod.toY.toStringAsFixed(1)} min',
                                          TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          int index = value.toInt();
                                          if (index < 0 ||
                                              index >= dayLabels.length) {
                                            return Container();
                                          }
                                          return Text(
                                            dayLabels[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          if (value == 0 || value == maxY)
                                            return Container();
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                  barGroups: List.generate(7, (index) {
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: dailyTimeSpent[index],
                                          color: Colors.green,
                                          width: 16,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.store,
                    color: Colors.black,
                    size: 20,
                  ),
                  label: Text(
                    'Visit Marketplace',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _navigateToMarketplace(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
