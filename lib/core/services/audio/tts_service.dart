import 'package:flutter_tts/flutter_tts.dart';
import 'package:codoky/core/logging/app_logger.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('vi-VN');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
      AppLogger.i('🔊 FlutterTts initialized with vi-VN language settings');
    } catch (e) {
      AppLogger.w('Failed to initialize FlutterTts: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    if (!_isInitialized) await init();
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
      AppLogger.i('🗣️ TTS Speaking: "$text"');
    } catch (e) {
      AppLogger.w('TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      AppLogger.w('TTS Stop error: $e');
    }
  }
}
