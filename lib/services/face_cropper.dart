import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import '../../services/Face recognition/embedding_extraction.dart';

Future<void> cropAndExtractEmbedding(CameraImage image, Face face) async {
  // Convert CameraImage to img.Image
  img.Image convertedImage = _convertCameraImage(image);

  // Get face bounding box
  final int left = face.boundingBox.left.toInt();
  final int top = face.boundingBox.top.toInt();
  final int width = face.boundingBox.width.toInt();
  final int height = face.boundingBox.height.toInt();

  // Ensure cropping does not exceed image bounds
  final int cropLeft = left.clamp(0, convertedImage.width - 1);
  final int cropTop = top.clamp(0, convertedImage.height - 1);
  final int cropWidth = width.clamp(1, convertedImage.width - cropLeft);
  final int cropHeight = height.clamp(1, convertedImage.height - cropTop);

  // Crop the face
  img.Image croppedFace = img.copyCrop(convertedImage, cropLeft, cropTop, cropWidth, cropHeight);

  // Extract embedding automatically
  FaceEmbeddingExtractor extractor = FaceEmbeddingExtractor();
  await extractor.loadModel();  // Ensure models are loaded

  List<double> embedding = await extractor.extractEmbeddingFromMobileFaceNet(croppedFace);
  List<double> embedding2 = await extractor.extractEmbeddingFromFaceNet(croppedFace);


  // TODO: Save embedding to Firestore or another storage
  print("Embedding from mobile facenet extracted: $embedding");
  print("Embedding from facenet extracted: $embedding2");

}

img.Image _convertCameraImage(CameraImage cameraImage) {
  final int width = cameraImage.width;
  final int height = cameraImage.height;

  // Convert YUV420 (NV21 format) to RGB
  img.Image image = img.Image(width, height);
  Uint8List bytes = cameraImage.planes[0].bytes;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int pixelIndex = y * width + x;
      int pixelValue = bytes[pixelIndex];

      // Convert grayscale to RGB
      image.setPixel(x, y, img.getColor(pixelValue, pixelValue, pixelValue));
    }
  }

  return image;
}
