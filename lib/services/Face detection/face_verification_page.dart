import 'dart:typed_data';

import 'package:flutter/material.dart';

class FaceVerificationPage extends StatefulWidget {
  final Uint8List croppedFace;

  const FaceVerificationPage({super.key, required this.croppedFace});

  @override
  FaceVerificationPageState createState() => FaceVerificationPageState();
}

class FaceVerificationPageState extends State<FaceVerificationPage> {
  final bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Verification")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.memory(widget.croppedFace, width: 150, height: 150),
          const SizedBox(height: 20),
          _isProcessing
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: (){},
            child: const Text("Register Face"),
          ),
        ],
      ),
    );
  }
}
