import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/audio_file.dart';

class FileService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<Directory> getAppDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${appDir.path}/voice_files');
    
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    
    return voiceDir;
  }

  Future<AudioFile> saveAudioFile(String text, String language) async {
    try {
      final appDir = await getAppDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'voice_$timestamp.mp3';
      final filePath = '${appDir.path}/$fileName';

      await _flutterTts.setLanguage(language);
      
      var result = await _flutterTts.synthesizeToFile(text, filePath);
      
      if (result == 1) {
        return AudioFile(
          id: timestamp.toString(),
          text: text.length > 50 ? '${text.substring(0, 50)}...' : text,
          fileName: fileName,
          filePath: filePath,
          createdAt: DateTime.now(),
        );
      } else {
        throw Exception('Failed to save audio file');
      }
    } catch (e) {
      throw Exception('Error saving audio: $e');
    }
  }

  Future<List<AudioFile>> getAudioFiles() async {
    try {
      final appDir = await getAppDir();
      final files = appDir.listSync();
      
      List<AudioFile> audioFiles = [];
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final fileName = file.path.split('/').last;
          final stat = await file.stat();
          
          audioFiles.add(AudioFile(
            id: fileName.replaceAll('.mp3', ''),
            text: fileName,
            fileName: fileName,
            filePath: file.path,
            createdAt: stat.modified,
          ));
        }
      }
      
      audioFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return audioFiles;
    } catch (e) {
      throw Exception('Error reading audio files: $e');
    }
  }

  Future<void> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  Future<String> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      
      if (bytes < 1024) {
        return '${bytes}B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)}KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
      }
    } catch (e) {
      return '0B';
    }
  }

  Future<void> dispose() async {
    await _flutterTts.stop();
  }
}
