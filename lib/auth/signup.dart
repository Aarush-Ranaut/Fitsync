import 'package:flutter/material.dart';
import 'package:fitsync_app/auth/signin.dart';
import 'auth_service.dart';
import 'package:fitsync_app/widgets/user_info/profile_screen.dart'; // Import ProfileScreen
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Updated signUpWithGoogle method
  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      // Sign out from any existing sessions
      await AuthService().signOut();

      // Sign in with Google
      final user = await AuthService().signInWithGoogle();

      if (user != null) {
        // Check if the user already exists in Firestore using UID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Account already exists in Firestore, redirect to sign-in
          _showSnackBar("Account already exists. Please sign in.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SigninScreen()),
          );
        } else {
          // New user, create a basic Firestore document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'username':
                user.displayName ?? '', // Optional: Use Google display name
          }, SetOptions(merge: true));

          _showSnackBar("Signup Successful!");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: user.uid),
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

// Updated _signup method
  // In signup.dart
  Future<void> _signup(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation checks (add your existing validation here)
    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    try {
      final user =
          await AuthService().createUserWithEmailAndPassword(email, password);

      if (user != null) {
        // Create a basic Firestore document for the user
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {
              'email': email,
              'createdAt': FieldValue.serverTimestamp(),
              // Add other default fields if needed, e.g., 'username': ''
            },
            SetOptions(
                merge:
                    true)); // merge: true ensures we don’t overwrite existing data later

        _showSnackBar("Signup Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: user.uid),
          ),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      bool obscureText = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
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

  Widget _buildButton(
      {required String text,
      required VoidCallback onPressed,
      Color backgroundColor = const Color(0xFF5CB85C),
      Color textColor = Colors.white}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
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
              _buildTextField(label: 'Email', controller: _emailController),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true),
              const SizedBox(height: 24),
              _buildButton(text: 'Sign Up', onPressed: () => _signup(context)),
              const SizedBox(height: 24),
              const Text(
                'OR',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildButton(
                text: 'Continue With Google',
                onPressed: () => signUpWithGoogle(context),
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already a user? ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SigninScreen()),
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
}
