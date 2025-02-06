import 'package:fitsync_app/auth/auth_service.dart';
import 'package:fitsync_app/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signIn(BuildContext context) async {
    try {
      final user = await AuthService().loginUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final username = userDoc['username'] ?? 'User';
        final profilePictureUrl = userDoc['profilePictureUrl'] ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: username,
              profilePictureUrl: profilePictureUrl,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final username = userDoc['username'] ?? 'User';
        final profilePictureUrl = userDoc['profilePictureUrl'] ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: username,
              profilePictureUrl: profilePictureUrl,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Signin Header Text
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' Now!',
                      style: TextStyle(
                        color: Color(0xFF5CB85C),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Email Text Field
              _buildTextField(emailController, 'Email', false),
              const SizedBox(height: 16),

              // Password Text Field
              _buildTextField(passwordController, 'Password', true),
              const SizedBox(height: 24),

              // Signin Button
              _buildActionButton(
                context,
                'Sign In',
                () => signIn(context),
                backgroundColor: const Color(0xFF5CB85C),
              ),
              const SizedBox(height: 24),

              // Divider Text
              const Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Sign In with Google Button
              _buildActionButton(
                context,
                'Sign In with Google',
                () => signInWithGoogle(context),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.g_mobiledata, size: 24),
              ),
              const SizedBox(height: 30),

              // New user? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "New here? ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign-up screen
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color(0xFF5CB85C),
                        fontSize: 16,
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
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5CB85C), width: 2),
        ),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    required Color backgroundColor,
    Color foregroundColor = Colors.white,
    Widget? icon,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          if (icon != null) const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
