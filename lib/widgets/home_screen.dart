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

  const HomeScreen({
    super.key,
    required this.username,
    required this.profilePictureUrl,
  });

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
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/${user.uid}.jpg');

          await storageRef.putFile(File(photo.path));
          String newUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePictureUrl': newUrl});

          setState(() {
            _profilePictureUrl = newUrl;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture')),
      );
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _profilePictureUrl.isNotEmpty
                  ? NetworkImage(_profilePictureUrl)
                  : null,
              child: _profilePictureUrl.isEmpty
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${widget.username}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openCamera,
              child: const Text('Update Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
