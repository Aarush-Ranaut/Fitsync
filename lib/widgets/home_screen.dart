import 'dart:convert';
import 'dart:ui';
import 'package:fitsync_app/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen

class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({Key? key, this.username}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profilePictureBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
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
    FirebaseAuth.instance.signOut(); // Sign out the user
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

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
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
                SizedBox(height: 16),
                Text(
                  widget.username ?? 'Guest',
                  style: TextStyle(
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
                    icon: Icon(Icons.logout, color: Colors.white),
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
                    icon: Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Jan 22, 2025',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                '${widget.username ?? 'Loading...'}',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Heart Rate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '69 BPM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Heart Rate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '69 BPM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Icon(
                            Icons.watch,
                            size: 40,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Tutorials',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage('assets/back_workout.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.6),
                          child: Text(
                            'BACK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage('assets/chest_workout.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.6),
                          child: Text(
                            'CHEST',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
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
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.green,
                  child: Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
