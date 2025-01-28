import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/signin.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String profilePictureUrl;

  HomeScreen({required this.username, required this.profilePictureUrl});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _profilePictureUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _profilePictureUrl = widget.profilePictureUrl;
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _profilePictureUrl = userDoc['profilePictureUrl'] ?? '';
        });
      }
    }
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        // Upload to Firebase Storage
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/${user.uid}.jpg');

          await storageRef.putFile(File(photo.path));
          String newUrl = await storageRef.getDownloadURL();

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePictureUrl': newUrl});

          // Update local state
          setState(() {
            _profilePictureUrl = newUrl;
          });
        }
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture')),
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
                    backgroundImage: _profilePictureUrl.isNotEmpty
                        ? NetworkImage(_profilePictureUrl)
                        : null,
                    child: _profilePictureUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Welcome, ${widget.username}!',
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
                  onPressed: _openCamera,
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
