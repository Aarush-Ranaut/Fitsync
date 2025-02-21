import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class PoseScreen extends StatefulWidget {
  @override
  _PoseScreenState createState() => _PoseScreenState();
}

class _PoseScreenState extends State<PoseScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isProcessing = false;
  String apiResponse = "Waiting for pose analysis...";
  bool isCameraEnabled = true;

  // Capture frame every 2 seconds
  final int captureInterval = 1;
  Timer? captureTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
        );

        await _cameraController!.initialize();

        setState(() {});
        _startFrameCapture(); // Start frame capture after initialization
      } else {
        print("No cameras available");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  // Toggles camera on/off
  void _toggleCamera() {
    setState(() {
      isCameraEnabled = !isCameraEnabled;
    });

    if (!isCameraEnabled) {
      // Stop the timer and dispose of the camera if camera is off
      captureTimer?.cancel();
      _cameraController?.dispose();
      _cameraController = null;
    } else {
      // Re-initialize camera if turned back on
      _initializeCamera().then((_) {
        _startFrameCapture(); // Restart frame capture
      });
    }
  }

  // Periodically captures a frame from the camera
  void _startFrameCapture() {
    if (captureTimer != null && captureTimer!.isActive) {
      print("⚠️ Timer already running, skipping...");
      return;
    }

    captureTimer =
        Timer.periodic(Duration(seconds: captureInterval), (timer) async {
      print("⏳ Capturing frame at ${DateTime.now()}"); // Debugging

      if (!isCameraEnabled ||
          isProcessing ||
          _cameraController == null ||
          !_cameraController!.value.isInitialized) {
        return;
      }

      isProcessing = true;
      try {
        XFile imageFile = await _cameraController!.takePicture();
        Uint8List imageBytes = await imageFile.readAsBytes();

        // Convert image to Base64
        String base64Image = base64Encode(imageBytes);

        // Debugging: Validate Base64 Image Before Sending
        Uint8List decodedBytes = base64Decode(base64Image);
        print("🖼 Image Size: ${decodedBytes.length} bytes");
        print("📝 Base64 First 100 Chars: ${base64Image.substring(0, 100)}");

        if (decodedBytes.isEmpty) {
          print("❌ Error: Decoded Base64 is empty!");
          isProcessing = false;
          return;
        }

        print("✅ Image Captured & Encoded Successfully!");
        await _sendToApi(base64Image);
        print("📡 SENT TO API");
      } catch (e) {
        print("❌ Error capturing frame: $e");
      } finally {
        isProcessing = false;
      }
    });
  }

  // Sends the captured image to the API
  Future<void> _sendToApi(String base64Image) async {
    final url = Uri.parse("http://192.168.0.115:5000/predict");

    try {
      Map<String, dynamic> requestBody = {"image": base64Image};
      String jsonBody = jsonEncode(requestBody);

      print(
          "📤 Request JSON (First 200 chars): ${jsonBody.substring(0, 200)}...");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonBody,
      );

      print("📡 API Response Code: ${response.statusCode}");
      print("📡 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          apiResponse = responseData["prediction"] ?? "No response";
        });
      } else {
        setState(() {
          apiResponse = "❌ Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        apiResponse = "❌ Failed to connect to API";
      });
      print("❌ Failed to send request: $e");
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
        title: Text("Pose Detection"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: isCameraEnabled
                ? (_cameraController == null ||
                        !_cameraController!.value.isInitialized
                    ? Center(child: CircularProgressIndicator())
                    : RotatedBox(
                        quarterTurns: 4,
                        child: CameraPreview(_cameraController!),
                      ))
                : Center(child: Text("Camera is Off")),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  apiResponse,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _toggleCamera,
            child: Text(
              isCameraEnabled ? "Turn Camera Off" : "Turn Camera On",
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
