import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import './workout_frequency_selection_screen.dart';

class ExperienceLevelScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const ExperienceLevelScreen({required this.onboardingData, super.key});

  @override
  _ExperienceLevelScreenState createState() => _ExperienceLevelScreenState();
}

class _ExperienceLevelScreenState extends State<ExperienceLevelScreen>
    with SingleTickerProviderStateMixin {
  List<String> selectedExperience = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Experience level data with descriptions and icons
  final List<Map<String, dynamic>> experienceLevels = [
    {
      "level": "Beginner",
      "description": "New to fitness or returning after a long break",
      "icon": Icons.emoji_people,
    },
    {
      "level": "Intermediate",
      "description": "Consistent training for 6+ months",
      "icon": Icons.directions_run,
    },
    {
      "level": "Advanced",
      "description": "Experienced with various training methods",
      "icon": Icons.sports_gymnastics,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize the fade animation for the screen
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start the animation
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
          "Your Fitness Experience",
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  "Select your fitness experience level to personalize your workout plan",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: experienceLevels.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> level = experienceLevels[index];
                    bool isSelected =
                        selectedExperience.contains(level["level"]);

                    return _buildExperienceCard(level, isSelected);
                  },
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> level, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(level["level"]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8ACA7A) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF8ACA7A).withOpacity(0.3)
                  : Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background gradient overlay
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

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Expanded(
                    child: Center(
                      child: Icon(
                        level["icon"],
                        size: 60,
                        color: Colors.white54,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Experience level name
                  Text(
                    level["level"],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // Description
                  Text(
                    level["description"],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: 8),
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF8ACA7A),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
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
          // Selected count indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
            child: Text(
              "${selectedExperience.length} of ${experienceLevels.length} levels selected",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ),

          // Buttons
          Row(
            children: [
              // Select All button
              Expanded(
                flex: 1,
                child: TextButton(
                  onPressed: _selectAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: Text(
                    "Select All",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Continue button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedExperience.isNotEmpty
                      ? () {
                          widget.onboardingData.experience =
                              selectedExperience.join(", ");

                          // Add haptic feedback
                          HapticFeedback.mediumImpact();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutFrequencyScreen(
                                  onboardingData: widget.onboardingData),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8ACA7A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[700],
                    disabledForegroundColor: Colors.grey[400],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String level) {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      selectedExperience.contains(level)
          ? selectedExperience.remove(level)
          : selectedExperience.add(level);
    });
  }

  void _selectAll() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      if (selectedExperience.length == experienceLevels.length) {
        // If all are selected, deselect all
        selectedExperience.clear();
      } else {
        // Otherwise select all
        selectedExperience =
            experienceLevels.map((level) => level["level"] as String).toList();
      }
    });
  }
}
