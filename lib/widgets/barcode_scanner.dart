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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  CameraController? _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isCameraInitialized = false;
  String? _scannedBarcode;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _barcodeScanner = BarcodeScanner();
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

  /// Captures an image and processes it for barcode scanning
  Future<void> _captureAndScanImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError("Camera is not initialized.");
      return;
    }

    try {
      XFile image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        String barcode = barcodes.first.rawValue ?? "Unknown";
        setState(() {
          _scannedBarcode = barcode;
        });
        _fetchProductDetails(barcode);
      } else {
        _showError("No barcode found. Try again.");
      }
    } catch (e) {
      _showError("Error scanning barcode: $e");
    }
  }

  Future<void> _fetchProductDetails(String barcode) async {
    String apiUrl = "http://192.168.0.113:5050/scan_barcode";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"barcode": barcode}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        _showProductDetails(data);
      } else {
        _showError("Failed to fetch details. Try again.");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _showProductDetails(Map<String, dynamic> data) {
    String productName = data['product_name'] ?? "Unknown";
    String ingredients = data['ingredients'] ?? "Not available";
    String calories = data['calories_per_100g'] ?? "Not available";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Product Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📌 Name: $productName",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("📝 Ingredients:\n$ingredients"),
              SizedBox(height: 8),
              Text("🔥 Calories per 100g:\n$calories"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
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
          Expanded(
            flex: 4,
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          if (_scannedBarcode != null)
            Padding(
              padding: EdgeInsets.all(10),
              child: Text("Scanned Barcode: $_scannedBarcode",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
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
