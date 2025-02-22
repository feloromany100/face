import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

Future<img.Image> cropFace(CameraImage image, Face face) async {
  // Convert CameraImage to img.Image
  img.Image convertedImage = _convertCameraImage(image);

  // Get bounding box
  final int left = face.boundingBox.left.toInt();
  final int top = face.boundingBox.top.toInt();
  final int width = face.boundingBox.width.toInt();
  final int height = face.boundingBox.height.toInt();

  // Clamp values to prevent errors
  final int cropLeft = left.clamp(0, convertedImage.width - 1);
  final int cropTop = top.clamp(0, convertedImage.height - 1);
  final int cropWidth = width.clamp(1, convertedImage.width - cropLeft);
  final int cropHeight = height.clamp(1, convertedImage.height - cropTop);

  if (cropWidth <= 1 || cropHeight <= 1) {
    throw Exception("Cropped face dimensions are too small");
  }
  print("Converted image size: ${convertedImage.width}x${convertedImage.height}");

  return img.copyCrop(convertedImage, cropLeft, cropTop, cropWidth, cropHeight);
}

img.Image _convertCameraImage(CameraImage cameraImage) {
  if (cameraImage.planes.isEmpty) {
    throw Exception("Camera image planes are empty");
  }

  final int width = cameraImage.width;
  final int height = cameraImage.height;

  // Check format
  if (cameraImage.format.group != ImageFormatGroup.bgra8888) {
    throw Exception("Unsupported image format: ${cameraImage.format.group}");
  }

  Uint8List bytes = cameraImage.planes[0].bytes;
  if (bytes.isEmpty) {
    throw Exception("Camera image data is empty");
  }

  // Create an image buffer
  img.Image image = img.Image.fromBytes(width, height, bytes, format: img.Format.bgra);

  return image;
}