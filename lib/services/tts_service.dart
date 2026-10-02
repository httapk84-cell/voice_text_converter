import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;

  Future<void> initTTS() async {
    await _flutterTts.awaitSpeakCompletion(true);
    
    if (Platform.isAndroid) {
      await _flutterTts.setEngine("com.google.android.tts");
    }
  }

  Future<List<String>> getAvailableLanguages() async {
    try {
      var languages = await _flutterTts.getLanguages as List;
      return languages.cast<String>();
    } catch (e) {
      return ['en-US', 'vi-VN', 'fr-FR', 'es-ES', 'de-DE', 'ja-JP', 'zh-CN'];
    }
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.speak(text);
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
