import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup.dart';
import '../widgets/home_screen.dart'; // Import the HomeScreen

class SigninScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signIn(BuildContext context) async {
    try {
      final user = await AuthService().loginUserWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (user != null) {
        // Fetch user data from Firestore using UID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String username = userDoc.data()?['username'] ?? user.email ?? '';
          String profilePictureUrl = userDoc.data()?['profilePictureUrl'] ?? '';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                username: username,
                profilePictureUrl: profilePictureUrl,
              ),
            ),
          );
        } else {
          // User document not found, sign out and show error
          await AuthService().signOut();
          _showSnackBar(context, "User data not found. Please sign up.");
        }
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out from Google first to ensure a fresh sign-in
      await AuthService().signOutFromGoogle();

      // Sign in with Google
      final user = await AuthService().signInWithGoogle();
      if (user != null) {
        // Check if the user exists in Firestore using UID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Get username and profile picture from Firestore
          String username = userDoc.data()?['username'] ??
              user.displayName ??
              user.email ??
              'User';
          String profilePictureUrl = userDoc.data()?['profilePictureUrl'] ?? '';

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                username: username,
                profilePictureUrl: profilePictureUrl,
              ),
            ),
          );
        } else {
          // User does not exist in Firestore, show error and sign out
          await AuthService().signOut();
          _showSnackBar(context, "Account not found. Please sign up.");
        }
      } else {
        _showSnackBar(context, "Google sign-in failed.");
      }
    } catch (e) {
      _showSnackBar(context, e.toString());
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Signup Text
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Signup',
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
                'Sign in',
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

              // Continue with Google Button
              _buildActionButton(
                context,
                'Continue With Google',
                () => signInWithGoogle(context),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.g_mobiledata, size: 24),
              ),
              const SizedBox(height: 30),

              // Already a user? Sign in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a user? ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign-up screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Sign in",
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

  // Helper method to build text fields
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

  // Helper method to build action buttons
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
