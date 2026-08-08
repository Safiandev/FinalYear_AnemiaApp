import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AnemiaDetectionService {
  Interpreter? _interpreter;

  // Initialize and load model with await handling
  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model/anemia_model.tflite');
      print('✅ TFLite Model Loaded Successfully!');
    } catch (e) {
      print('❌ Error loading TFLite model: $e');
    }
  }

  // Preprocess Image (224x224 & Normalize 0-1) and Run Prediction
  Future<Map<String, dynamic>> predict(File imageFile) async {
    // 1. Ensure Model is Loaded properly before proceeding
    if (_interpreter == null) {
      await loadModel();
    }

    if (_interpreter == null) {
      return {'error': 'Failed to initialize AI Engine model.'};
    }

    // 2. Read Image Bytes
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      return {'error': 'Could not decode image'};
    }

    // 3. Resize to (224, 224) as required by MobileNetV2
    img.Image resizedImage =
        img.copyResize(originalImage, width: 224, height: 224);

    // 4. Prepare Input Tensor [1, 224, 224, 3] Normalized to (0-1)
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resizedImage.getPixel(x, y);
            return <double>[
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // 5. Output Buffer [1, 2] for [Anemic, Non-Anemic]
    var output = List<double>.filled(1 * 2, 0.0).reshape([1, 2]);

    try {
      // 6. Run Inference safely
      _interpreter!.run(input, output);

      // Extract Probabilities
      double anemicProb = output[0][0];
      double nonAnemicProb = output[0][1];

      bool isAnemic = anemicProb > nonAnemicProb;
      double confidence = (isAnemic ? anemicProb : nonAnemicProb) * 100;

      return {
        'result': isAnemic ? 'Anemic' : 'Non-Anemic',
        'confidence': confidence.toStringAsFixed(1),
        'anemic_probability': (anemicProb * 100).toStringAsFixed(1),
        'non_anemic_probability': (nonAnemicProb * 100).toStringAsFixed(1),
      };
    } catch (e) {
      print("❌ Error during TFLite Inference: $e");
      return {'error': 'Inference execution failed: $e'};
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';

// class AnemiaDetectionService {
//   Interpreter? _interpreter;

//   AnemiaDetectionService() {
//     _loadModel();
//   }

//   // Load TFLite Model from Assets
//   Future<void> _loadModel() async {
//     try {
//       _interpreter =
//           await Interpreter.fromAsset('assets/model/anemia_model.tflite');
//       print('✅ TFLite Model Loaded Successfully!');
//     } catch (e) {
//       print('❌ Error loading TFLite model: $e');
//     }
//   }

//   // Preprocess Image (224x224 & Normalize 0-1) and Run Prediction
//   Future<Map<String, dynamic>> predict(File imageFile) async {
//     if (_interpreter == null) {
//       await _loadModel();
//     }

//     // 1. Read Image Bytes
//     Uint8List imageBytes = await imageFile.readAsBytes();
//     img.Image? originalImage = img.decodeImage(imageBytes);

//     if (originalImage == null) {
//       return {'error': 'Could not decode image'};
//     }

//     // 2. Resize to (224, 224) as required by MobileNetV2
//     img.Image resizedImage =
//         img.copyResize(originalImage, width: 224, height: 224);

//     // 3. Prepare Input Tensor [1, 224, 224, 3] Normalized to (0-1)
//     var input = List.generate(
//       1,
//       (_) => List.generate(
//         224,
//         (y) => List.generate(
//           224,
//           (x) {
//             var pixel = resizedImage.getPixel(x, y);
//             return [
//               pixel.r / 255.0,
//               pixel.g / 255.0,
//               pixel.b / 255.0,
//             ];
//           },
//         ),
//       ),
//     );

//     // 4. Output Buffer [1, 2] for [Anemic, Non-Anemic]
//     var output = List.filled(1 * 2, 0.0).reshape([1, 2]);

//     // 5. Run Inference
//     _interpreter?.run(input, output);

//     // Extract Probabilities
//     double anemicProb = output[0][0];
//     double nonAnemicProb = output[0][1];

//     bool isAnemic = anemicProb > nonAnemicProb;
//     double confidence = (isAnemic ? anemicProb : nonAnemicProb) * 100;

//     return {
//       'result': isAnemic ? 'Anemic' : 'Non-Anemic',
//       'confidence': confidence.toStringAsFixed(1),
//       'anemic_probability': (anemicProb * 100).toStringAsFixed(1),
//       'non_anemic_probability': (nonAnemicProb * 100).toStringAsFixed(1),
//     };
//   }

//   void dispose() {
//     _interpreter?.close();
//   }
// }
