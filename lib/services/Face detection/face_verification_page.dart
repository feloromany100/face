import 'dart:typed_data';
import 'package:face_recognition/models/user.dart';
import 'package:face_recognition/services/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/Face recognition/embedding_extraction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cloudinary.dart';

class FaceVerificationPage extends StatelessWidget {
  final Uint8List croppedFace;
  final String personID;

  const FaceVerificationPage({super.key, required this.croppedFace, required this.personID});

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
            onPressed: () async {
              var user = await _getUserData(context);
              await _registerFace(context, personID);
              String? imageUrl = await cloudinaryUploadImage(
                  croppedFace,
                  user?.name,
                  oldImageUrl: user?.imageUrl
              );

              if (imageUrl != null) {
                // Update Firestore with the new image URL
                await _uploadImageUrl(context, personID, imageUrl);

                if(user!.uid == FirebaseService().firebaseAuth.currentUser!.uid) {
                  Provider.of<UserProvider>(context, listen: false).updateFieldImageUrl(imageUrl);
                }
              }
            },
            child: const Text('Register face'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerFace(BuildContext context, String userId) async {
    final faceImage = img.decodeImage(croppedFace);
    if (faceImage != null) {
      final extractor = FaceEmbeddingExtractor();
      bool isModelLoaded = await extractor.loadModel();
      if (!isModelLoaded) {
        print("Model loading failed!");
        return;
      }

      final List<double> mobileFaceNetEmbeddings = await extractor
          .extractEmbeddingFromMobileFaceNet(faceImage);
      final List<double> faceNetEmbeddings = await extractor
          .extractEmbeddingFromFaceNet(faceImage);

      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'mobileFaceNetEmbeddings': mobileFaceNetEmbeddings,
        'faceNetEmbeddings': faceNetEmbeddings,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Face registered successfully')),
      );
    }
  }

  Future<void> _uploadImageUrl(BuildContext context, String userId, String imageUrl) async {
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'imageUrl': imageUrl,
    });

    Navigator.pop(context);
    Navigator.pop(context);

  }

  Future<UserModel?> _getUserData(BuildContext context) async{
    FirebaseService firebaseService = FirebaseService();
    var userData = await firebaseService.getUserData(personID);
    UserModel user = UserModel.fromMap(userData!, personID);
    return user;
  }
}
