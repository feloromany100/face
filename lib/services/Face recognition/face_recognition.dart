import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import '../../services/firebase_services.dart';
import 'embedding_extraction.dart';
import 'embedding_comparison.dart';

class FaceRecognitionService {
  final FaceEmbeddingExtractor embeddingExtractor = FaceEmbeddingExtractor();
  final FirebaseService firebaseService = FirebaseService();

  Future<String?> recognizeFace(img.Image faceImage) async {
    List<double> newEmbedding = await embeddingExtractor.extractEmbeddingFromMobileFaceNet(faceImage);

    // Fetch all stored users
    var users = await FirebaseFirestore.instance.collection('users').get();

    for (var user in users.docs) {
      List<dynamic> storedEmbedding = user['embedding'];
      bool isMatch = FaceRecognition.isMatch(newEmbedding, List<double>.from(storedEmbedding));
      if (isMatch) {
        return user.id; // Return matched user ID
      }
    }

    return null; // No match found
  }
}
