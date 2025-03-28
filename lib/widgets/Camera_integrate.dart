//LOADING MODEL FIRST THEN CALLING + OPTIMIZED + multiple exrercises + global variable for ip + Dynamic API + Manual Exposure
// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:dio/dio.dart';

// class PoseScreen extends StatefulWidget {
//   final int exercise;
//   PoseScreen({required this.exercise});

//   @override
//   _PoseScreenState createState() => _PoseScreenState();
// }

// class _PoseScreenState extends State<PoseScreen> {
//   CameraController? _cameraController;
//   List<CameraDescription>? cameras;
//   bool isProcessing = false;
//   String apiResponse = "Waiting for pose analysis...";
//   bool isCameraEnabled = false;
//   Timer? captureTimer;
//   final int captureInterval = 2;
//   final Dio dio = Dio();
//   bool isModelLoaded = false;
//   double _exposure = 0.0;
//   double _minExposure = -2.0; // Set to detected min value
//   double _maxExposure = 2.0; // Set to detected max value

//   // ✅ Define server IP address
//   final String serverIP = "http://10.110.12.209:5050";

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras != null && cameras!.isNotEmpty) {
//         _cameraController = CameraController(
//           cameras![0],
//           ResolutionPreset.high,
//           enableAudio: false,
//           imageFormatGroup: ImageFormatGroup.yuv420,
//         );

//         await _cameraController!.initialize();
//         await _cameraController!.setFlashMode(FlashMode.off);

//         // ✅ Fetch min, max, and current exposure values
//         _minExposure = await _cameraController!.getMinExposureOffset();
//         _maxExposure = await _cameraController!.getMaxExposureOffset();
//         _exposure = (_minExposure + _maxExposure) / 2; // Set to mid-range

//         setState(() {});
//       } else {
//         print("❌ No cameras available");
//       }
//     } catch (e) {
//       print("❌ Error initializing camera: $e");
//     }
//   }

//   void _toggleCamera() {
//     setState(() {
//       isCameraEnabled = !isCameraEnabled;
//     });

//     if (isCameraEnabled) {
//       _startFrameCapture();
//     } else {
//       captureTimer?.cancel();
//     }
//   }

//   void _startFrameCapture() {
//     captureTimer =
//         Timer.periodic(Duration(seconds: captureInterval), (timer) async {
//       if (!isCameraEnabled ||
//           isProcessing ||
//           _cameraController == null ||
//           !_cameraController!.value.isInitialized) {
//         return;
//       }

//       isProcessing = true;
//       try {
//         XFile imageFile = await _cameraController!.takePicture();
//         Uint8List imageBytes = await imageFile.readAsBytes();
//         String base64Image = await compute(encodeImageToBase64, imageBytes);
//         await _sendToApi(base64Image);
//       } catch (e) {
//         print("❌ Error capturing frame: $e");
//       } finally {
//         isProcessing = false;
//       }
//     });
//   }

//   static String encodeImageToBase64(Uint8List imageBytes) {
//     return base64Encode(imageBytes);
//   }

//   void _loadModel() async {
//     if (isModelLoaded) return;

//     String loadModelUrl = "$serverIP/load_model_${widget.exercise}";

//     try {
//       Response response = await dio.get(loadModelUrl);
//       if (response.statusCode == 200) {
//         print(
//             "✅ Model ${widget.exercise} Loaded Successfully: ${response.data}");
//         setState(() {
//           isModelLoaded = true;
//         });
//       } else {
//         print(
//             "❌ Error loading Model ${widget.exercise}: ${response.statusCode}, ${response.data}");
//       }
//     } catch (e) {
//       print("❌ Failed to load Model ${widget.exercise}: $e");
//     }
//   }

//   Future<void> _sendToApi(String base64Image) async {
//     String apiUrl = "$serverIP/predict/model_${widget.exercise}";
//     print("🔗 API URL: $apiUrl");

//     try {
//       Response response = await dio.post(
//         apiUrl,
//         options: Options(
//           headers: {"Content-Type": "application/json"},
//           validateStatus: (status) => true,
//         ),
//         data: jsonEncode({"image": base64Image}),
//       );

//       print("✅ API Response Status: ${response.statusCode}");
//       print("✅ API Response Body: ${response.data}");

//       if (response.statusCode == 200) {
//         setState(() {
//           apiResponse = response.data.toString();
//         });
//       } else {
//         setState(() {
//           apiResponse = "❌ Error: ${response.statusCode}";
//         });
//       }
//     } catch (e) {
//       setState(() {
//         apiResponse = "❌ Failed to connect to API";
//       });
//       print("❌ Failed to send request: $e");
//     }
//   }

//   Future<void> _updateExposure(double value) async {
//     if (_cameraController == null) return;

//     try {
//       await _cameraController!.setExposureOffset(value);
//       setState(() {
//         _exposure = value; // ✅ Update UI manually
//       });
//     } catch (e) {
//       print("❌ Error setting exposure: $e");
//     }
//   }

//   @override
//   void dispose() {
//     captureTimer?.cancel();
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Exercise ${widget.exercise} Pose Detection")),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 3,
//             child: isCameraEnabled
//                 ? (_cameraController == null ||
//                         !_cameraController!.value.isInitialized
//                     ? Center(child: CircularProgressIndicator())
//                     : RotatedBox(
//                         quarterTurns: 4,
//                         child: CameraPreview(_cameraController!),
//                       ))
//                 : Center(child: Text("Camera is Off")),
//           ),
//           Slider(
//             value: _exposure,
//             min: _minExposure,
//             max: _maxExposure,
//             divisions: 10,
//             label: _exposure.toStringAsFixed(2),
//             onChanged: _updateExposure, // ✅ Adjust brightness dynamically
//           ),
//           ElevatedButton(
//             onPressed: _toggleCamera,
//             child: Text(isCameraEnabled ? "Turn Camera Off" : "Turn Camera On"),
//           ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               color: Colors.black,
//               width: double.infinity,
//               padding: EdgeInsets.all(16),
//               child: Center(
//                 child: Text(
//                   apiResponse,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//LOADING MODEL FIRST THEN CALLING + OPTIMIZED + multiple exrercises + global variable for ip + Dynamic API + Manual Exposure + FRONT AND BACK CAMERA
// lib/widgets/Camera_integrate.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';

// Global server IP constant
const String serverIP = "http://10.110.12.209:5050";

class PoseScreen extends StatefulWidget {
  final int exercise;

  const PoseScreen({required this.exercise, super.key});

  @override
  _PoseScreenState createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isProcessing = false;
  String apiResponse = "Waiting for pose analysis...";
  bool isCameraEnabled = false;
  Timer? captureTimer;
  static const int captureInterval = 2; // Time interval for capturing frames
  final Dio dio = Dio();
  bool isModelLoaded = false;
  double _exposure = 0.0;
  double _minExposure = -2.0;
  double _maxExposure = 2.0;
  int _selectedCameraIndex = 0; // Default: back camera

  @override
  void initState() {
    super.initState();
    _loadModel().then((_) {
      if (isModelLoaded) {
        _initializeCamera();
      } else {
        setState(() {
          apiResponse = "❌ Model failed to load. Camera not started.";
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return; // Prevent setState if widget is disposed

    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        setState(() {
          apiResponse = "❌ No cameras available";
        });
        print("❌ No cameras available");
        return;
      }

      // Dispose of old controller safely
      await _cameraController?.dispose();
      _cameraController = null;

      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.off);

      _minExposure = await _cameraController!.getMinExposureOffset();
      _maxExposure = await _cameraController!.getMaxExposureOffset();
      _exposure = (_minExposure + _maxExposure) / 2;

      if (mounted) {
        setState(() {});
      }

      if (isCameraEnabled && isModelLoaded) {
        _startFrameCapture();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiResponse = "❌ Error initializing camera: $e";
        });
      }
      print("❌ Error initializing camera: $e");
    }
  }

  void _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
    await _initializeCamera();
    if (isCameraEnabled && isModelLoaded) {
      _startFrameCapture();
    }
  }

  void _toggleCamera() {
    setState(() {
      isCameraEnabled = !isCameraEnabled;
    });

    if (isCameraEnabled && isModelLoaded) {
      _startFrameCapture();
    } else {
      captureTimer?.cancel();
    }
  }

  void _startFrameCapture() {
    if (!isModelLoaded) {
      setState(() {
        apiResponse = "❌ Model not loaded yet. Please wait.";
      });
      return;
    }

    captureTimer?.cancel(); // Cancel previous timer
    captureTimer = Timer.periodic(
      const Duration(seconds: captureInterval),
      (timer) async {
        if (!isCameraEnabled ||
            isProcessing ||
            _cameraController == null ||
            !_cameraController!.value.isInitialized) {
          return;
        }

        isProcessing = true;
        try {
          final XFile imageFile = await _cameraController!.takePicture();
          final Uint8List imageBytes = await imageFile.readAsBytes();
          final String base64Image =
              await compute(encodeImageToBase64, imageBytes);
          await _sendToApi(base64Image);
        } catch (e) {
          if (mounted) {
            setState(() {
              apiResponse = "❌ Error capturing frame: $e";
            });
          }
          print("❌ Error capturing frame: $e");
        } finally {
          isProcessing = false;
        }
      },
    );
  }

  static String encodeImageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  Future<void> _loadModel() async {
    if (isModelLoaded) return;

    final String loadModelUrl = "$serverIP/load_model_${widget.exercise}";
    print("🔗 Loading model from: $loadModelUrl");

    try {
      final Response response = await dio.get(loadModelUrl);
      if (response.statusCode == 200) {
        print(
            "✅ Model ${widget.exercise} Loaded Successfully: ${response.data}");
        if (mounted) {
          setState(() {
            isModelLoaded = true;
            apiResponse = "✅ Model loaded. Ready for pose analysis.";
          });
        }
      } else {
        print(
            "❌ Error loading Model ${widget.exercise}: ${response.statusCode}, ${response.data}");
        if (mounted) {
          setState(() {
            apiResponse = "❌ Model load failed: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      print("❌ Failed to load Model ${widget.exercise}: $e");
      if (mounted) {
        setState(() {
          apiResponse = "❌ Failed to load model: $e";
        });
      }
    }
  }

  Future<void> _sendToApi(String base64Image) async {
    final String apiUrl = "$serverIP/predict/model_${widget.exercise}";
    print("🔗 Sending to API: $apiUrl");

    try {
      final Response response = await dio.post(
        apiUrl,
        options: Options(
          headers: {"Content-Type": "application/json"},
          validateStatus: (status) => true,
        ),
        data: jsonEncode({"image": base64Image}),
      );

      print("✅ API Response Status: ${response.statusCode}");
      print("✅ API Response Body: ${response.data}");

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            apiResponse = response.data.toString();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            apiResponse = "❌ Error: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          apiResponse = "❌ Failed to connect to API: $e";
        });
      }
      print("❌ Failed to send request: $e");
    }
  }

  Future<void> _updateExposure(double value) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      await _cameraController!.setExposureOffset(value);
      if (mounted) {
        setState(() {
          _exposure = value;
        });
      }
    } catch (e) {
      print("❌ Error setting exposure: $e");
    }
  }

  @override
  void dispose() {
    captureTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise ${widget.exercise} Pose Detection"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: isCameraEnabled
                ? (_cameraController == null ||
                        !_cameraController!.value.isInitialized
                    ? const Center(child: CircularProgressIndicator())
                    : RotatedBox(
                        quarterTurns: 4,
                        child: CameraPreview(_cameraController!),
                      ))
                : const Center(child: Text("Camera is Off")),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _toggleCamera,
                child: Text(
                    isCameraEnabled ? "Turn Camera Off" : "Turn Camera On"),
              ),
              ElevatedButton(
                onPressed: _switchCamera,
                child: const Text("Switch Camera"),
              ),
            ],
          ),
          Slider(
            value: _exposure,
            min: _minExposure,
            max: _maxExposure,
            divisions: 10,
            label: _exposure.toStringAsFixed(2),
            onChanged: _updateExposure,
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  apiResponse,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
