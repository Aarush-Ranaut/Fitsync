import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // ✅ Ensure correct format
    );
    await _controller!.initialize();
  }

  CameraController? get controller => _controller;

  Future<void> disposeCamera() async {
    await _controller?.dispose();
    _controller = null;
  }
}
