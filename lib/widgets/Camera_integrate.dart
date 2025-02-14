// import 'dart:async';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// class PostureCameraScreen extends StatefulWidget {
//   @override
//   _PostureCameraScreenState createState() => _PostureCameraScreenState();
// }

// class _PostureCameraScreenState extends State<PostureCameraScreen> {
//   late Interpreter _interpreter;
//   CameraController? _cameraController;
//   bool _isDetecting = false;
//   String _postureStatus = "Analyzing...";
//   late PoseDetector _poseDetector;
//   bool _isModelLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _poseDetector = PoseDetector(options: PoseDetectorOptions());
//     _initializeCamera();
//     _loadModel();
//   }

//   Future<void> _loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset(
//           'assets/models/exercise_form_model.tflite');
//       setState(() => _isModelLoaded = true);
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
//     await _cameraController?.initialize();
//     if (!mounted) return;
//     setState(() {});

//     _cameraController?.startImageStream((image) {
//       if (!_isDetecting) {
//         _isDetecting = true;
//         _processFrame(image).then((_) => _isDetecting = false);
//       }
//     });
//   }

//   Future<void> _processFrame(CameraImage image) async {
//     if (!_isModelLoaded) return;

//     final inputImage = _convertCameraImage(image);
//     try {
//       final poses = await _poseDetector.processImage(inputImage);
//       if (poses.isNotEmpty) {
//         final keypoints = _extractKeypoints(poses.first);
//         await _runInference(keypoints);
//       }
//     } catch (e) {
//       print("Error processing frame: $e");
//     }
//   }

//   InputImage _convertCameraImage(CameraImage image) {
//     final bytesList = image.planes
//         .fold<List<int>>([], (prev, element) => prev + element.bytes);
//     final bytes = Uint8List.fromList(bytesList);
//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: InputImageRotation.rotation0deg,
//         format: InputImageFormat.nv21,
//         bytesPerRow: image.planes[0].bytesPerRow,
//       ),
//     );
//   }

//   List<double> _extractKeypoints(Pose pose) {
//     List<double> keypoints = [];
//     for (PoseLandmarkType type in PoseLandmarkType.values) {
//       final landmark = pose.landmarks[type];
//       keypoints.add(landmark?.x ?? 0.0);
//       keypoints.add(landmark?.y ?? 0.0);
//       keypoints.add(landmark?.z ?? 0.0);
//     }
//     return keypoints;
//   }

//   Future<void> _runInference(List<double> keypoints) async {
//     if (!_isModelLoaded || keypoints.length != 99) return;
//     try {
//       final input = [keypoints];
//       final output = List.generate(1, (index) => List<double>.filled(1, 0.0));
//       _interpreter.run(input, output);

//       setState(() {
//         _postureStatus = output[0][0] >= 0.5 ? "Correct" : "Incorrect";
//       });
//     } catch (e) {
//       print("Error running inference: $e");
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _interpreter.close();
//     _poseDetector.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             if (_cameraController != null &&
//                 _cameraController!.value.isInitialized)
//               CameraPreview(_cameraController!),
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Text(
//                   _postureStatus,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color:
//                         _postureStatus == "Correct" ? Colors.green : Colors.red,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;

class PoseDetectionScreen extends StatefulWidget {
  @override
  _PoseDetectionScreenState createState() => _PoseDetectionScreenState();
}

class _PoseDetectionScreenState extends State<PoseDetectionScreen> {
  Interpreter? _interpreter;
  CameraController? _cameraController;
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  List<List<double>> _keypoints = [];
  bool _poseDetected = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _loadModel() async {
    try {
      // Load the TensorFlow Lite model
      final options = InterpreterOptions()..threads = 4; // Multi-threading
      _interpreter = await Interpreter.fromAsset('4.tflite', options: options);

      // Retrieve the input tensor
      final inputTensor = _interpreter!.getInputTensor(0);

      // Print input tensor details
      print("✅ Model successfully loaded!");
      print("📏 Input Shape: ${inputTensor.shape}");
      print("📏 Input Type: ${inputTensor.type}");

      // Check the input tensor's data type
      if (inputTensor.type == TfLiteType.uint8) {
        print("🔍 Input type is Uint8");
      } else if (inputTensor.type == TfLiteType.float32) {
        print("🔍 Input type is Float32");
      } else {
        print("⚠️ Unsupported input type: ${inputTensor.type}");
      }

      // Update the UI to indicate the model is loaded
      setState(() => _isModelLoaded = true);
    } catch (e) {
      print("❌ Failed to load model: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("🚨 No cameras found");
        return;
      }

      await _cameraController?.dispose();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController?.initialize();
      if (!mounted) return;

      print("📷 Camera initialized successfully");
      print(
          "📸 Camera Image Format: ${_cameraController!.description.sensorOrientation}, "
          "ImageFormatGroup: ${_cameraController!.value.previewSize}");

      _cameraController?.startImageStream((image) {
        if (_isModelLoaded && _interpreter != null && !_isDetecting) {
          _isDetecting = true;
          _processFrame(image).then((_) => _isDetecting = false);
        }
      });

      setState(() {});
    } catch (e) {
      print("❌ Failed to initialize camera: $e");
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      if (_interpreter == null) {
        print("⚠️ Model is not initialized yet");
        return;
      }

      // Convert the camera image to a flat Uint8List (with 256x256x3 values)
      final Uint8List input = _convertImage(image);

      // Create a TensorBuffer with the correct shape [1, 256, 256, 3] and type uint8.
      TensorBuffer inputBuffer =
          TensorBuffer.createFixedSize([1, 256, 256, 3], TfLiteType.uint8);
      inputBuffer.loadList(input.toList(), shape: [1, 256, 256, 3]);

      // Create the output container matching the expected output shape: [1, 1, 17, 3].
      // This creates a 4D nested list: 1 batch, 1 extra dimension, 17 keypoints, each with 3 values.
      final output = List.generate(
        1,
        (_) => List.generate(
          1,
          (_) => List.generate(
            17,
            (_) => List.filled(3, 0.0),
          ),
        ),
      );

      // Run inference with the properly shaped input and output.
      _interpreter!.run(inputBuffer.buffer, output);

      // Parse keypoints from the output.
      final keypoints = _parseKeypoints(output);
      bool detected = _checkPoseDetected(keypoints);

      setState(() {
        _keypoints = keypoints;
        _poseDetected = detected;
      });

      print("✅ Keypoints: $_keypoints");
      print("🎯 Pose Detected: $_poseDetected");
    } catch (e) {
      print("📏 Model Input Type: ${_interpreter!.getInputTensor(0).type}");
      print("❌ Processing error: $e");
    }
  }

  Uint8List _convertImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    // Convert YUV420 to RGB using image package
    final img.Image convertedImage = img.Image(width, height);
    final yBuffer = image.planes[0].bytes;
    final uBuffer = image.planes[1].bytes;
    final vBuffer = image.planes[2].bytes;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        int y = yBuffer[i * width + j];
        int u = uBuffer[(i ~/ 2) * (width ~/ 2) + (j ~/ 2)];
        int v = vBuffer[(i ~/ 2) * (width ~/ 2) + (j ~/ 2)];

        int r = (y + (1.402 * (v - 128))).toInt();
        int g = (y - (0.344136 * (u - 128)) - (0.714136 * (v - 128))).toInt();
        int b = (y + (1.772 * (u - 128))).toInt();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        convertedImage.setPixel(j, i, img.getColor(r, g, b));
      }
    }

    // Resize to match model input (256x256)
    final resized = img.copyResize(convertedImage, width: 256, height: 256);

    // Convert to Uint8List for model
    final input = Uint8List(256 * 256 * 3);

    int index = 0;
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = img.getRed(pixel); // Red
        input[index++] = img.getGreen(pixel); // Green
        input[index++] = img.getBlue(pixel); // Blue
      }
    }

    print("📸 Converted Image Shape: [1, 256, 256, 3]");
    print("🔍 Sample Input Data (First 10 values): ${input.sublist(0, 10)}");

    return input;
  }

  /// Update the parser to work with an output shape of [1, 1, 17, 3].
  List<List<double>> _parseKeypoints(List<dynamic> output) {
    List<List<double>> keypoints = [];
    // output[0][0] is a List of 17 keypoints, each is a List of 3 doubles.
    final keypointList = output[0][0];
    for (int i = 0; i < keypointList.length; i++) {
      keypoints.add([
        keypointList[i][0], // x-coordinate
        keypointList[i][1], // y-coordinate
        keypointList[i][2] // confidence score
      ]);
    }
    return keypoints;
  }

  bool _checkPoseDetected(List<List<double>> keypoints) {
    int count = keypoints.where((k) => k[2] > 0.2).length;
    return count >= 3;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pose Detection")),
      body: _cameraController == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_cameraController!),
                CustomPaint(
                  painter: KeypointPainter(_keypoints),
                  child: Container(),
                ),
                if (_poseDetected)
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "Pose Detected!",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class KeypointPainter extends CustomPainter {
  final List<List<double>> keypoints;

  KeypointPainter(this.keypoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    for (var keypoint in keypoints) {
      final x = keypoint[0] * size.width;
      final y = keypoint[1] * size.height;
      if (keypoint[2] > 0.2) {
        canvas.drawCircle(Offset(x, y), 5.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
