// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   final bool scanFromGallery;

//   BarcodeScannerScreen({required this.scanFromGallery});

//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;
//   Map<String, dynamic>? _productDetails; // Store fetched details
//   final ImagePicker _imagePicker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _barcodeScanner = BarcodeScanner();

//     if (!widget.scanFromGallery) {
//       _initializeCamera();
//     } else {
//       _pickImageAndScan();
//     }
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) {
//         _showError("No available cameras found.");
//         return;
//       }

//       _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       if (!mounted) return;

//       setState(() {
//         _isCameraInitialized = true;
//       });
//     } catch (e) {
//       _showError("Camera initialization failed: $e");
//     }
//   }

//   Future<void> _captureAndScanImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       _showError("Camera is not initialized.");
//       return;
//     }

//     try {
//       XFile image = await _cameraController!.takePicture();
//       _scanBarcodeFromFile(image.path);
//     } catch (e) {
//       _showError("Error capturing image: $e");
//     }
//   }

//   Future<void> _pickImageAndScan() async {
//     try {
//       final XFile? pickedFile =
//           await _imagePicker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         _scanBarcodeFromFile(pickedFile.path);
//       }
//     } catch (e) {
//       _showError("Error selecting image: $e");
//     }
//   }

//   Future<void> _scanBarcodeFromFile(String filePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(filePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//           _productDetails = null; // Clear previous details
//         });

//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }

//       // Delete the image file after scanning
//       File(filePath).delete();
//     } catch (e) {
//       _showError("Error scanning barcode: $e");
//     }
//   }

//   Future<void> _fetchProductDetails(String barcode) async {
//     String apiUrl = "http://192.168.206.58:5050/scan_barcode";

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"barcode": barcode}),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           _productDetails = data; // Update UI with response data
//         });
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Error"),
//         content: Text(message),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Barcode Scanner")),
//       body: Column(
//         children: [
//           if (!widget.scanFromGallery)
//             Expanded(
//               flex: 4,
//               child: _isCameraInitialized
//                   ? CameraPreview(_cameraController!)
//                   : Center(child: CircularProgressIndicator()),
//             ),
//           if (_scannedBarcode != null)
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Scanned Barcode: $_scannedBarcode",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   if (_productDetails != null) ...[
//                     SizedBox(height: 10),
//                     Text(
//                         "📌 Name: ${_productDetails!['product_name'] ?? "Unknown"}",
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                     SizedBox(height: 5),
//                     Text(
//                         "📝 Ingredients: ${_productDetails!['ingredients'] ?? "Not available"}"),
//                     SizedBox(height: 5),
//                     Text(
//                         "🔥 Calories per 100g: ${_productDetails!['calories_per_100g'] ?? "Not available"}"),
//                   ],
//                 ],
//               ),
//             ),
//           if (!widget.scanFromGallery)
//             Padding(
//               padding: const EdgeInsets.all(10),
//               child: ElevatedButton(
//                 onPressed: _captureAndScanImage,
//                 child: Text("Capture & Scan"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//Krishna's With GUI with Flask
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:google_fonts/google_fonts.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   final bool scanFromGallery;

//   const BarcodeScannerScreen({super.key, required this.scanFromGallery});

//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
//     with TickerProviderStateMixin {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;
//   Map<String, dynamic>? _productDetails;
//   final ImagePicker _imagePicker = ImagePicker();

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _barcodeScanner = BarcodeScanner();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();

//     if (!widget.scanFromGallery) {
//       _initializeCamera();
//     } else {
//       _pickImageAndScan();
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _barcodeScanner.close();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) {
//         _showError("No available cameras found.");
//         return;
//       }

//       _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//       await _cameraController!.initialize();
//       if (!mounted) return;

//       setState(() {
//         _isCameraInitialized = true;
//       });
//     } catch (e) {
//       _showError("Camera initialization failed: $e");
//     }
//   }

//   Future<void> _captureAndScanImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       _showError("Camera is not initialized.");
//       return;
//     }

//     try {
//       XFile image = await _cameraController!.takePicture();
//       _scanBarcodeFromFile(image.path);
//     } catch (e) {
//       _showError("Error capturing image: $e");
//     }
//   }

//   Future<void> _pickImageAndScan() async {
//     try {
//       final XFile? pickedFile =
//           await _imagePicker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         _scanBarcodeFromFile(pickedFile.path);
//       }
//     } catch (e) {
//       _showError("Error selecting image: $e");
//     }
//   }

//   Future<void> _scanBarcodeFromFile(String filePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(filePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//           _productDetails = null;
//         });

//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }

//       File(filePath).delete();
//     } catch (e) {
//       _showError("Error scanning barcode: $e");
//     }
//   }

//   Future<void> _fetchProductDetails(String barcode) async {
//     String apiUrl = "http://10.110.6.118:5050/scan_barcode";

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"barcode": barcode}),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         setState(() {
//           _productDetails = data;
//         });
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: [
//             const Icon(Icons.error, color: Colors.red),
//             const SizedBox(width: 10),
//             Text(
//               "Error",
//               style: GoogleFonts.roboto(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           message,
//           style: GoogleFonts.roboto(color: Colors.white),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               "OK",
//               style: GoogleFonts.roboto(color: const Color(0xFF8ACA7A)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCameraPreview() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.5,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: _isCameraInitialized
//                   ? CameraPreview(_cameraController!)
//                   : Container(
//                       color: const Color(0xFF1E1E1E),
//                       child: Center(
//                         child: CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)),
//                         ),
//                       ),
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildResultCard() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Card(
//             elevation: 4,
//             color: const Color(0xFF1E1E1E),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Scanned Barcode: $_scannedBarcode",
//                     style: GoogleFonts.roboto(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF8ACA7A),
//                     ),
//                   ),
//                   if (_productDetails != null) ...[
//                     const SizedBox(height: 12),
//                     Text(
//                       "📌 Name: ${_productDetails!['product_name'] ?? "Unknown"}",
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "📝 Ingredients: ${_productDetails!['ingredients'] ?? "Not available"}",
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "🔥 Calories per 100g: ${_productDetails!['calories_per_100g'] ?? "Not available"}",
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildButton() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: Container(
//               width: 200,
//               height: 50,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF8ACA7A), Color(0xFF5CB85C)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF8ACA7A).withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: ElevatedButton(
//                 onPressed: _captureAndScanImage,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.camera, color: Colors.white, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Capture & Scan",
//                       style: GoogleFonts.roboto(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
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
//           widget.scanFromGallery ? "Scan from Gallery" : "Barcode Scanner",
//           style: GoogleFonts.roboto(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (!widget.scanFromGallery) ...[
//                 _buildCameraPreview(),
//                 const SizedBox(height: 24),
//               ],
//               if (_scannedBarcode != null) ...[
//                 _buildResultCard(),
//                 const SizedBox(height: 24),
//               ],
//               if (!widget.scanFromGallery) Center(child: _buildButton()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//works with everything
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image/image.dart' as img;
// import 'calorie_calculator.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   const BarcodeScannerScreen({super.key});

//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
//     with TickerProviderStateMixin {
//   late BarcodeScanner _barcodeScanner;
//   String _scannedBarcode = "Scanned barcode will appear here.";
//   String _productName = "Product name will appear here.";
//   String _ingredients = "Ingredients & details will appear here.";
//   String _calorieInfo = "Calorie information will appear here.";
//   final ImagePicker _imagePicker = ImagePicker();
//   File? _selectedImage;
//   bool _isProcessing = false;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   final String apiKey =
//       "AIzaSyBGEykAPgVXExWRmhROIYJIeisXudF9nfA"; // Replace with your Gemini API key
//   final String geminiEndpoint =
//       "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

//   @override
//   void initState() {
//     super.initState();
//     _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _barcodeScanner.close();
//     _animationController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       print("Picking image from $source...");
//       final XFile? pickedFile = await _imagePicker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         print("Image selected: ${pickedFile.path}");
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//           _scannedBarcode = "Processing...";
//           _productName = "";
//           _ingredients = "";
//           _calorieInfo = "";
//           _isProcessing = true;
//         });
//         _scanBarcodeFromFile(pickedFile.path);
//       } else {
//         print("No image selected.");
//       }
//     } catch (e) {
//       _showError("Error selecting image: $e");
//       print("Image pick error: $e");
//     }
//   }

//   Future<void> _scanBarcodeFromFile(String filePath) async {
//     try {
//       print("Scanning barcode from file: $filePath");

//       // Temporarily skip preprocessing to test raw image
//       final inputImage = InputImage.fromFilePath(filePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);
//       print("Barcodes detected: $barcodes");

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         print("Barcode extracted: $barcode");
//         setState(() {
//           _scannedBarcode = barcode;
//           _productDetails = null;
//           print("State updated with barcode: $_scannedBarcode");
//         });

//         _fetchProductDetails(barcode);
//       } else {
//         setState(() {
//           _scannedBarcode = "No barcode found.";
//           _productName = "No product found.";
//           _ingredients = "No ingredients available.";
//           _calorieInfo = "No calorie information available.";
//           _isProcessing = false;
//         });
//         print("No barcodes detected in image.");
//       }

//       File(filePath).delete();
//       print("File deleted: $filePath");
//     } catch (e) {
//       _showError("Error scanning barcode: $e");
//       setState(() {
//         _scannedBarcode = "Error occurred.";
//         _productName = "Error occurred.";
//         _ingredients = "Error fetching ingredients.";
//         _calorieInfo = "Error fetching calories.";
//         _isProcessing = false;
//       });
//       print("Barcode scan error: $e");
//     }
//   }

//   Map<String, dynamic>? _productDetails;

//   Future<void> _fetchProductDetails(String barcode) async {
//     print("Fetching product details for barcode: $barcode");

//     Map<String, String> productInfo =
//         await _getIngredientsFromOpenFoodFacts(barcode);

//     String productName = productInfo['product_name'] ?? "Unknown Product";
//     String ingredients = productInfo['ingredients'] ?? "";

//     if (ingredients.isEmpty && productName != "Unknown Product") {
//       final prompt = """
//         Provide a **concise and clear** breakdown of **$productName** with the following details:

//         1. **Ingredients:** List only the key ingredients in a simple, readable format. No disclaimers.
//         2. **Ingredient Components:** Mention if it contains dairy, soy, gluten, or any common allergens.
//         3. **Health Hazards:** Briefly mention potential risks (e.g., allergies, high sugar, digestive issues).
//         4. **Allergen Information:** List the allergens clearly. No need to repeat information.
//         5. **Veg/Non-Veg Status:** Simply state if the product is vegetarian or non-vegetarian.

// ⚡      **Keep it short, easy to read, and avoid unnecessary disclaimers or lengthy explanations.**
//       """;

//       ingredients =
//           await _callGeminiAPI(prompt) ?? "Error fetching ingredients.";
//     }

//     String caloriesPer100g = "Not available";
//     if (ingredients.isNotEmpty && !ingredients.startsWith("Error")) {
//       final caloriePrompt = """
//         Provide the calorie content per 100g for the following ingredients in **$productName**:

//         **Ingredients:** $ingredients

//         **Response format:**
//         - **Ingredient Name:** Calories per 100g (e.g., Sugar: 387 kcal)
//         - If an ingredient has **0 kcal**, mention it explicitly.
//         - If exact calorie info is unavailable, state: "Check product label for accurate values."

//         ⚡ Keep it **short, structured, and readable.** No unnecessary disclaimers.
//       """;

//       caloriesPer100g =
//           await _callGeminiAPI(caloriePrompt) ?? "Error fetching calorie info.";
//     }

//     setState(() {
//       _productDetails = {
//         "product_name": productName,
//         "ingredients": ingredients,
//         "calories_per_100g": caloriesPer100g,
//       };
//       _productName = productName;
//       _ingredients = _formatText(ingredients);
//       _calorieInfo = _formatText(caloriesPer100g);
//       _isProcessing = false;
//       print("State updated with product details: $_productDetails");
//     });
//   }

//   Future<Map<String, String>> _getIngredientsFromOpenFoodFacts(
//       String barcode) async {
//     final url = "https://world.openfoodfacts.org/api/v0/product/$barcode.json";
//     try {
//       final response =
//           await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
//       if (response.statusCode == 200) {
//         final productData = jsonDecode(response.body);
//         if (productData['status'] == 1) {
//           return {
//             "product_name":
//                 productData['product']['product_name'] ?? "Unknown Product",
//             "ingredients": productData['product']['ingredients_text'] ?? "",
//           };
//         } else {
//           print("Product not found in Open Food Facts: $barcode");
//           return {"product_name": "Unknown Product", "ingredients": ""};
//         }
//       } else {
//         print("Open Food Facts API error: ${response.statusCode}");
//         return {"product_name": "Unknown Product", "ingredients": ""};
//       }
//     } catch (e) {
//       print("Error fetching from Open Food Facts: $e");
//       _showError("Error fetching from Open Food Facts: $e");
//       return {"product_name": "Error", "ingredients": "Error"};
//     }
//   }

//   Future<String?> _callGeminiAPI(String prompt) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse("$geminiEndpoint?key=$apiKey"),
//             headers: {"Content-Type": "application/json"},
//             body: jsonEncode({
//               "contents": [
//                 {
//                   "parts": [
//                     {"text": prompt}
//                   ]
//                 }
//               ]
//             }),
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         return data['candidates'][0]['content']['parts'][0]['text'];
//       } else {
//         print("Gemini API error: ${response.statusCode}");
//         _showError("Gemini API error: ${response.statusCode}");
//         return null;
//       }
//     } catch (e) {
//       print("Error fetching from Gemini API: $e");
//       _showError("Error fetching from Gemini API: $e");
//       return null;
//     }
//   }

//   String _formatText(String text) {
//     return text.replaceAll('\n', '\n\n').trim();
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: [
//             const Icon(Icons.error, color: Colors.red),
//             const SizedBox(width: 10),
//             Text("Error",
//                 style: GoogleFonts.roboto(
//                     color: Colors.white, fontWeight: FontWeight.bold)),
//           ],
//         ),
//         content: Text(message, style: GoogleFonts.roboto(color: Colors.white)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK",
//                 style: GoogleFonts.roboto(color: const Color(0xFF8ACA7A))),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImageDisplay() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Container(
//             height: 200,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: _selectedImage != null
//                   ? Image.file(_selectedImage!, fit: BoxFit.cover)
//                   : Container(
//                       color: const Color(0xFF1E1E1E),
//                       child:
//                           Icon(Icons.image, size: 100, color: Colors.grey[400]),
//                     ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTextCard(String title, String content) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: Card(
//             elevation: 4,
//             color: const Color(0xFF1E1E1E),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: GoogleFonts.roboto(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF8ACA7A))),
//                   const SizedBox(height: 8),
//                   Text(content,
//                       style: GoogleFonts.roboto(
//                           fontSize: 16, color: Colors.white)),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildIconButton(
//       {required IconData icon, required VoidCallback onPressed}) {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
//           child: Opacity(
//             opacity: _fadeAnimation.value,
//             child: GestureDetector(
//               onTap: onPressed,
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF8ACA7A), Color(0xFF5CB85C)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF8ACA7A).withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 3),
//                     )
//                   ],
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 32),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: Text("Barcode Scanner",
//             style: GoogleFonts.roboto(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white)),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildImageDisplay(),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildIconButton(
//                     icon: Icons.camera_alt,
//                     onPressed: () => _pickImage(ImageSource.camera),
//                   ),
//                   _buildIconButton(
//                     icon: Icons.photo_library,
//                     onPressed: () => _pickImage(ImageSource.gallery),
//                   ),
//                   _buildIconButton(
//                     icon: Icons.calculate,
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CalorieCalculator()),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               if (_isProcessing) ...[
//                 Center(
//                     child: CircularProgressIndicator(
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)))),
//                 const SizedBox(height: 24),
//               ],
//               _buildTextCard("🔍 Scanned Barcode", _scannedBarcode),
//               const SizedBox(height: 16),
//               _buildTextCard("📌 Product Name", _productName),
//               const SizedBox(height: 16),
//               _buildTextCard("📝 Ingredients & Details", _ingredients),
//               const SizedBox(height: 16),
//               _buildTextCard("🔥 Calories per 100g", _calorieInfo),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late BarcodeScanner _barcodeScanner;
  String _scannedBarcode = "Scanned barcode will appear here.";
  String _productName = "Product name will appear here.";
  String _ingredients = "Ingredients & details will appear here.";
  String _calorieInfo = "Calorie information will appear here.";
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;

  final String apiKey =
      "AIzaSyBGEykAPgVXExWRmhROIYJIeisXudF9nfA"; // Replace with your Gemini API key
  final String geminiEndpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent";

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print("Picking image from $source...");
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        print("Image selected: ${pickedFile.path}");
        setState(() {
          _selectedImage = File(pickedFile.path);
          _scannedBarcode = "Processing...";
          _productName = "Processing...";
          _ingredients = "Processing...";
          _calorieInfo = "Processing...";
          _isProcessing = true;
        });
        _scanBarcodeFromFile(pickedFile.path);
      } else {
        print("No image selected.");
      }
    } catch (e) {
      _showError("Error selecting image: $e");
      print("Image pick error: $e");
    }
  }

  Future<void> _scanBarcodeFromFile(String filePath) async {
    try {
      print("Scanning barcode from file: $filePath");
      final inputImage = InputImage.fromFilePath(filePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      print("Barcodes detected: $barcodes");

      if (barcodes.isNotEmpty) {
        String barcode = barcodes.first.rawValue ?? "Unknown";
        print("Barcode extracted: $barcode");
        setState(() {
          _scannedBarcode = barcode;
          _productDetails = null;
          print("State updated with barcode: $_scannedBarcode");
        });

        _fetchProductDetails(barcode);
      } else {
        setState(() {
          _scannedBarcode = "No barcode found.";
          _productName = "No product found.";
          _ingredients = "No ingredients available.";
          _calorieInfo = "No calorie information available.";
          _isProcessing = false;
        });
        print("No barcodes detected in image.");
      }

      File(filePath).delete();
      print("File deleted: $filePath");
    } catch (e) {
      _showError("Error scanning barcode: $e");
      setState(() {
        _scannedBarcode = "Error occurred.";
        _productName = "Error occurred.";
        _ingredients = "Error fetching ingredients.";
        _calorieInfo = "Error fetching calories.";
        _isProcessing = false;
      });
      print("Barcode scan error: $e");
    }
  }

  Map<String, dynamic>? _productDetails;

  Future<void> _fetchProductDetails(String barcode) async {
    print("Fetching product details for barcode: $barcode");

    Map<String, String> productInfo =
        await _getIngredientsFromOpenFoodFacts(barcode);

    String productName = productInfo['product_name'] ?? "Unknown Product";
    String ingredients = productInfo['ingredients'] ?? "";

    if (ingredients.isEmpty && productName != "Unknown Product") {
      final prompt = """
        Provide a **concise and clear** breakdown of **$productName** with the following details:

        1. **Ingredients:** List only the key ingredients in a simple, readable format. No disclaimers.  
        2. **Ingredient Components:** Mention if it contains dairy, soy, gluten, or any common allergens.  
        3. **Health Hazards:** Briefly mention potential risks (e.g., allergies, high sugar, digestive issues).  
        4. **Allergen Information:** List the allergens clearly. No need to repeat information.  
        5. **Veg/Non-Veg Status:** Simply state if the product is vegetarian or non-vegetarian.  

        **Keep it short, easy to read, and avoid unnecessary disclaimers or lengthy explanations.**  
      """;

      ingredients =
          await _callGeminiAPI(prompt) ?? "Error fetching ingredients.";
    }

    String caloriesPer100g = "Not available";
    if (ingredients.isNotEmpty && !ingredients.startsWith("Error")) {
      final caloriePrompt = """
        Provide the calorie content per 100g for the following ingredients in **$productName**:  

        **Ingredients:** $ingredients  

        **Response format:**  
        - **Ingredient Name:** Calories per 100g (e.g., Sugar: 387 kcal)  
        - If an ingredient has **0 kcal**, mention it explicitly.  
        - If exact calorie info is unavailable, state: "Check product label for accurate values."  

        ⚡ Keep it **short, structured, and readable.** No unnecessary disclaimers.
      """;

      caloriesPer100g =
          await _callGeminiAPI(caloriePrompt) ?? "Error fetching calorie info.";
    }

    setState(() {
      _productDetails = {
        "product_name": productName,
        "ingredients": ingredients,
        "calories_per_100g": caloriesPer100g,
      };
      _productName = productName;
      _ingredients = _formatText(ingredients);
      _calorieInfo = _formatText1(caloriesPer100g);
      _isProcessing = false;
      print("State updated with product details: $_productDetails");
    });
  }

  Future<Map<String, String>> _getIngredientsFromOpenFoodFacts(
      String barcode) async {
    final url = "https://world.openfoodfacts.org/api/v0/product/$barcode.json";
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
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
            headers: {"Content-Type": "application/json"},
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
          .timeout(const Duration(seconds: 30));

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
    return text.replaceAll('\n', '\n').trim();
  }

  String _formatText1(String text) {
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

  List<TextSpan> _formatTextWithBold(String text) {
    List<TextSpan> spans = [];

    // Check if the text contains ** markers
    if (text.contains('**')) {
      // Handle text with ** markers (e.g., Ingredients & Details)
      List<String> parts = text.split('**');
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) continue;
        spans.add(TextSpan(
          text: parts[i],
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
            fontWeight: i % 2 == 1 ? FontWeight.bold : FontWeight.normal,
          ),
        ));
      }
    } else {
      // Handle calorie-like format without ** markers (e.g., Calories per 100g)
      List<String> lines = text.split('\n');
      for (String line in lines) {
        if (line.trim().startsWith('- ')) {
          final parts = line.trim().substring(2).split(':');
          if (parts.length >= 2) {
            spans.add(TextSpan(
              text: '- ${parts[0]}:',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ));
            spans.add(TextSpan(
              text: '${parts.sublist(1).join(':').trim()}\n',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
                fontWeight: FontWeight.normal,
              ),
            ));
          } else {
            spans.add(TextSpan(
              text: '$line\n',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
                fontWeight: FontWeight.normal,
              ),
            ));
          }
        } else {
          spans.add(TextSpan(
            text: '$line\n',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
              fontWeight: FontWeight.normal,
            ),
          ));
        }
      }
    }

    return spans;
  }

  Widget _buildImageDisplay() {
    return Container(
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
                child: Icon(Icons.image, size: 100, color: Colors.grey[400]),
              ),
      ),
    );
  }

  Widget _buildTextCard(String title, String content) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB4EC51), Color(0xFF9BEC00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (title.contains("Ingredients") || title.contains("Calories"))
            RichText(
              text: TextSpan(
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: _formatTextWithBold(content),
              ),
            )
          else
            Text(
              content,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFB4EC51), Color(0xFF9BEC00)],
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
        child: Icon(icon,
            color: const Color(0xFF1E1E1E),
            size: 32), // Changed color to dark gray
      ),
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
          "Barcode Scanner",
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
                        AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)),
                  ),
                ),
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
