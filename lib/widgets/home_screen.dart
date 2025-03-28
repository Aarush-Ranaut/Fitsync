import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitsync_app/onboarding_screen.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import 'gemini_api.dart';

class HomeScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const HomeScreen({required this.onboardingData, super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> workoutPlan = {};
  bool isLoading = true;
  int _currentDay = 1;
  Map<String, dynamic> _workoutProgress = {};
  Map<String, dynamic> muscleEnergy = {};
  final double recoveryRate = 20.0;
  final double drainFactor = 100.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Animation<double>> _cardAnimations;

  double _progressValue = 0.0;
  String _progressMessage = "Fetch user data...";
  bool _showFakeProgressDialog = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProgress();
    _cardAnimations = [];
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDay = prefs.getInt('currentDay') ?? 1;
    _workoutProgress = jsonDecode(prefs.getString('progress') ?? '{}');
    String? muscleEnergyJson = prefs.getString('muscleEnergy');
    if (muscleEnergyJson != null) {
      setState(() {
        muscleEnergy = jsonDecode(muscleEnergyJson);
      });
    }
    _startFakeProgress();
  }

  void _startFakeProgress() {
    const totalDuration = 5;
    const steps = [
      "Fetch user data...",
      "Analyzing preferences...",
      "Generating plan...",
      "Finalizing details..."
    ];
    int currentStep = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildFakeProgressDialog(),
      );
    });

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progressValue += 0.02;
        if (_progressValue >= (currentStep + 1) / steps.length) {
          currentStep++;
          if (currentStep < steps.length) {
            _progressMessage = steps[currentStep];
          }
        }

        if (_progressValue >= 1.0) {
          timer.cancel();
          _showFakeProgressDialog = false;
          Navigator.pop(context);
          loadWorkoutPlan();
        }
      });
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentDay', _currentDay);
    await prefs.setString('progress', jsonEncode(_workoutProgress));
  }

  Future<void> _updateMuscleEnergy(String muscle, double volume) async {
    final prefs = await SharedPreferences.getInstance();

    double currentEnergy = 100.0;
    DateTime lastUpdated = DateTime.now();

    if (muscleEnergy.containsKey(muscle)) {
      currentEnergy = muscleEnergy[muscle]['energy'];
      lastUpdated = DateTime.parse(muscleEnergy[muscle]['lastUpdated']);
    }

    double drain = volume / drainFactor;
    double newEnergy = (currentEnergy - drain).clamp(0.0, 100.0);

    setState(() {
      muscleEnergy[muscle] = {
        'energy': newEnergy,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    });

    await prefs.setString('muscleEnergy', jsonEncode(muscleEnergy));
  }

  double getCurrentEnergy(String muscle) {
    if (!muscleEnergy.containsKey(muscle)) return 100.0;

    final data = muscleEnergy[muscle];
    final storedEnergy = data['energy'].toDouble();
    final lastUpdated = DateTime.parse(data['lastUpdated']);
    final hoursPassed = DateTime.now().difference(lastUpdated).inSeconds / 3600;
    final recovered = hoursPassed * recoveryRate;

    return (storedEnergy + recovered).clamp(0.0, 100.0);
  }

  void _showEnergyDialog(BuildContext context) {
    final muscles = muscleEnergy.keys.toList();
    final currentEnergies = {
      for (var muscle in muscles) muscle: getCurrentEnergy(muscle)
    };

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
              final energy = currentEnergies[muscle]!;
              return ListTile(
                title: Text(
                  muscle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                trailing: Text(
                  "${energy.toStringAsFixed(1)}%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: energy / 100,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    energy > 50
                        ? const Color(0xFF89F336)
                        : energy > 25
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

  Future<void> loadWorkoutPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('workoutPlan');

      if (savedData != null) {
        setState(() {
          workoutPlan = jsonDecode(savedData);
          isLoading = false;
          _updateCardAnimations();
        });
      } else {
        fetchWorkoutPlan();
      }
    } catch (e) {
      print("Error loading saved workout plan: $e");
      fetchWorkoutPlan();
    }
  }

  Future<void> fetchWorkoutPlan() async {
    try {
      String data = await rootBundle.loadString('assets/exercises.json');
      List<dynamic> rawList = jsonDecode(data);
      List<Map<String, dynamic>> exercisesDB =
          rawList.map((e) => Map<String, dynamic>.from(e)).toList();

      Map<String, dynamic> plan = await GeminiAI.generateWorkoutPlan(
          widget.onboardingData, exercisesDB);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('workoutPlan', jsonEncode(plan));

      setState(() {
        workoutPlan = plan;
        isLoading = false;
        _updateCardAnimations();
      });
    } catch (e) {
      print("Error fetching workout plan: $e");
      setState(() {
        isLoading = false;
        _cardAnimations = [];
      });
    }
  }

  void _updateCardAnimations() {
    final exerciseCount =
        workoutPlan["Day $_currentDay"]?["exercises"]?.length ?? 0;
    _cardAnimations = List.generate(
      exerciseCount,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (index * 0.1),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _animationController.reset();
    _animationController.forward();
  }

  int get workoutPlanLength =>
      workoutPlan.keys.where((k) => k.startsWith("Day")).length;

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Workout Planner",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            "Welcome, ${_auth.currentUser?.email?.split('@')[0] ?? "User"}!",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Goal: ${widget.onboardingData.goal}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[400],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _activePlanHeader(),
                          ),
                          const SizedBox(height: 20),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _nextWorkoutSection(),
                          ),
                          const SizedBox(height: 20),
                          _exerciseList(),
                        ],
                      ),
                    ),
                  ),
                  _startWorkoutButton(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEnergyDialog(context),
        backgroundColor: const Color(0xFF89F336),
        child: const Icon(Icons.fitness_center, color: Colors.white),
      ),
    );
  }

  Widget _buildFakeProgressDialog() {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fitness_center,
              color: Color(0xFF89F336),
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              "Building Your Plan",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _progressMessage,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.grey[700],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF89F336)),
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  "${(_progressValue * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: index < (_progressValue * 3).toInt()
                        ? const Color(0xFF89F336)
                        : Colors.grey[700],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activePlanHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.flash_on, color: Color(0xFF89F336)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "Active Plan: ${_auth.currentUser?.email?.split('@')[0] ?? "User"}'s Journey",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {},
            child: Text(
              "Plans",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextWorkoutSection() {
    return Row(
      children: [
        const Icon(Icons.play_arrow, color: Color(0xFF89F336)),
        const SizedBox(width: 8),
        Text(
          "Your next workout: Day $_currentDay",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _exerciseList() {
    final exerciseCount =
        workoutPlan["Day $_currentDay"]?["exercises"]?.length ?? 0;

    if (exerciseCount == 0 || _cardAnimations.isEmpty) {
      return const Center(
        child: Text(
          "No exercises available for this day.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: exerciseCount,
        itemBuilder: (context, index) {
          if (index >= _cardAnimations.length) {
            return const SizedBox.shrink();
          }
          return FadeTransition(
            opacity: _cardAnimations[index],
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _cardAnimations[index].value)),
              child: _exerciseCard(
                  workoutPlan["Day $_currentDay"]["exercises"][index]),
            ),
          );
        },
      ),
    );
  }

  Widget _exerciseCard(Map<String, dynamic> exercise) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    getExerciseImage(exercise["name"]),
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.white54,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise["name"],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${exercise["sets"]} sets x ${exercise["reps"]} reps",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _startWorkoutButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              "${workoutPlan["Day $_currentDay"]?["exercises"]?.length ?? 0} exercises for Day $_currentDay",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF89F336),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.flash_on, color: Colors.white),
            label: Text(
              "Start",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () async {
              if (workoutPlan.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: Text(
                      "Workout Started",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    content: Text(
                      "Workout tracking is not available yet.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _currentDay =
                              (_currentDay % workoutPlanLength) + 1);
                          _saveProgress();
                        },
                        child: Text(
                          "Finish",
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
            },
          ),
        ],
      ),
    );
  }

  String getExerciseImage(String exerciseName) {
    return "assets/exercises/${exerciseName.toLowerCase().replaceAll(" ", "_")}.png";
  }
}
