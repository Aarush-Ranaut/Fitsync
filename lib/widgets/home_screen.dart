import 'dart:convert';
import 'dart:ui';
import 'package:fitsync_app/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:typed_data';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profilePictureBase64;
  String _firstName = "";
  late Interpreter _interpreter;
  CameraController? _cameraController;
  bool _isDetecting = false;
  String _postureStatus = "Analyzing...";
  bool _isModelLoaded = false; // Add a flag to track model loading

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initializeCamera();
    _loadModel();
  }

  // Load the model and set the flag when the model is ready
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/models/exercise_form_model.tflite');
      setState(() {
        _isModelLoaded = true; // Set the flag to true when model is loaded
      });
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Run inference only if the model is loaded
  Future<void> _runInference(List<double> keypoints) async {
    if (!_isModelLoaded || keypoints.length != 99) return;

    try {
      var input = [keypoints];
      var output = List.filled(1, 0.0);
      _interpreter?.run(input, output);

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

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print("No cameras available");
      return;
    }

    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    try {
      await _cameraController?.initialize();
      if (!mounted) return;
      setState(() {});

      _cameraController?.startImageStream((CameraImage image) {
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
    if (_isDetecting) return;

    _isDetecting = true;
    final PoseDetector poseDetector =
        PoseDetector(options: PoseDetectorOptions());
    final InputImage inputImage = _convertCameraImage(image);

    try {
      final List<Pose> poses = await poseDetector.processImage(inputImage);
      if (poses.isNotEmpty) {
        List<double> keypoints = _extractKeypoints(poses.first);
        await _runInference(keypoints);
      }
    } catch (e) {
      print("Error processing frame: $e");
    }

    _isDetecting = false;
  }

  InputImage _convertCameraImage(CameraImage image) {
    final List<int> bytesList = image.planes.fold<List<int>>(
      [],
      (previousValue, element) => previousValue + element.bytes,
    );

    final Uint8List bytes = Uint8List.fromList(bytesList);

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = _cameraController?.description;
    final InputImageRotation rotation = camera != null
        ? InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg
        : InputImageRotation.rotation0deg;

    final InputImageFormat format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    // Now we need to add 'bytesPerRow'
    final bytesPerRow = image.planes[0].bytesPerRow;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow, // Add the 'bytesPerRow' here
      ),
    );
  }

  List<double> _extractKeypoints(Pose pose) {
    List<double> keypoints = [];
    for (PoseLandmarkType type in PoseLandmarkType.values) {
      PoseLandmark? landmark = pose.landmarks[type];
      if (landmark != null) {
        keypoints.add(landmark.x);
        keypoints.add(landmark.y);
        keypoints.add(landmark.z);
      } else {
        keypoints.add(0.0);
        keypoints.add(0.0);
        keypoints.add(0.0);
      }
    }
    return keypoints.length == 99 ? keypoints : List<double>.filled(99, 0.0);
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String fullName = userDoc['firstName'] ?? 'Guest';
          String firstName = fullName.split(' ')[0];

          setState(() {
            _firstName = firstName;
            _profilePictureBase64 = userDoc['profileImage'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userId: userId),
      ),
    );
  }

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: _profilePictureBase64 != null &&
                          _profilePictureBase64!.isNotEmpty
                      ? Image.memory(
                          base64Decode(_profilePictureBase64!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/icons/ic_default_avatar.jpg',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 16),
                Text(
                  _firstName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _logout(context),
                    icon: Icon(Icons.logout, color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () => _showProfilePopup(context),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: _profilePictureBase64 != null &&
                              _profilePictureBase64!.isNotEmpty
                          ? MemoryImage(base64Decode(_profilePictureBase64!))
                          : const AssetImage(
                                  'assets/icons/ic_default_avatar.jpg')
                              as ImageProvider,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _navigateToEditProfile(context),
                    icon: Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Jan 22, 2025',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                _firstName,
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    _cameraController != null &&
                            _cameraController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _cameraController!.value.aspectRatio,
                            child: CameraPreview(_cameraController!),
                          )
                        : Center(child: CircularProgressIndicator()),
                    SizedBox(height: 20),
                    Text(
                      _postureStatus,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    _runInference(List<double>.filled(99, 0.0));
                  },
                  backgroundColor: Colors.green,
                  child: Icon(Icons.camera_alt, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
