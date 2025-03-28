import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'gender_selection.dart';
import 'weight_picker_page.dart'; // Import WeightPickerPage
import 'step_progress_indicator.dart'; // Import the reusable widget
import 'package:fitsync_app/models/onboarding_data.dart'; // Import OnboardingData

class ProfileScreen extends StatefulWidget {
  final String userId;
  final OnboardingData onboardingData;

  const ProfileScreen(
      {Key? key, required this.userId, required this.onboardingData})
      : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? _profilePicture;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _birthDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Step management
  int _currentStep = 1;
  final int _totalSteps = 4;

  // Animation-related
  late AnimationController _animationController;
  late Animation<double> _animation;
  Animation<Color?>? _buttonColorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _buttonColorAnimation = ColorTween(
      begin: const Color(0xFF5CB85C),
      end: const Color(0xFF4CAF50),
    ).animate(_animationController);

    _animationController.forward(); // Play the animation once

    _fetchUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (widget.userId.isEmpty) {
      _showSnackBar("Error: Invalid user ID.");
      return;
    }

    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        if (data['profileImage'] != null && data['profileImage'].isNotEmpty) {
          setState(() {
            _profilePicture = data['profileImage'];
          });
        }
        if (data['birthDate'] != null) {
          setState(() {
            _birthDate = DateTime.parse(data['birthDate']);
          });
        }
      }
    } catch (e) {
      _showSnackBar("Error fetching data: $e");
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profilePicture = base64Encode(bytes);
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF5CB85C),
              onPrimary: Colors.black,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
      });
    }
  }

  Future<void> _saveData() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    print("Saving data for user: ${widget.userId}");
    if (firstName.isEmpty || lastName.isEmpty) {
      _showSnackBar("First name and last name are required");
      print("Validation failed: First or last name empty");
      return;
    }

    if (_birthDate == null) {
      _showSnackBar("Please select your birth date");
      print("Validation failed: Birth date not selected");
      return;
    }

    if (widget.userId.isEmpty) {
      _showSnackBar("Error: Invalid user ID.");
      print("Validation failed: userId is empty");
      return;
    }

    try {
      print("Attempting to save to Firestore...");
      await _firestore.collection('users').doc(widget.userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': _profilePicture ?? '',
        'birthDate': _birthDate!.toIso8601String(),
      }, SetOptions(merge: true));
      print("Firestore save successful");
      _showSnackBar("Profile saved successfully");

      if (mounted) {
        print("Navigating to WeightPickerPage...");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WeightPickerPage(onboardingData: widget.onboardingData),
          ),
        );
        print("Navigation triggered");
      }
    } catch (e) {
      print("Error occurred: $e");
      _showSnackBar("Error saving data: $e");
    }
  }

  void _showImageInFullScreen() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                radius: 120,
                backgroundImage: _profilePicture != null
                    ? MemoryImage(base64Decode(_profilePicture!))
                    : null,
                child: _profilePicture == null
                    ? const Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5CB85C).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: GoogleFonts.roboto(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: prefixIcon != null
                      ? Icon(prefixIcon, color: Colors.grey[400], size: 20)
                      : null,
                  suffixIcon: suffixIcon,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF5CB85C), width: 1.5),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF121212),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5CB85C).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _buttonColorAnimation?.value ?? const Color(0xFF5CB85C),
                        const Color(0xFF4CAF50),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
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
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animation.value)),
              child: Opacity(
                opacity: _animation.value,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        StepProgressIndicator(
                          currentStep: _currentStep,
                          totalSteps: _totalSteps,
                        ),
                        const SizedBox(height: 24),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            GestureDetector(
                              onTap: _showImageInFullScreen,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E1E1E),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5CB85C)
                                          .withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  image: _profilePicture != null
                                      ? DecorationImage(
                                          image: MemoryImage(
                                              base64Decode(_profilePicture!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profilePicture == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey[400],
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5CB85C),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Personal Information",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          label: 'First Name',
                          controller: _firstNameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Birth Date',
                          controller: TextEditingController(
                            text: _birthDate != null
                                ? "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"
                                : '',
                          ),
                          prefixIcon: Icons.calendar_today,
                          readOnly: true,
                          onTap: _pickBirthDate,
                        ),
                        const SizedBox(height: 32),
                        _buildButton(
                          text: 'Save & Continue',
                          onPressed: _saveData,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
