import 'package:fitsync_app/models/onboarding_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import './home_screen.dart';

class WorkoutFrequencyScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const WorkoutFrequencyScreen({required this.onboardingData, super.key});

  @override
  _WorkoutFrequencyScreenState createState() => _WorkoutFrequencyScreenState();
}

class _WorkoutFrequencyScreenState extends State<WorkoutFrequencyScreen>
    with SingleTickerProviderStateMixin {
  int selectedFrequency = 3;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Color _primaryColor = const Color(0xFF7CBA3B); // Updated color

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
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
          "Workout Frequency",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "How often do you want to work out each week?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildFrequencySelector(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    const double minValue = 1;
    const double maxValue = 7;
    const int divisions = 6;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$selectedFrequency',
            key: ValueKey<int>(selectedFrequency),
            style: GoogleFonts.poppins(
              fontSize: 64,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
              shadows: [
                Shadow(
                  color: _primaryColor.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "time${selectedFrequency == 1 ? '' : 's'} / week",
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _primaryColor,
              inactiveTrackColor: Colors.grey[800],
              trackHeight: 6,
              thumbColor: _primaryColor,
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12, elevation: 4),
              overlayColor: _primaryColor.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              valueIndicatorColor: _primaryColor,
              valueIndicatorTextStyle: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: selectedFrequency.toDouble(),
              min: minValue,
              max: maxValue,
              divisions: divisions,
              label:
                  "$selectedFrequency time${selectedFrequency == 1 ? '' : 's'}",
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value.toInt();
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You've selected $selectedFrequency weekly session${selectedFrequency == 1 ? '' : 's'}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () {
              widget.onboardingData.workoutFrequency = selectedFrequency;
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    onboardingData: widget.onboardingData,
                    showEnergyDialog: () {},
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              shadowColor: _primaryColor.withOpacity(0.3),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                "Continue",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
