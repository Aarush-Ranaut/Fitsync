import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitsync_app/models/onboarding_data.dart';
import './experience_level_screen.dart';

class FocusAreaScreen extends StatefulWidget {
  final OnboardingData onboardingData;
  const FocusAreaScreen({required this.onboardingData, super.key});

  @override
  _FocusAreaScreenState createState() => _FocusAreaScreenState();
}

class _FocusAreaScreenState extends State<FocusAreaScreen>
    with SingleTickerProviderStateMixin {
  // Focus areas with their image paths and descriptions
  final List<Map<String, dynamic>> focusAreas = [
    {
      "name": "Chest",
      "image": "assets/images/chest.png",
      "description": "Build strength and definition"
    },
    {
      "name": "Triceps",
      "image": "assets/images/triceps.png",
      "description": "Tone and strengthen arms"
    },
    {
      "name": "Back",
      "image": "assets/images/back.png",
      "description": "Improve posture and power"
    },
    {
      "name": "Biceps",
      "image": "assets/images/biceps.png",
      "description": "Develop arm definition"
    },
    {
      "name": "Shoulder",
      "image": "assets/images/shoulder.png",
      "description": "Build broader shoulders"
    },
    {
      "name": "Abs",
      "image": "assets/images/abs.png",
      "description": "Define your core"
    },
    {
      "name": "Legs",
      "image": "assets/images/legs.png",
      "description": "Strengthen lower body"
    },
  ];

  List<String> selectedAreas = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

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
          "Choose Your Focus Areas",
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
                  "Select the muscle groups you want to focus on in your workouts",
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
                  itemCount: focusAreas.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> area = focusAreas[index];
                    bool isSelected = selectedAreas.contains(area["name"]);

                    return _buildFocusAreaCard(area, isSelected);
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

  Widget _buildFocusAreaCard(Map<String, dynamic> area, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(area["name"]),
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
                  // Image container
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        area["image"],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Muscle name
                  Text(
                    area["name"],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  // Description
                  Text(
                    area["description"],
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
              "${selectedAreas.length} of ${focusAreas.length} areas selected",
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
                  onPressed: selectedAreas.isNotEmpty
                      ? () {
                          widget.onboardingData.focusAreas = selectedAreas;

                          // Add haptic feedback
                          HapticFeedback.mediumImpact();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExperienceLevelScreen(
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

  void _toggleSelection(String muscle) {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      selectedAreas.contains(muscle)
          ? selectedAreas.remove(muscle)
          : selectedAreas.add(muscle);
    });
  }

  void _selectAll() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      if (selectedAreas.length == focusAreas.length) {
        // If all are selected, deselect all
        selectedAreas.clear();
      } else {
        // Otherwise select all
        selectedAreas =
            focusAreas.map((area) => area["name"] as String).toList();
      }
    });
  }
}
