// DISABLED for APK build - Heavy dependencies removed  
// Original package: speech_to_text
class VoiceSearchService {
  static final VoiceSearchService instance = VoiceSearchService._();
  
  VoiceSearchService._();
  
  bool get isAvailable => false; // Feature disabled
  
  Future<String?> listen() async {
    return null; // Feature temporarily disabled
  }
  
  Future<String?> startListening() async {
    return null; // Feature temporarily disabled
  }
  
  static String extractSearchQuery(String text) {
    return text; // Passthrough
  }
}
