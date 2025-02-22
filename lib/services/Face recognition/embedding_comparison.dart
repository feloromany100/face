import 'dart:math';

class FaceRecognition {
  static double cosineSimilarity(List<double> emb1, List<double> emb2) {
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < emb1.length; i++) {
      dotProduct += emb1[i] * emb2[i];
      norm1 += emb1[i] * emb1[i];
      norm2 += emb2[i] * emb2[i];
    }

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  static bool isMatch(List<double> emb1, List<double> emb2, {double threshold = 0.6}) {
    double similarity = cosineSimilarity(emb1, emb2);
    return similarity > threshold; // Adjust the threshold as needed
  }
}
