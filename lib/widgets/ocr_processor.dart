import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'calorie_calculator.dart'; // Import the CalorieCalculator screen

class OCRProcessor extends StatefulWidget {
  @override
  _OCRProcessorState createState() => _OCRProcessorState();
}

class _OCRProcessorState extends State<OCRProcessor> {
  final TextRecognizer textRecognizer = TextRecognizer();
  final String apiUrl =
      "http://192.168.0.113:5050/process_text"; // Flask server
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

  /// **Pick Image from Camera or Gallery**
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

      // Extract text using OCR (Runs on the main thread)
      String extractedText = await _extractText(_selectedImage!);
      setState(() {
        _extractedText = extractedText;
      });

      // Send text to Flask API
      Map<String, dynamic> apiResponse = await _sendTextToAPI(extractedText);
      setState(() {
        _normalIngredients = apiResponse["details"] ?? "No details found";
        _calorieInfo =
            apiResponse["calories_per_100g"] ?? "No calorie info available";
        _isProcessing = false;
      });
    }
  }

  /// **Extract Text using OCR (Runs on the main thread)**
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

  /// **Send Extracted Text to Flask API using Dio**
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

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OCR & Calorie Info")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Icon(Icons.image, size: 200),
            SizedBox(height: 20),

            if (_isProcessing) ...[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
            ],

            // **Extracted Text**
            Text("🔹 Extracted Text:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_extractedText, textAlign: TextAlign.center),
            Divider(),

            // **Ingredients & Details**
            Text("📝 Ingredients & Details:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_normalIngredients, textAlign: TextAlign.center),
            Divider(),

            // **Calories per 100g**
            Text("🔥 Calories per 100g:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_calorieInfo, textAlign: TextAlign.center),
            SizedBox(height: 20),

            // **Pick Image Buttons**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera),
                  label: Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.folder),
                  label: Text('Gallery'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // **Navigate to Calorie Calculator**
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalorieCalculator()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Open Calorie Calculator"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
