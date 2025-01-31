import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/signin.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  HomeScreen({required this.username});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _username;
  String? _profilePictureBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(); // Fetch user data from Firestore

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['firstName'] ?? 'Guest'; // Fetch username (e.g., firstName)
            _profilePictureBase64 = userDoc['profileImage'] ?? ''; // Fetch profileImage
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
    FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _profilePictureBase64 != null && _profilePictureBase64!.isNotEmpty
                        ? MemoryImage(base64Decode(_profilePictureBase64!))
                        : const AssetImage('assets/icons/ic_default_avatar.jpg')
                            as ImageProvider,
                  ),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Welcome, ${_username ?? 'Loading...'}!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () => "", // Add your functionality here
                  backgroundColor: Colors.green,
                  child: Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
        ],
      ),
    );
  }
}
