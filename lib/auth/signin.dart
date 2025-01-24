import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitsync_app/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'signup.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> signIn(BuildContext context) async {
      try {
        final FirebaseAuth auth = FirebaseAuth.instance;
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Signin Text
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
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF5CB85C), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Password Text Field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF5CB85C), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Signin Button
              ElevatedButton(
                onPressed: () => signIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB85C), // Green color
                  minimumSize: const Size(double.infinity, 56), // Larger button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
              ElevatedButton(
                onPressed: () {
                  // Add Google authentication logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56), // Larger button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.g_mobiledata, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Continue With Google',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Don't have an account? Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign-in screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Signup",
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
