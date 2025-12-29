import 'package:flutter/services.dart';

/// Voice Search Service using Android's built-in speech recognition
/// No external dependencies - uses platform channels to native Android Intent
class VoiceSearchService {
  static final VoiceSearchService instance = VoiceSearchService._();
  static const _channel = MethodChannel('medicine_saver_bd/voice');
  
  VoiceSearchService._();
  
  /// Check if voice recognition is available on device
  bool get isAvailable => true; // Android has built-in speech recognition
  
  /// Start voice recognition using Android Intent
  /// Returns the recognized text or null if cancelled/failed
  Future<String?> startListening() async {
    try {
      final String? result = await _channel.invokeMethod('startVoiceRecognition');
      return result;
    } on PlatformException catch (e) {
      print('Voice recognition error: ${e.message}');
      return null;
    } catch (e) {
      print('Voice recognition failed: $e');
      return null;
    }
  }
  
  /// Extract clean search query from voice input
  static String extractSearchQuery(String text) {
    // Remove common voice artifacts
    String cleaned = text.toLowerCase().trim();
    
    // Remove common prefixes
    final prefixes = ['search for', 'find', 'look for', 'show me', 'i want'];
    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        break;
      }
    }
    
    return cleaned;
  }
}
