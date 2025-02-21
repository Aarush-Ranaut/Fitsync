// home_screen.dart
import 'dart:convert';
import 'dart:ui';
import 'package:fitsync_app/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import '../widgets/Camera_integrate.dart';
import '../widgets/ai_integration.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profilePictureBase64;
  String _firstName = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

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

  void _navigateToEditProfile(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: userId),
      ),
    );
  }

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: _profilePictureBase64 != null &&
                          _profilePictureBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(_profilePictureBase64!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/icons/ic_default_avatar.jpg',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  _firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PoseScreen()),
            ),
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AIIntegration(
                        apiKey: 'AIzaSyB1FflSFQMelsT-Ra27xsPLAlBjfsW7uLU',
                      )),
            ),
            backgroundColor: Colors.green,
            child: const Icon(Icons.smart_toy, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => _showProfilePopup(context),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: _profilePictureBase64 != null &&
                              _profilePictureBase64!.isNotEmpty
                          ? MemoryImage(base64Decode(_profilePictureBase64!))
                          : const AssetImage(
                                  'assets/icons/ic_default_avatar.jpg')
                              as ImageProvider,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _navigateToEditProfile(context),
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Jan 22, 2025',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                _firstName,
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
