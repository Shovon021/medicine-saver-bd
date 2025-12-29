import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Service for scanning prescriptions and medicine strips using OCR.
class PrescriptionScannerService {
  static final PrescriptionScannerService instance = PrescriptionScannerService._init();
  
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  PrescriptionScannerService._init();

  /// Captures an image from the camera and extracts text.
  Future<ScanResult> scanFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (image == null) {
        return ScanResult(success: false, error: 'No image captured');
      }

      return await _processImage(image.path);
    } catch (e) {
      return ScanResult(success: false, error: 'Camera error: $e');
    }
  }

  /// Picks an image from the gallery and extracts text.
  Future<ScanResult> scanFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        return ScanResult(success: false, error: 'No image selected');
      }

      return await _processImage(image.path);
    } catch (e) {
      return ScanResult(success: false, error: 'Gallery error: $e');
    }
  }

  /// Processes the image and extracts medicine names.
  Future<ScanResult> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return ScanResult(success: false, error: 'No text found in image');
      }

      // Extract potential medicine names
      final List<String> medicineNames = _extractMedicineNames(recognizedText);

      return ScanResult(
        success: true,
        rawText: recognizedText.text,
        extractedMedicines: medicineNames,
      );
    } catch (e) {
      return ScanResult(success: false, error: 'OCR processing error: $e');
    }
  }

  /// Extracts potential medicine names from recognized text.
  List<String> _extractMedicineNames(RecognizedText recognizedText) {
    final List<String> medicines = [];
    final Set<String> seen = {};

    // Common medicine name patterns
    final RegExp medicinePattern = RegExp(
      r'\b([A-Z][a-z]+(?:\s+[A-Z]?[a-z]*)?)\s*(\d+(?:\.\d+)?)\s*(mg|mcg|ml|gm|iu|%)\b',
      caseSensitive: false,
    );

    // Also match capitalized words that might be brand names
    final RegExp brandPattern = RegExp(
      r'\b([A-Z][a-z]{2,}(?:\s+\d+)?)\b',
    );

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text;

        // Try medicine pattern first
        for (final match in medicinePattern.allMatches(text)) {
          final name = match.group(0)!.trim();
          final normalized = name.toLowerCase();
          if (!seen.contains(normalized)) {
            seen.add(normalized);
            medicines.add(name);
          }
        }

        // Try brand pattern
        for (final match in brandPattern.allMatches(text)) {
          final name = match.group(1)!.trim();
          final normalized = name.toLowerCase();
          
          // Filter out common non-medicine words
          if (!_isCommonWord(normalized) && !seen.contains(normalized)) {
            seen.add(normalized);
            medicines.add(name);
          }
        }
      }
    }

    return medicines;
  }

  /// Checks if a word is a common non-medicine word.
  bool _isCommonWord(String word) {
    const commonWords = {
      'patient', 'name', 'date', 'doctor', 'dr', 'hospital', 'clinic',
      'prescription', 'medicine', 'tablet', 'capsule', 'syrup', 'injection',
      'before', 'after', 'meals', 'breakfast', 'lunch', 'dinner', 'daily',
      'once', 'twice', 'thrice', 'morning', 'evening', 'night', 'days',
      'weeks', 'months', 'take', 'apply', 'use', 'signature', 'address',
      'phone', 'mobile', 'email', 'the', 'and', 'for', 'with', 'from',
    };
    return commonWords.contains(word.toLowerCase());
  }

  /// Releases resources.
  void dispose() {
    _textRecognizer.close();
  }
}

/// Result of a prescription scan.
class ScanResult {
  final bool success;
  final String? rawText;
  final List<String> extractedMedicines;
  final String? error;

  ScanResult({
    required this.success,
    this.rawText,
    this.extractedMedicines = const [],
    this.error,
  });
}
