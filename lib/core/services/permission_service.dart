import 'package:permission_handler/permission_handler.dart';

/// Camera / microphone for consultation video calls (same flow as patient_app).
class PermissionService {
  Future<bool> requestCameraPermission() async {
    final s = await Permission.camera.request();
    return s.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final s = await Permission.microphone.request();
    return s.isGranted;
  }
}
