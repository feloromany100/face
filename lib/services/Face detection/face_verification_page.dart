import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../main.dart';
import '../../services/Face recognition/embedding_extraction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaceVerificationPage extends StatelessWidget {
  final Uint8List croppedFace;

  const FaceVerificationPage({super.key, required this.croppedFace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Verification'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (croppedFace.isNotEmpty)
            Image.memory(croppedFace)
          else
            const Text('No image available'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _registerFace(context),
            child: const Text('Register face'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerFace(BuildContext context) async {
    final faceImage = img.decodeImage(croppedFace);
    if (faceImage != null) {
      final extractor = FaceEmbeddingExtractor();
      bool isModelLoaded = await extractor.loadModel();
      if (!isModelLoaded) {
        print("Model loading failed!");
        return;
      }
      final mobileFaceNetEmbeddings = await extractor.extractEmbeddingFromMobileFaceNet(faceImage);
      final faceNetEmbeddings = await extractor.extractEmbeddingFromFaceNet(faceImage);

      print("mobileFaceNetEmbeddings: $mobileFaceNetEmbeddings");
      print("faceNetEmbeddings: $faceNetEmbeddings");

      // Save to Firestore
      await FirebaseFirestore.instance.collection('faces').add({
        'name': "personName",
        'mobileFaceNetEmbeddings': mobileFaceNetEmbeddings,
        'faceNetEmbeddings': faceNetEmbeddings,
      });

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Face registered successfully')),
      );
    }
  }
}