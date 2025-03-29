// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'barcode_scanner.dart';

// class BarcodeScannerChoiceScreen extends StatelessWidget {
//   const BarcodeScannerChoiceScreen({super.key});

//   Widget _buildButton({
//     required BuildContext context,
//     required String text,
//     required VoidCallback onPressed,
//     required IconData icon,
//   }) {
//     return Container(
//       width: 250,
//       height: 60,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF8ACA7A), Color(0xFF5CB85C)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF8ACA7A).withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: Colors.white, size: 24),
//             const SizedBox(width: 12),
//             Text(
//               text,
//               style: GoogleFonts.roboto(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: Text(
//           "Choose Scan Method",
//           style: GoogleFonts.roboto(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Title with animation
//             TweenAnimationBuilder(
//               tween: Tween<double>(begin: 0, end: 1),
//               duration: const Duration(milliseconds: 800),
//               builder: (context, opacity, child) {
//                 return Opacity(
//                   opacity: opacity,
//                   child: Text(
//                     "Select Your Scanning Option",
//                     style: GoogleFonts.roboto(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF8ACA7A),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 40),
//             // Camera Button
//             TweenAnimationBuilder(
//               tween: Tween<double>(begin: 0, end: 1),
//               duration: const Duration(milliseconds: 1000),
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: _buildButton(
//                       context: context,
//                       text: "Scan Using Camera",
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 BarcodeScannerScreen(scanFromGallery: false),
//                           ),
//                         );
//                       },
//                       icon: Icons.camera_alt,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             // Gallery Button
//             TweenAnimationBuilder(
//               tween: Tween<double>(begin: 0, end: 1),
//               duration: const Duration(milliseconds: 1000),
//               curve: Curves.easeInOut,
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: _buildButton(
//                       context: context,
//                       text: "Scan From Gallery",
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 BarcodeScannerScreen(scanFromGallery: true),
//                           ),
//                         );
//                       },
//                       icon: Icons.photo_library,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For RootIsolateToken
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calorie_calculator.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with TickerProviderStateMixin {
  late BarcodeScanner _barcodeScanner;
  String _scannedBarcode = "Scanned barcode will appear here.";
  String _productName = "Product name will appear here.";
  String _ingredients = "Ingredients & details will appear here.";
  String _calorieInfo = "Calorie information will appear here.";
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;

  final String apiKey = "AIzaSyBGEykAPgVXExWRmhROIYJIeisXudF9nfA";
  final String geminiEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

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
    _barcodeScanner.close();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      _selectedImage = File(image.path);
      _scannedBarcode = "Processing...";
      _productName = "";
      _ingredients = "";
      _calorieInfo = "";
      _isProcessing = true;
    });

    try {
      print("Starting barcode scan for image: ${image.path}");
      String barcode = await _scanBarcodeFromFile(image.path);
      print("Barcode scan completed: $barcode");
      if (barcode.isNotEmpty) {
        setState(() => _scannedBarcode = barcode);
        await _fetchProductDetails(barcode);
      } else {
        setState(() {
          _scannedBarcode = "No barcode detected.";
          _productName = "No product found.";
          _ingredients = "No ingredients available.";
          _calorieInfo = "No calorie information available.";
        });
      }
    } catch (e) {
      _showError("Error during processing: $e");
      setState(() {
        _scannedBarcode = "Error occurred.";
        _productName = "Error occurred.";
        _ingredients = "Error fetching ingredients.";
        _calorieInfo = "Error fetching calories.";
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
      File(image.path).delete();
    }
  }

  Future<String> _scanBarcodeFromFile(String filePath) async {
    print("Preparing to scan barcode from file: $filePath");
    final ReceivePort receivePort = ReceivePort();
    // Get the root isolate token from the main isolate
    final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      _showError("RootIsolateToken is null, cannot initialize isolate.");
      return "";
    }

    await Isolate.spawn(
      _barcodeScanIsolate,
      [filePath, receivePort.sendPort, rootIsolateToken],
    );

    final result = await receivePort.first.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        print("Barcode scanning timed out after 10 seconds");
        return "Timeout: Barcode scanning took too long";
      },
    );

    receivePort.close();
    if (result is String) {
      if (result.startsWith("Error") || result.startsWith("Timeout")) {
        _showError(result);
        return "";
      }
      return result;
    }
    return "";
  }

  static void _barcodeScanIsolate(List<dynamic> args) {
    final String filePath = args[0];
    final SendPort sendPort = args[1];
    final RootIsolateToken rootIsolateToken = args[2];

    // Initialize the binary messenger in the isolate
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    final inputImage = InputImage.fromFilePath(filePath);

    print("Isolate: Starting barcode processing");
    barcodeScanner.processImage(inputImage).then((barcodes) {
      print("Isolate: Barcodes detected: $barcodes");
      String barcodeResult =
          barcodes.isNotEmpty ? barcodes.first.rawValue ?? "Unknown" : "";
      sendPort.send(barcodeResult);
    }).catchError((e) {
      print("Isolate: Error scanning barcode: $e");
      sendPort.send("Error: $e");
    }).whenComplete(() {
      barcodeScanner.close();
    });
  }

  Future<void> _fetchProductDetails(String barcode) async {
    print("Fetching product details for barcode: $barcode");
    Map<String, String> productInfo =
        await _getIngredientsFromOpenFoodFacts(barcode);

    String productName = productInfo['product_name'] ?? "Unknown Product";
    String ingredients = productInfo['ingredients'] ?? "";

    if (ingredients.isEmpty && productName != "Unknown Product") {
      final prompt =
          "List the ingredients, ingredient components, health hazards, allergen information, "
          "and whether it is veg or non-veg for $productName. Do not provide any extra information.";
      ingredients =
          await _callGeminiAPI(prompt) ?? "Error fetching ingredients.";
    }

    String calorieInfo = "Not available";
    if (ingredients.isNotEmpty && !ingredients.startsWith("Error")) {
      final caloriePrompt =
          "Provide the calorie content per 100 grams for each of the following ingredients. "
          "If an ingredient does not contribute calories, state '0 kcal'. "
          "Format the response as:\nIngredient: Calories per 100g\n"
          "Ingredients: $ingredients";
      calorieInfo =
          await _callGeminiAPI(caloriePrompt) ?? "Error fetching calorie info.";
    }

    setState(() {
      _productName = productName;
      _ingredients = _formatText(ingredients);
      _calorieInfo = _formatText(calorieInfo);
    });
  }

  Future<Map<String, String>> _getIngredientsFromOpenFoodFacts(
      String barcode) async {
    final url = "https://world.openfoodfacts.org/api/v0/product/$barcode.json";
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        if (productData['status'] == 1) {
          return {
            "product_name":
                productData['product']['product_name'] ?? "Unknown Product",
            "ingredients": productData['product']['ingredients_text'] ?? "",
          };
        } else {
          print("Product not found in Open Food Facts: $barcode");
          return {"product_name": "Unknown Product", "ingredients": ""};
        }
      } else {
        print("Open Food Facts API error: ${response.statusCode}");
        return {"product_name": "Unknown Product", "ingredients": ""};
      }
    } catch (e) {
      print("Error fetching from Open Food Facts: $e");
      _showError("Error fetching from Open Food Facts: $e");
      return {"product_name": "Error", "ingredients": "Error"};
    }
  }

  Future<String?> _callGeminiAPI(String prompt) async {
    try {
      final response = await http
          .post(
            Uri.parse("$geminiEndpoint?key=$apiKey"),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt}
                  ]
                }
              ]
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print("Gemini API error: ${response.statusCode}");
        _showError("Gemini API error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching from Gemini API: $e");
      _showError("Error fetching from Gemini API: $e");
      return null;
    }
  }

  String _formatText(String text) {
    return text.replaceAll('\n', '\n\n').trim();
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Text("Error",
                style: GoogleFonts.roboto(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: GoogleFonts.roboto(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK",
                style: GoogleFonts.roboto(color: const Color(0xFF8ACA7A))),
          ),
        ],
      ),
    );
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
                      child:
                          Icon(Icons.image, size: 100, color: Colors.grey[400]),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8ACA7A))),
                  const SizedBox(height: 8),
                  Text(content,
                      style: GoogleFonts.roboto(
                          fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                    )
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
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
        title: Text("Barcode Scanner",
            style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconButton(
                    icon: Icons.camera_alt,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  _buildIconButton(
                    icon: Icons.photo_library,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  _buildIconButton(
                    icon: Icons.calculate,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalorieCalculator()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isProcessing) ...[
                Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)))),
                const SizedBox(height: 24),
              ],
              _buildTextCard("🔍 Scanned Barcode", _scannedBarcode),
              const SizedBox(height: 16),
              _buildTextCard("📌 Product Name", _productName),
              const SizedBox(height: 16),
              _buildTextCard("📝 Ingredients & Details", _ingredients),
              const SizedBox(height: 16),
              _buildTextCard("🔥 Calories per 100g", _calorieInfo),
            ],
          ),
        ),
      ),
    );
  }
}
