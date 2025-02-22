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
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
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
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
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
      _interpreter = await Interpreter.fromAsset('facenet.tflite');
    } catch (e) {
      print("FaceNet model loading error: $e");
    }
  }

  Future<void> _capturePhoto() async {
    if (!_controller.value.isInitialized) {
      debugPrint("Camera not initialized!");
      return;
    }

    try {
      final XFile file = await _controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      await _processCapturedImage(inputImage);
    } catch (e) {
      print("Photo capture error: $e");
    }
  }

  Future<void> _processCapturedImage(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      print("Faces detected: ${faces.length}");
      if (faces.isEmpty) {
        print("No face detected.");
      } else {
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
            await _captureAndStoreEmbedding(inputImage, face, pose);
          }
        }
      }
    } catch (e) {
      print("Face detection error: $e");
    }
  }

  Future<void> _captureAndStoreEmbedding(InputImage inputImage, Face face, String pose) async {
    final img.Image croppedFace = _cropFace(inputImage, face);
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
      print("✅ All poses captured!");
    }
  }

  img.Image _cropFace(InputImage inputImage, Face face) {
    final int left = face.boundingBox.left.toInt();
    final int top = face.boundingBox.top.toInt();
    final int width = face.boundingBox.width.toInt();
    final int height = face.boundingBox.height.toInt();

    final img.Image imgImage = img.decodeImage(inputImage.bytes!)!;
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
          onPressed: _capturePhoto,
          child: const Icon(Icons.camera_alt),
        ),
      );
}