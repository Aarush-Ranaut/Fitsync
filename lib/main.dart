import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fitsync_app/onboarding_screen.dart';
import 'package:fitsync_app/widgets/edit_profile_screen.dart';
import 'package:fitsync_app/widgets/home_screen.dart';
import 'package:fitsync_app/widgets/exercise_selection.dart';
import 'package:fitsync_app/widgets/gamification_provider.dart';
import 'firebase_options.dart';
import 'package:fitsync_app/widgets/user_data_provider.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GamificationProvider()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return const MainScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Color limeGreenColor = const Color(0xFF90FF42);

  static const List<NavigationItemData> _navigationItems = [
    NavigationItemData(iconPath: 'assets/images/home.png', label: 'Home'),
    NavigationItemData(iconPath: 'assets/images/camera.png', label: 'Camera'),
    NavigationItemData(iconPath: 'assets/images/watch.png', label: 'Watch'),
    NavigationItemData(iconPath: 'assets/images/profile.png', label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      _showChatAIDialog();
    }
  }

  void _showChatAIDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          "Chat with AI",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          "This is a placeholder for the Chat AI feature.",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[400],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF89F336),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEnergyDialog(BuildContext context) {
    final muscles = ['Chest', 'Back', 'Legs', 'Arms', 'Shoulders'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          "Muscle Energy Levels",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: muscles.length,
            itemBuilder: (context, index) {
              final muscle = muscles[index];
              return ListTile(
                title: Text(
                  muscle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  "${70 + index * 5}%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: (70 + index * 5) / 100,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (70 + index * 5) > 50
                        ? const Color(0xFF89F336)
                        : (70 + index * 5) > 25
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF89F336),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.85),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_navigationItems.length, (index) {
              return GestureDetector(
                onTap: () => _onItemTapped(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index
                        ? limeGreenColor.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        _navigationItems[index].iconPath,
                        width: 24,
                        height: 24,
                        color: _selectedIndex == index
                            ? limeGreenColor
                            : Colors.white70,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _navigationItems[index].label,
                        style: TextStyle(
                          color: _selectedIndex == index
                              ? limeGreenColor
                              : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    var defaultOnboardingData = OnboardingData(
      goal: 'Build Muscle',
      focusAreas: ['Chest', 'Legs'],
      experience: 'Beginner',
      workoutFrequency: 3,
    );

    switch (_selectedIndex) {
      case 0:
        return HomeScreen(
          onboardingData: defaultOnboardingData,
          showEnergyDialog: () => _showEnergyDialog(context),
        );
      case 1:
        return const ExerciseSelectionScreen();
      case 2:
        return const Center(
            child: Text("Watch Feature Coming Soon",
                style: TextStyle(fontSize: 20, color: Colors.white)));
      case 3:
        return EditProfileScreen(onboardingData: defaultOnboardingData);
      default:
        return HomeScreen(
          onboardingData: defaultOnboardingData,
          showEnergyDialog: () => _showEnergyDialog(context),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          _buildPageContent(),
          _buildBottomNavigationBar(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showEnergyDialog(context),
              backgroundColor: const Color(0xFF89F336),
              child: const Icon(Icons.fitness_center, color: Colors.white),
            )
          : null,
    );
  }
}

class NavigationItemData {
  final String iconPath;
  final String label;

  const NavigationItemData({required this.iconPath, required this.label});
}
