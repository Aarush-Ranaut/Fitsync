// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;

// class BarcodeScannerScreen extends StatefulWidget {
//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _barcodeScanner = BarcodeScanner();
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

//   /// Captures an image and processes it for barcode scanning
//   Future<void> _captureAndScanImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       _showError("Camera is not initialized.");
//       return;
//     }

//     try {
//       XFile image = await _cameraController!.takePicture();
//       final inputImage = InputImage.fromFilePath(image.path);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//         });
//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }
//     } catch (e) {
//       _showError("Error scanning barcode: $e");
//     }
//   }

//   Future<void> _fetchProductDetails(String barcode) async {
//     String apiUrl = "http://192.168.0.105:5050/scan_barcode";

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"barcode": barcode}),
//       );

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         _showProductDetails(data);
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   void _showProductDetails(Map<String, dynamic> data) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Product Details"),
//         content: Text(
//             "Name: ${data['product_name']}\nIngredients: ${data['ingredients']}"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
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
//           Expanded(
//             flex: 4,
//             child: _isCameraInitialized
//                 ? CameraPreview(_cameraController!)
//                 : Center(child: CircularProgressIndicator()),
//           ),
//           if (_scannedBarcode != null)
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Text("Scanned Barcode: $_scannedBarcode",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: ElevatedButton(
//               onPressed: _captureAndScanImage,
//               child: Text("Capture & Scan"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//ONE WITH CALORIES PRINTING
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;

// class BarcodeScannerScreen extends StatefulWidget {
//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _barcodeScanner = BarcodeScanner();
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

//   /// Captures an image and processes it for barcode scanning
//   Future<void> _captureAndScanImage() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       _showError("Camera is not initialized.");
//       return;
//     }

//     try {
//       XFile image = await _cameraController!.takePicture();
//       final inputImage = InputImage.fromFilePath(image.path);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//         });
//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }
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
//         _showProductDetails(data);
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   void _showProductDetails(Map<String, dynamic> data) {
//     String productName = data['product_name'] ?? "Unknown";
//     String ingredients = data['ingredients'] ?? "Not available";
//     String calories = data['calories_per_100g'] ?? "Not available";

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Product Details"),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("📌 Name: $productName",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text("📝 Ingredients:\n$ingredients"),
//               SizedBox(height: 8),
//               Text("🔥 Calories per 100g:\n$calories"),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
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
//           Expanded(
//             flex: 4,
//             child: _isCameraInitialized
//                 ? CameraPreview(_cameraController!)
//                 : Center(child: CircularProgressIndicator()),
//           ),
//           if (_scannedBarcode != null)
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Text("Scanned Barcode: $_scannedBarcode",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: ElevatedButton(
//               onPressed: _captureAndScanImage,
//               child: Text("Capture & Scan"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//camera and image picker
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;
//   final ImagePicker _imagePicker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _barcodeScanner = BarcodeScanner();
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

//   /// Captures an image from the camera and processes it for barcode scanning
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

//   /// Selects an image from the gallery and processes it for barcode scanning
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

//   /// Processes the given image file for barcode scanning
//   Future<void> _scanBarcodeFromFile(String filePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(filePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//         });
//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }
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
//         _showProductDetails(data);
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       _showError("Error: $e");
//     }
//   }

//   void _showProductDetails(Map<String, dynamic> data) {
//     String productName = data['product_name'] ?? "Unknown";
//     String ingredients = data['ingredients'] ?? "Not available";
//     String calories = data['calories_per_100g'] ?? "Not available";

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Product Details"),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("📌 Name: $productName",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text("📝 Ingredients:\n$ingredients"),
//               SizedBox(height: 8),
//               Text("🔥 Calories per 100g:\n$calories"),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
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
//           Expanded(
//             flex: 4,
//             child: _isCameraInitialized
//                 ? CameraPreview(_cameraController!)
//                 : Center(child: CircularProgressIndicator()),
//           ),
//           if (_scannedBarcode != null)
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Text("Scanned Barcode: $_scannedBarcode",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _captureAndScanImage,
//                   child: Text("Capture & Scan"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _pickImageAndScan,
//                   child: Text("Pick from Gallery"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//camera and image picker
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';

// class BarcodeScannerScreen extends StatefulWidget {
//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   CameraController? _cameraController;
//   late BarcodeScanner _barcodeScanner;
//   bool _isCameraInitialized = false;
//   String? _scannedBarcode;
//   final ImagePicker _imagePicker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _barcodeScanner = BarcodeScanner();
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

//   /// Captures an image from the camera and processes it for barcode scanning
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

//   /// Selects an image from the gallery and processes it for barcode scanning
//   Future<void> _pickImageAndScan() async {
//     try {
//       final XFile? pickedFile =
//           await _imagePicker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);

//         // Load and resize image
//         List<int> imageBytes = await imageFile.readAsBytes();
//         img.Image? originalImage = img.decodeImage(imageBytes);

//         if (originalImage != null) {
//           img.Image resizedImage =
//               img.copyResize(originalImage, width: 600); // Reduce size
//           File compressedFile = File(pickedFile.path)
//             ..writeAsBytesSync(
//                 img.encodeJpg(resizedImage, quality: 85)); // Reduce quality
//           _scanBarcodeFromFile(compressedFile.path);
//         } else {
//           _showError("Failed to process image.");
//         }
//       }
//     } catch (e) {
//       _showError("Error selecting image: $e");
//     }
//   }

//   /// Processes the given image file for barcode scanning
//   Future<void> _scanBarcodeFromFile(String filePath) async {
//     try {
//       final inputImage = InputImage.fromFilePath(filePath);
//       final barcodes = await _barcodeScanner.processImage(inputImage);

//       if (barcodes.isNotEmpty) {
//         String barcode = barcodes.first.rawValue ?? "Unknown";
//         setState(() {
//           _scannedBarcode = barcode;
//         });
//         _fetchProductDetails(barcode);
//       } else {
//         _showError("No barcode found. Try again.");
//       }
//     } catch (e) {
//       _showError("Error scanning barcode: $e");
//     }
//   }

//   Future<void> _fetchProductDetails(String barcode) async {
//     String apiUrl = "http://10.110.6.118:5050/scan_barcode";

//     // Show loading dialog
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent closing by tapping outside
//       builder: (_) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 10),
//             Text("Fetching product details..."),
//           ],
//         ),
//       ),
//     );

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"barcode": barcode}),
//       );

//       Navigator.pop(context); // Dismiss loading dialog

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         _showProductDetails(data);
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       Navigator.pop(context); // Dismiss loading dialog in case of error
//       _showError("Error: $e");
//     }
//   }

//   void _showProductDetails(Map<String, dynamic> data) {
//     String productName = data['product_name'] ?? "Unknown";
//     String ingredients = data['ingredients'] ?? "Not available";
//     String calories = data['calories_per_100g'] ?? "Not available";

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Product Details"),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("📌 Name: $productName",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text("📝 Ingredients:\n$ingredients"),
//               SizedBox(height: 8),
//               Text("🔥 Calories per 100g:\n$calories"),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
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
//           Expanded(
//             flex: 4,
//             child: _isCameraInitialized
//                 ? CameraPreview(_cameraController!)
//                 : Center(child: CircularProgressIndicator()),
//           ),
//           if (_scannedBarcode != null)
//             Padding(
//               padding: EdgeInsets.all(10),
//               child: Text("Scanned Barcode: $_scannedBarcode",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: _captureAndScanImage,
//                   child: Text("Capture & Scan"),
//                 ),
//                 ElevatedButton(
//                   onPressed: _pickImageAndScan,
//                   child: Text("Pick from Gallery"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//Latest separtley working
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
//     String apiUrl = "http://10.110.6.118:5050/scan_barcode";

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 10),
//             Text("Fetching product details..."),
//           ],
//         ),
//       ),
//     );

//     try {
//       var response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"barcode": barcode}),
//       );

//       Navigator.pop(context);

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         _showProductDetails(data);
//       } else {
//         _showError("Failed to fetch details. Try again.");
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       _showError("Error: $e");
//     }
//   }

//   void _showProductDetails(Map<String, dynamic> data) {
//     String productName = data['product_name'] ?? "Unknown";
//     String ingredients = data['ingredients'] ?? "Not available";
//     String calories = data['calories_per_100g'] ?? "Not available";

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Product Details"),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("📌 Name: $productName",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(height: 8),
//               Text("📝 Ingredients:\n$ingredients"),
//               SizedBox(height: 8),
//               Text("🔥 Calories per 100g:\n$calories"),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
//         ],
//       ),
//     );
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
//               child: Text("Scanned Barcode: $_scannedBarcode",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final bool scanFromGallery;

  BarcodeScannerScreen({required this.scanFromGallery});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  CameraController? _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isCameraInitialized = false;
  String? _scannedBarcode;
  Map<String, dynamic>? _productDetails; // Store fetched details
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();

    if (!widget.scanFromGallery) {
      _initializeCamera();
    } else {
      _pickImageAndScan();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError("No available cameras found.");
        return;
      }

      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      _showError("Camera initialization failed: $e");
    }
  }

  Future<void> _captureAndScanImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError("Camera is not initialized.");
      return;
    }

    try {
      XFile image = await _cameraController!.takePicture();
      _scanBarcodeFromFile(image.path);
    } catch (e) {
      _showError("Error capturing image: $e");
    }
  }

  Future<void> _pickImageAndScan() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _scanBarcodeFromFile(pickedFile.path);
      }
    } catch (e) {
      _showError("Error selecting image: $e");
    }
  }

  Future<void> _scanBarcodeFromFile(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        String barcode = barcodes.first.rawValue ?? "Unknown";
        setState(() {
          _scannedBarcode = barcode;
          _productDetails = null; // Clear previous details
        });

        _fetchProductDetails(barcode);
      } else {
        _showError("No barcode found. Try again.");
      }

      // Delete the image file after scanning
      File(filePath).delete();
    } catch (e) {
      _showError("Error scanning barcode: $e");
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    String apiUrl = "http://10.110.6.118:5050/scan_barcode";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"barcode": barcode}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _productDetails = data; // Update UI with response data
        });
      } else {
        _showError("Failed to fetch details. Try again.");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Barcode Scanner")),
      body: Column(
        children: [
          if (!widget.scanFromGallery)
            Expanded(
              flex: 4,
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: CircularProgressIndicator()),
            ),
          if (_scannedBarcode != null)
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Scanned Barcode: $_scannedBarcode",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_productDetails != null) ...[
                    SizedBox(height: 10),
                    Text(
                        "📌 Name: ${_productDetails!['product_name'] ?? "Unknown"}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text(
                        "📝 Ingredients: ${_productDetails!['ingredients'] ?? "Not available"}"),
                    SizedBox(height: 5),
                    Text(
                        "🔥 Calories per 100g: ${_productDetails!['calories_per_100g'] ?? "Not available"}"),
                  ],
                ],
              ),
            ),
          if (!widget.scanFromGallery)
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _captureAndScanImage,
                child: Text("Capture & Scan"),
              ),
            ),
        ],
      ),
    );
  }
}
