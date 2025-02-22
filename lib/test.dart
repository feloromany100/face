import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_options.dart';
import 'package:image/image.dart' as img;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final cameras = await availableCameras();
  runApp(MyApp(camera: cameras.first));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: FaceRecognition(camera: camera),
    );
  }
}

class FaceRecognition extends StatefulWidget {
  final CameraDescription camera;
  const FaceRecognition({super.key, required this.camera});

  @override
  FaceRecognitionState createState() => FaceRecognitionState();
}

class FaceRecognitionState extends State<FaceRecognition> {
  late CameraController _controller;
  late Interpreter _interpreter;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isDetecting = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.1, // Adjust this value as needed
    ),
  );
  final Set<String> _capturedPoses = {};
  final List<String> requiredPoses = [
    "Front", "Left", "Right", "Up", "Down",
    "Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right"
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {}); // Refresh UI
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/facenet.tflite');
    } catch (e) {
      print("FaceNet model loading error: $e");
    }
  }

  void _startFaceDetection() {
    if (!_controller.value.isInitialized) {
      debugPrint("Camera not initialized!");
      return;
    }

    _controller.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;
        await _processCameraImage(image);
        _isDetecting = false;
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (image.planes.isEmpty || _capturedPoses.length >= requiredPoses.length) {
      _controller.stopImageStream();
      return;
    }
    final inputImage = _convertCameraImage(image);
    try {
      final faces = await _faceDetector.processImage(inputImage);
      print("Faces detected: ${faces.length}");
      if (faces.isEmpty) {
        print("No face detected.");
        return;
      } else {
        print("Face detected");
        for (var face in faces) {
          final double? yaw = face.headEulerAngleY;
          final double? pitch = face.headEulerAngleX;

          if (yaw == null || pitch == null) continue;

          String? pose;
          if (yaw.abs() < 10 && pitch.abs() < 10) {
            pose = "Front";
          } else if (yaw > 30) {
            pose = "Right";
          } else if (yaw < -30) {
            pose = "Left";
          } else if (pitch > 30) {
            pose = "Up";
          } else if (pitch < -30) {
            pose = "Down";
          } else if (yaw > 15 && pitch > 15) {
            pose = "Top-Right";
          } else if (yaw < -15 && pitch > 15) {
            pose = "Top-Left";
          } else if (yaw > 15 && pitch < -15) {
            pose = "Bottom-Right";
          } else if (yaw < -15 && pitch < -15) {
            pose = "Bottom-Left";
          }
          if (pose != null && !_capturedPoses.contains(pose)) {
            await _captureAndStoreEmbedding(image, face, pose);
          }
        }
      }
    } catch (e) {
      print("Face detection error: $e");
    }
  }

  InputImageRotation _getCameraRotation() {
    switch (widget.camera.sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _getCameraRotation(),
      format: InputImageFormat.yuv420,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _captureAndStoreEmbedding(CameraImage image, Face face, String pose) async {
    final img.Image croppedFace = _cropFace(image, face);
    final input = _imageToByteListFloat32(croppedFace, 160);
    final output = List.filled(128, 0).reshape([1, 128]);

    _interpreter.run(input, output);
    final embedding = output[0];
    final norm = sqrt(embedding.map((e) => e * e).reduce((a, b) => a + b));
    final normalizedEmbedding = embedding.map((e) => e / norm).toList();

    await _firestore.collection('face_embeddings').add({
      'name': "Person_$pose",
      'embedding': normalizedEmbedding,
    });

    _capturedPoses.add(pose);
    print("✅ Captured pose: $pose (${_capturedPoses.length}/${requiredPoses.length})");

    if (_capturedPoses.length >= requiredPoses.length) {
      _controller.stopImageStream();
      print("✅ All poses captured!");
    }
  }

  img.Image _cropFace(CameraImage image, Face face) {
    final int left = face.boundingBox.left.toInt();
    final int top = face.boundingBox.top.toInt();
    final int width = face.boundingBox.width.toInt();
    final int height = face.boundingBox.height.toInt();

    final img.Image imgImage = img.Image(image.width, image.height);
    return img.copyCrop(imgImage, left, top, width, height);
  }

  Uint8List _imageToByteListFloat32(img.Image image, int inputSize) {
    final Float32List floatList = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        final pixel = image.getPixel(j, i);
        floatList[index++] = (img.getRed(pixel) - 128) / 128;
        floatList[index++] = (img.getGreen(pixel) - 128) / 128;
        floatList[index++] = (img.getBlue(pixel) - 128) / 128;
      }
    }
    return floatList.buffer.asUint8List();
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(title: const Text('Face Recognition')),
        body: CameraPreview(_controller),
        floatingActionButton: FloatingActionButton(
          onPressed: _startFaceDetection,
          child: const Icon(Icons.videocam),
        ),
      );
}
