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
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    Future<void> signOut() async {
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SigninScreen()),
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
