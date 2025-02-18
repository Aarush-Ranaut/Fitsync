import 'dart:convert';
import 'package:fitsync_app/auth/signin.dart';
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
  final limeGreenColor = Color(0xFF90FF42);

  static const List<NavigationItemData> _navigationItems = [
    NavigationItemData(iconPath: 'assets/images/home.png', label: ''),
    NavigationItemData(iconPath: 'assets/images/camera.png', label: ''),
    NavigationItemData(iconPath: 'assets/images/watch.png', label: ''),
    NavigationItemData(iconPath: 'assets/images/profile.png', label: ''),
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
        case 0:
          // Home
          break;
        case 1:
          // Camera
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
      width: 110,
      height: 110,
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
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.bothCurve,
              gradient: SweepGradient(
                colors: [Colors.blue, Colors.green],
                stops: [0.25, 0.75],
              ),
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: 75,
                needleLength: 0.8,
                lengthUnit: GaugeSizeUnit.factor,
                needleColor: Colors.redAccent,
                needleEndWidth: 5,
                knobStyle: KnobStyle(
                  color: Colors.white,
                  borderColor: Colors.redAccent,
                  borderWidth: 3,
                  sizeUnit: GaugeSizeUnit.factor,
                  knobRadius: 0.07,
                ),
                enableAnimation: true,
                animationType: AnimationType.ease,
                animationDuration: 1500,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '75%',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 11,
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
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey[800]!, Colors.grey[900]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 15,
          spreadRadius: 2,
          offset: Offset(0, 8),
        ),
        BoxShadow(
          color: limeGreenColor.withOpacity(0.2),
          blurRadius: 25,
          spreadRadius: 2,
          offset: Offset(0, 0), // Glowing effect
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: _buildGaugeMeter(),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHealthInfo(Icons.favorite, 'BPM', '72'),
              Divider(color: Colors.white24, thickness: 0.5),
              _buildHealthInfo(Icons.directions_walk, 'Steps', '8,546'),
              Divider(color: Colors.white24, thickness: 0.5),
              _buildHealthInfo(Icons.monitor_weight, 'BMI', '22.5'),
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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: limeGreenColor.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: limeGreenColor, size: 24),
      ),
      SizedBox(width: 12),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: limeGreenColor,
                fontSize: 18,
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
        "image": "assets/images/back_workout.jpg",
        "color": Color(0xFFCFFF95), // Peach color for back
      },
      {
        "title": "CHEST",
        "image": "assets/images/chest_workout.jpg",
        "color": Color(0xFFCFFF95), // Light yellow for chest
      },
      {
        "title": "CHEST",
        "image": "assets/images/chest_workout.jpg",
        "color": Color(0xFFCFFF95), // Light green for next card
      },
      {
        "title": "CHEST",
        "image": "assets/images/chest_workout.jpg",
        "color": Color(0xFFCFFF95), // Light green for last card
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tutorials",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: tutorial["color"],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        tutorial["title"]!,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            tutorial["image"]!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.green));
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

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        intl.DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            firstName,
                            style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.notifications, color: Colors.green, size: 28),
                            onPressed: () {
                              // Handle notification button press
                              print('Notification button pressed');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildHealthCard(),
                      SizedBox(height: 20),
                      _buildTutorials(),
                    ],
                  );
                },
              ),
            ),
          ),
         Positioned(
  left: 20,
  right: 20,
  bottom: 30,
  child: Container(
    height: 70,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.grey[900]!.withOpacity(0.85),
          Colors.grey[800]!.withOpacity(0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _navigationItems.map((item) {
        int index = _navigationItems.indexOf(item);
        bool isSelected = _selectedIndex == index;
        
        return GestureDetector(
          onTap: () {
            _onItemTapped(index);
          },
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item.iconPath,
                  color: isSelected ? Colors.greenAccent : Colors.white,
                  width: 30,
                  height: 30,
                ),
                SizedBox(height: 5),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? Colors.greenAccent : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  ),
),
          Positioned(
            bottom: 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _navigateToAIIntegration(context),
              backgroundColor: Colors.greenAccent,
              child: Icon(Icons.chat, color: Colors.white),
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
