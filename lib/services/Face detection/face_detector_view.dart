import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'detector_view.dart';
import 'face_detector_painter.dart';
import '../../services/face_cropper.dart';
import 'face_verification_page.dart';
import 'package:image/image.dart' as img;

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key});

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;
  List<Face> _faces = [];
  CameraImage? _cameraImage;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DetectorView(
          title: 'Face Detector',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
        Positioned(
          bottom: 20,
          left: 80, // Increase the left margin
          right: 80, // Increase the right margin
          child: SizedBox(
            child: ElevatedButton(
              onPressed: _faces.length == 1 ? _navigateToVerification : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _faces.length == 1 ? Colors.blue : Colors.grey[900],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Capture the face",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );  }

  Future<void> _processImage(InputImage inputImage, CameraImage cameraImage) async {
    if (!_canProcess || _isBusy) return;
    _isBusy = true;
    _cameraImage = cameraImage;

    setState(() {
      _text = '';
    });

    final faces = await _faceDetector.processImage(inputImage);
    _faces = faces;

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = null;
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToVerification() async {
    if (_faces.isNotEmpty && _cameraImage != null) {
      final croppedFace = await cropFace(_cameraImage!, _faces.first);

      // Convert img.Image to Uint8List
      final Uint8List croppedFaceBytes = Uint8List.fromList(img.encodeJpg(croppedFace));

      if(mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FaceVerificationPage(croppedFace: croppedFaceBytes),
          ),
        );
      }
    }
  }
}