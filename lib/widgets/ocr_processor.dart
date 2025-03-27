// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:dio/dio.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'calorie_calculator.dart'; // Import the CalorieCalculator screen

// class OCRProcessor extends StatefulWidget {
//   @override
//   _OCRProcessorState createState() => _OCRProcessorState();
// }

// class _OCRProcessorState extends State<OCRProcessor> {
//   final TextRecognizer textRecognizer = TextRecognizer();
//   final String apiUrl =
//       "http://192.168.206.58:5050/process_text"; // Flask server
//   File? _selectedImage;
//   String _extractedText = "Extracted text will appear here.";
//   String _normalIngredients = "Normal ingredients will appear here.";
//   String _calorieInfo = "Calorie information will appear here.";
//   bool _isProcessing = false;

//   final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: Duration(seconds: 10),
//       receiveTimeout: Duration(seconds: 10),
//       headers: {"Content-Type": "application/json"},
//     ),
//   );

//   /// **Pick Image from Camera or Gallery**
//   Future<void> _pickImage(ImageSource source) async {
//     final XFile? image = await ImagePicker().pickImage(source: source);
//     if (image != null) {
//       setState(() {
//         _selectedImage = File(image.path);
//         _extractedText = "Processing...";
//         _normalIngredients = "";
//         _calorieInfo = "";
//         _isProcessing = true;
//       });

//       // Extract text using OCR (Runs on the main thread)
//       String extractedText = await _extractText(_selectedImage!);
//       setState(() {
//         _extractedText = extractedText;
//       });

//       // Send text to Flask API
//       Map<String, dynamic> apiResponse = await _sendTextToAPI(extractedText);
//       setState(() {
//         _normalIngredients = apiResponse["details"] ?? "No details found";
//         _calorieInfo =
//             apiResponse["calories_per_100g"] ?? "No calorie info available";
//         _isProcessing = false;
//       });
//     }
//   }

//   /// **Extract Text using OCR (Runs on the main thread)**
//   Future<String> _extractText(File imageFile) async {
//     try {
//       final InputImage inputImage = InputImage.fromFile(imageFile);
//       final RecognizedText recognizedText =
//           await textRecognizer.processImage(inputImage);
//       return recognizedText.text;
//     } catch (e) {
//       return "Error extracting text: $e";
//     }
//   }

//   /// **Send Extracted Text to Flask API using Dio**
//   Future<Map<String, dynamic>> _sendTextToAPI(String extractedText) async {
//     try {
//       final response = await _dio.post(
//         apiUrl,
//         data: jsonEncode({"text": extractedText}),
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         return {
//           "details": data["details"] ?? "No details available",
//           "calories_per_100g":
//               data["calories_per_100g"] ?? "No calorie info available",
//         };
//       } else {
//         return {
//           "error": "API Error",
//           "details": "No details available",
//           "calories_per_100g": "No calorie info available"
//         };
//       }
//     } catch (e) {
//       return {
//         "error": "API Error: $e",
//         "details": "No details available",
//         "calories_per_100g": "No calorie info available"
//       };
//     }
//   }

//   @override
//   void dispose() {
//     textRecognizer.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("OCR & Calorie Info")),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _selectedImage != null
//                 ? Image.file(_selectedImage!, height: 200)
//                 : Icon(Icons.image, size: 200),
//             SizedBox(height: 20),

//             if (_isProcessing) ...[
//               Center(child: CircularProgressIndicator()),
//               SizedBox(height: 20),
//             ],

//             // **Extracted Text**
//             Text("🔹 Extracted Text:",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Text(_extractedText, textAlign: TextAlign.center),
//             Divider(),

//             // **Ingredients & Details**
//             Text("📝 Ingredients & Details:",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Text(_normalIngredients, textAlign: TextAlign.center),
//             Divider(),

//             // **Calories per 100g**
//             Text("🔥 Calories per 100g:",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Text(_calorieInfo, textAlign: TextAlign.center),
//             SizedBox(height: 20),

//             // **Pick Image Buttons**
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.camera),
//                   icon: Icon(Icons.camera),
//                   label: Text('Camera'),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: Icon(Icons.folder),
//                   label: Text('Gallery'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),

//             // **Navigate to Calorie Calculator**
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => CalorieCalculator()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//                 child: Text("Open Calorie Calculator"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calorie_calculator.dart';

class OCRProcessor extends StatefulWidget {
  @override
  _OCRProcessorState createState() => _OCRProcessorState();
}

class _OCRProcessorState extends State<OCRProcessor>
    with TickerProviderStateMixin {
  final TextRecognizer textRecognizer = TextRecognizer();
  final String apiUrl = "http://192.168.206.58:5050/process_text";
  File? _selectedImage;
  String _extractedText = "Extracted text will appear here.";
  String _normalIngredients = "Normal ingredients will appear here.";
  String _calorieInfo = "Calorie information will appear here.";
  bool _isProcessing = false;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _extractedText = "Processing...";
        _normalIngredients = "";
        _calorieInfo = "";
        _isProcessing = true;
      });

      String extractedText = await _extractText(_selectedImage!);
      setState(() {
        _extractedText = extractedText;
      });

      Map<String, dynamic> apiResponse = await _sendTextToAPI(extractedText);
      setState(() {
        _normalIngredients = apiResponse["details"] ?? "No details found";
        _calorieInfo =
            apiResponse["calories_per_100g"] ?? "No calorie info available";
        _isProcessing = false;
      });
    }
  }

  Future<String> _extractText(File imageFile) async {
    try {
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return "Error extracting text: $e";
    }
  }

  Future<Map<String, dynamic>> _sendTextToAPI(String extractedText) async {
    try {
      final response = await _dio.post(
        apiUrl,
        data: jsonEncode({"text": extractedText}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          "details": data["details"] ?? "No details available",
          "calories_per_100g":
              data["calories_per_100g"] ?? "No calorie info available",
        };
      } else {
        return {
          "error": "API Error",
          "details": "No details available",
          "calories_per_100g": "No calorie info available"
        };
      }
    } catch (e) {
      return {
        "error": "API Error: $e",
        "details": "No details available",
        "calories_per_100g": "No calorie info available"
      };
    }
  }

  Widget _buildImageDisplay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFF1E1E1E),
                      child: Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextCard(String title, String content) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Card(
            elevation: 4,
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8ACA7A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
    required IconData icon,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 150,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8ACA7A), Color(0xFF5CB85C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8ACA7A).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "OCR & Calorie Info",
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageDisplay(),
              const SizedBox(height: 24),
              if (_isProcessing) ...[
                Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildTextCard("🔹 Extracted Text", _extractedText),
              const SizedBox(height: 16),
              _buildTextCard("📝 Ingredients & Details", _normalIngredients),
              const SizedBox(height: 16),
              _buildTextCard("🔥 Calories per 100g", _calorieInfo),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    text: "Camera",
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icons.camera_alt,
                  ),
                  _buildButton(
                    text: "Gallery",
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icons.photo_library,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8ACA7A), Color(0xFF5CB85C)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8ACA7A).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalorieCalculator(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Open Calorie Calculator",
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
