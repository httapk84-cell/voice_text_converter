import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/file_service.dart';
import '../models/audio_file.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final TTSService _ttsService = TTSService();
  final FileService _fileService = FileService();

  String _selectedLanguage = 'en-US';
  double _speechRate = 1.0;
  double _pitch = 1.0;
  double _volume = 1.0;
  List<String> _languages = [];
  bool _isLoading = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _ttsService.initTTS();
    final languages = await _ttsService.getAvailableLanguages();
    
    setState(() {
      _languages = languages;
      if (!_languages.contains(_selectedLanguage)) {
        _selectedLanguage = _languages.isNotEmpty ? _languages.first : 'en-US';
      }
    });
  }

  Future<void> _speak() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    await _ttsService.setLanguage(_selectedLanguage);
    await _ttsService.setSpeechRate(_speechRate);
    await _ttsService.setPitch(_pitch);
    await _ttsService.setVolume(_volume);

    setState(() => _isSpeaking = true);
    await _ttsService.speak(_textController.text);
    setState(() => _isSpeaking = false);
  }

  Future<void> _saveAsMP3() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _ttsService.setLanguage(_selectedLanguage);
      await _ttsService.setSpeechRate(_speechRate);
      await _ttsService.setPitch(_pitch);

      final audioFile = await _fileService.saveAudioFile(
        _textController.text,
        _selectedLanguage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved: ${audioFile.fileName}'),
            duration: const Duration(seconds: 3),
          ),
        );
        _textController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _ttsService.dispose();
    _fileService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceText Converter'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _textController,
                  maxLines: 6,
                  minLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter text here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedLanguage,
                  items: _languages.map((lang) {
                    return DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value ?? 'en-US');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Speed: ${_speechRate.toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _speechRate,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (value) {
                        setState(() => _speechRate = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pitch: ${_pitch.toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _pitch,
                      min: 0.5,
                      max: 2.0,
                      onChanged: (value) {
                        setState(() => _pitch = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Volume: ${(_volume * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        setState(() => _volume = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSpeaking ? null : _speak,
                    icon: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow),
                    label: Text(_isSpeaking ? 'Playing...' : 'Preview'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveAsMP3,
                    icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.save),
                    label: Text(_isLoading ? 'Saving...' : 'Save MP3'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
