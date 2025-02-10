import 'package:fitsync_app/auth/signup.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Future<List<Image>> _imageFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future for loading images
    _imageFuture = _loadImages();
  }

  Future<List<Image>> _loadImages() async {
    // Simulate a delay for loading images
    await Future.delayed(const Duration(seconds: 2));
    final List<String> images = [
      'assets/images/fitness1.jpg',
      'assets/images/fitness2.jpg',
      'assets/images/fitness3.jpg',
      'assets/images/fitness4.jpg',
      'assets/images/fitness5.jpg',
      'assets/images/fitness6.jpg',
    ];

    // Load all images in the background and return them
    return images
        .map((imagePath) => Image.asset(imagePath, fit: BoxFit.cover))
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
    // Here we would dispose any resources if necessary, such as image controllers, but since we're using `Image.asset`,
    // Flutter takes care of this cleanup automatically.
  }

  @override
  Widget build(BuildContext context) {
    // Reusable button style for consistency
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5CB85C),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              // Using FutureBuilder to load images asynchronously
              Expanded(
                child: FutureBuilder<List<Image>>(
                  future: _imageFuture, // Load images asynchronously
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show a loading indicator while images are loading
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      // Handle errors if any
                      return const Center(child: Text('Error loading images'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No images found'));
                    }

                    // Grid of circular images
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[800]!,
                                width: 2,
                              ),
                            ),
                            child: snapshot.data![index],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    style: buttonStyle,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
