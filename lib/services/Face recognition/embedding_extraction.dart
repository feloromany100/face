import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

class FaceEmbeddingExtractor {
  late tfl.Interpreter mobileFaceNetInterpreter;
  late tfl.Interpreter faceNetInterpreter;
  bool _isLoaded = false;

  Future<bool> loadModel() async {
    if (!_isLoaded) {
      try {
        mobileFaceNetInterpreter = await tfl.Interpreter.fromAsset('assets/mobilefacenet.tflite');
        faceNetInterpreter = await tfl.Interpreter.fromAsset('assets/facenet.tflite');
        _isLoaded = true;
        return true; // Indicate success
      } catch (e) {
        print("Error loading models: $e");
        return false; // Indicate failure
      }
    }
    return true; // Already loaded
  }

  Future<List<double>> extractEmbeddingFromMobileFaceNet(img.Image faceImage) async {
    img.Image resized = img.copyResize(faceImage, width: 112, height: 112);
    List<List<List<List<double>>>> input = preprocessImage(resized);
    var output = List.filled(192, 0.0).reshape([1, 192]);

    mobileFaceNetInterpreter.run(input, output);
    return output[0];
  }

  Future<List<double>> extractEmbeddingFromFaceNet(img.Image faceImage) async {
    img.Image resized = img.copyResize(faceImage, width: 112, height: 112);
    List<List<List<List<double>>>> input = preprocessImage(resized);
    var output = List.filled(1 * 128, 0.0).reshape([1, 128]);

    faceNetInterpreter.run(input, output);
    return output[0];
  }

  List<List<List<List<double>>>> preprocessImage(img.Image image) {
    return [
      List.generate(112, (y) => List.generate(112, (x) {
        int pixel = image.getPixel(x, y);
        return [
          img.getRed(pixel) / 255.0,
          img.getGreen(pixel) / 255.0,
          img.getBlue(pixel) / 255.0
        ];
      }))
    ];
  }
}
