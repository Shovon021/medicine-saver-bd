import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service for handling voice-based medicine search.
class VoiceSearchService {
  static final VoiceSearchService instance = VoiceSearchService._init();
  
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastRecognizedWords = '';
  
  VoiceSearchService._init();

  /// Whether voice recognition is currently active.
  bool get isListening => _isListening;

  /// The last recognized speech text.
  String get lastWords => _lastRecognizedWords;

  /// Whether the speech recognition is available on this device.
  Future<bool> get isAvailable async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          // Error handling - logged silently in production
        },
        onStatus: (status) {
          // Status updates - logged silently in production
        },
      );
    }
    return _isInitialized;
  }

  /// Get available locales for speech recognition.
  Future<List<LocaleName>> getLocales() async {
    if (!await isAvailable) return [];
    return await _speechToText.locales();
  }

  /// Starts listening for voice input.
  /// 
  /// [onResult] is called whenever speech is recognized.
  /// [localeId] specifies the language (default: device language).
  /// 
  /// Common locale IDs:
  /// - 'en_US' for English
  /// - 'bn_BD' for Bengali (Bangladesh)
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    String? localeId,
    Duration? listenFor,
  }) async {
    if (!await isAvailable) {
      throw Exception('Speech recognition not available');
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;
    _lastRecognizedWords = '';

    await _speechToText.listen(
      onResult: (SpeechRecognitionResult result) {
        _lastRecognizedWords = result.recognizedWords;
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// Stops listening for voice input.
  Future<void> stopListening() async {
    _isListening = false;
    await _speechToText.stop();
  }

  /// Cancels the current listening session.
  Future<void> cancel() async {
    _isListening = false;
    await _speechToText.cancel();
  }

  /// Cleans up recognized text for search.
  /// Handles common voice patterns like "search for X" or "find Y".
  static String extractSearchQuery(String rawText) {
    String text = rawText.toLowerCase().trim();
    
    // Remove common prefixes
    final prefixes = [
      'search for',
      'search',
      'find',
      'look for',
      'look up',
      'show me',
      'what is',
      'tell me about',
    ];

    for (final prefix in prefixes) {
      if (text.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    // Capitalize first letter for display
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    return text;
  }
}
