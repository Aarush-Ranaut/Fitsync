import 'dart:convert';
import 'package:fitsync_app/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import 'edit_profile_screen.dart';
import '../widgets/ai_integration.dart'; // Make sure AIIntegration is imported

class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({super.key, this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<NavigationItemData> _navigationItems = [
    NavigationItemData(icon: Icons.home, label: 'Home'),
    NavigationItemData(icon: Icons.person, label: 'Profile'),
    NavigationItemData(icon: Icons.settings, label: 'Settings'),
  ];

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return {"firstName": "Guest", "profileImage": ""};

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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
        case 0: // Home
          break; // Already on home, no action needed
        case 1: // Profile
          _navigateToEditProfile(context);
          break;
        case 2: // Settings
          // Navigate to settings screen - Implement this!
          break;
      }
    });
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
      (Route<dynamic> route) => false,
    );
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

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartwatchCard() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              "Smartwatch Connected",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorials() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.green, size: 32),
              SizedBox(width: 12),
              Text(
                "Tutorial ${index + 1}",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: Colors.green));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading data",
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    );
                  }

                  String firstName = snapshot.data?['firstName'] ?? "Guest";
                  String profilePictureBase64 =
                      snapshot.data?['profileImage'] ?? "";

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _logout(context),
                            icon: Icon(Icons.logout, color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: profilePictureBase64.isNotEmpty
                                  ? MemoryImage(base64Decode(profilePictureBase64))
                                  : AssetImage('assets/icons/ic_default_avatar.jpg')
                                      as ImageProvider,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _navigateToEditProfile(context),
                            icon: Icon(Icons.edit, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        intl.DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        firstName,
                        style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoCard("Heart Rate", "69 BPM"),
                          SizedBox(width: 16),
                          _buildSmartwatchCard(),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Tutorials',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildTutorials(),
                    ],
                  );
                },
              ),
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 70,
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 3,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  items: _navigationItems.map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon, color: Colors.white),
                    label: item.label,
                  )).toList(),
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.green,
                  unselectedItemColor: Colors.grey,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                ),
              ),
            ),
          ),
          
          // AI Integration Floating Action Button
          Positioned(
            right: 20,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIIntegration(
                      apiKey: 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU',
                    ),
                  ),
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
}

class NavigationItemData {
  final IconData icon;
  final String label;

  const NavigationItemData({required this.icon, required this.label});
}
