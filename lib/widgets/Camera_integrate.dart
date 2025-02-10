// posture_camera_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class PostureCameraScreen extends StatefulWidget {
  const PostureCameraScreen({Key? key}) : super(key: key);

  @override
  _PostureCameraScreenState createState() => _PostureCameraScreenState();
}

class _PostureCameraScreenState extends State<PostureCameraScreen> {
  late Interpreter _interpreter;
  CameraController? _cameraController;
  bool _isDetecting = false;
  String _postureStatus = "Analyzing...";
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/models/exercise_form_model.tflite');
      setState(() => _isModelLoaded = true);
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    try {
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {});

      _cameraController?.startImageStream((image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _processFrame(image);
        }
      });
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    final poseDetector = PoseDetector(options: PoseDetectorOptions());
    final inputImage = _convertCameraImage(image);

    try {
      final poses = await poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        final keypoints = _extractKeypoints(poses.first);
        await _runInference(keypoints);
      }
    } catch (e) {
      print("Error processing frame: $e");
    } finally {
      _isDetecting = false;
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    final bytesList = image.planes.fold<List<int>>(
      [],
      (previousValue, element) => previousValue + element.bytes,
    );

    final bytes = Uint8List.fromList(bytesList);
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final camera = _cameraController?.description;
    final rotation = camera != null
        ? InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg
        : InputImageRotation.rotation0deg;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  List<double> _extractKeypoints(Pose pose) {
    List<double> keypoints = [];
    for (PoseLandmarkType type in PoseLandmarkType.values) {
      final landmark = pose.landmarks[type];
      keypoints.addAll([landmark?.x ?? 0, landmark?.y ?? 0, landmark?.z ?? 0]);
    }
    return keypoints.length == 99 ? keypoints : List.filled(99, 0.0);
  }

  Future<void> _runInference(List<double> keypoints) async {
    if (!_isModelLoaded || keypoints.length != 99) return;

    try {
      final input = [keypoints];
      final output = List.filled(1, 0.0);
      _interpreter.run(input, output);

      setState(() {
        _postureStatus =
            output[0] == 1 ? "Correct Posture" : "Incorrect Posture";
      });
    } catch (e) {
      print("Error running inference: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_cameraController != null &&
                _cameraController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _postureStatus,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
