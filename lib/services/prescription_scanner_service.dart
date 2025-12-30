import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Service for scanning text from images using ML Kit
class PrescriptionScannerService {
  static final PrescriptionScannerService instance = PrescriptionScannerService._();
  PrescriptionScannerService._();

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  /// Pick an image from Camera or Gallery and scan it
  Future<List<String>> scanPrescription({bool fromCamera = true}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, // Optimize for speed/size
      );

      if (image == null) return [];

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      return _processText(recognizedText);
    } catch (e) {
      debugPrint('Scanning Error: $e');
      return [];
    }
  }

  /// Process raw OCR text into potential medicine names
  List<String> _processText(RecognizedText recognizedText) {
    List<String> medicines = [];

    // Simple heuristic: Get lines that look like medicine names
    // (In reality, this needs complex fuzzy matching against our DB)
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text.trim();
        
        // Filter out short noise or common non-medicine words
        if (text.length > 3 && !_isNoise(text)) {
          medicines.add(text);
        }
      }
    }

    return medicines;
  }

  bool _isNoise(String text) {
    final lowerText = text.toLowerCase().trim();
    // Only filter if the ENTIRE text is just noise (not if it contains these as part of medicine name)
    final exactNoise = ['rx', 'date', 'price', 'tk', 'qty', 'total', 'dr', 'doctor', 'patient', 'name', 'age', 'sig'];
    return exactNoise.contains(lowerText) || lowerText.length < 3;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
