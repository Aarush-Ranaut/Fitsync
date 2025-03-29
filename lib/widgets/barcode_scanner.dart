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

//Krishna's Wuith GUI
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final bool scanFromGallery;

  const BarcodeScannerScreen({super.key, required this.scanFromGallery});

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isCameraInitialized = false;
  String? _scannedBarcode;
  Map<String, dynamic>? _productDetails;
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    if (!widget.scanFromGallery) {
      _initializeCamera();
    } else {
      _pickImageAndScan();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
    _animationController.dispose();
    super.dispose();
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
          _productDetails = null;
        });

        _fetchProductDetails(barcode);
      } else {
        _showError("No barcode found. Try again.");
      }

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
          _productDetails = data;
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
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 10),
            Text(
              "Error",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.roboto(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.roboto(color: const Color(0xFF8ACA7A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
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
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: const Color(0xFF1E1E1E),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF8ACA7A)),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
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
                    "Scanned Barcode: $_scannedBarcode",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8ACA7A),
                    ),
                  ),
                  if (_productDetails != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      "📌 Name: ${_productDetails!['product_name'] ?? "Unknown"}",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "📝 Ingredients: ${_productDetails!['ingredients'] ?? "Not available"}",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "🔥 Calories per 100g: ${_productDetails!['calories_per_100g'] ?? "Not available"}",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 200,
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
                onPressed: _captureAndScanImage,
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
                    const Icon(Icons.camera, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Capture & Scan",
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
          widget.scanFromGallery ? "Scan from Gallery" : "Barcode Scanner",
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
              if (!widget.scanFromGallery) ...[
                _buildCameraPreview(),
                const SizedBox(height: 24),
              ],
              if (_scannedBarcode != null) ...[
                _buildResultCard(),
                const SizedBox(height: 24),
              ],
              if (!widget.scanFromGallery) Center(child: _buildButton()),
            ],
          ),
        ),
      ),
    );
  }
}
