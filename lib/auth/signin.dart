import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'signup.dart';
import '../widgets/home_screen.dart';
import '../widgets/user_info/profile_screen.dart';
import 'forgot_password_screen.dart';
import '../models/onboarding_data.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> signIn(BuildContext context) async {
    try {
      final user = await AuthService().loginUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                userId: user.uid,
                onboardingData: OnboardingData(
                  goal: 'Maintain',
                  focusAreas: ['Full Body'],
                  experience: 'Beginner',
                  workoutFrequency: 3,
                ),
              ),
            ),
          );
        } else {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          List<String> requiredFields = [
            'firstName',
            'lastName',
            'height',
            'weight',
            'birthDate',
            'gender'
          ];

          bool isDataMissing = requiredFields.any((field) =>
              !data.containsKey(field) ||
              data[field] == null ||
              data[field].toString().isEmpty);

          if (isDataMissing) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: user.uid,
                  onboardingData: OnboardingData(
                    goal: 'Maintain',
                    focusAreas: ['Full Body'],
                    experience: 'Beginner',
                    workoutFrequency: 3,
                  ),
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  onboardingData: OnboardingData(
                    goal: 'Maintain',
                    focusAreas: ['Full Body'],
                    experience: 'Beginner',
                    workoutFrequency: 3,
                  ),
                  showEnergyDialog: () {},
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await AuthService().signOutFromGoogle();
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                userId: user.uid,
                onboardingData: OnboardingData(
                  goal: 'Maintain',
                  focusAreas: ['Full Body'],
                  experience: 'Beginner',
                  workoutFrequency: 3,
                ),
              ),
            ),
          );
        } else {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          List<String> requiredFields = [
            'firstName',
            'lastName',
            'height',
            'weight',
            'birthDate',
            'gender'
          ];

          bool isDataMissing = requiredFields.any((field) =>
              !data.containsKey(field) ||
              data[field] == null ||
              data[field].toString().isEmpty);

          if (isDataMissing) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userId: user.uid,
                  onboardingData: OnboardingData(
                    goal: 'Maintain',
                    focusAreas: ['Full Body'],
                    experience: 'Beginner',
                    workoutFrequency: 3,
                  ),
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  onboardingData: OnboardingData(
                    goal: 'Maintain',
                    focusAreas: ['Full Body'],
                    experience: 'Beginner',
                    workoutFrequency: 3,
                  ),
                  showEnergyDialog: () {},
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  void _navigateToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(
          initialEmail: emailController.text.trim(),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 55,
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
        obscureText: obscureText,
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
            borderSide: const BorderSide(color: Color(0xFF5CB85C), width: 1.5),
          ),
          filled: true,
          fillColor: const Color(0xFF121212),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF5CB85C),
    Color textColor = Colors.white,
    IconData? icon,
    Image? customIcon,
  }) {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [backgroundColor.withOpacity(0.8), backgroundColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                ],
                if (customIcon != null) ...[
                  customIcon,
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Fit',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Sync',
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF7CBA3B),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.roboto(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Password',
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    text: 'Sign In',
                    onPressed: () => signIn(context),
                    backgroundColor: const Color(0xFF7CBA3B),
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _navigateToForgotPassword(context),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.roboto(
                        color: const Color(0xFF7CBA3B),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[800],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: GoogleFonts.roboto(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    text: 'Continue with Google',
                    onPressed: () => signInWithGoogle(context),
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    customIcon: Image.asset(
                      'assets/images/google.png',
                      height: 24,
                      width: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.roboto(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(
                                onboardingData: OnboardingData(
                                  goal: 'Build Muscle',
                                  focusAreas: ['Chest', 'Legs'],
                                  experience: 'Beginner',
                                  workoutFrequency: 3,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.roboto(
                            color: const Color(0xFF7CBA3B),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
