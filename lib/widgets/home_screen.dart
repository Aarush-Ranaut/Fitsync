import 'package:flutter/material.dart';
import '../auth/signin.dart'; // Import the SignIn screen

class HomeScreen extends StatelessWidget {
  final String username;
  final String profilePictureUrl; // URL for profile picture

  HomeScreen({required this.username, required this.profilePictureUrl});

  void _logout(BuildContext context) {
    // Clear any user session or state here
    // For example, if you're using shared preferences to store user data:
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.remove('userToken');
    //   prefs.remove('username');
    // });

    // Navigate to the SignIn screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
      (Route<dynamic> route) => false, // This removes all routes
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
                    backgroundColor: Colors.grey,
                    radius: 24,
                    backgroundImage: profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : null,
                  ),
                  IconButton(
                    onPressed: () {
                      _logout(context); // Call the logout function
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                username,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Workout",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.6, // 60% progress
                          backgroundColor: Colors.black,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        Text(
                          "60%",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                  ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
        ],
      ),
    );
  }
}
