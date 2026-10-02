import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/file_service.dart';
import '../models/audio_file.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  final FileService _fileService = FileService();
  late Future<List<AudioFile>> _audioFilesFuture;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() {
    _audioFilesFuture = _fileService.getAudioFiles();
  }

  Future<void> _shareFile(AudioFile file) async {
    try {
      await Share.shareXFiles(
        [XFile(file.filePath)],
        subject: file.fileName,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing file: $e')),
      );
    }
  }

  Future<void> _deleteFile(AudioFile file) async {
    try {
      await _fileService.deleteAudioFile(file.filePath);
      setState(() => _loadFiles());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Files'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: FutureBuilder<List<AudioFile>>(
        future: _audioFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return const Center(
              child: Text('No saved files yet.\nCreate one on the home screen!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  leading: const Icon(Icons.audiotrack),
                  title: Text(file.fileName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.createdAt.toString().split('.')[0],
                        style: const TextStyle(fontSize: 12),
                      ),
                      FutureBuilder<String>(
                        future: _fileService.getFileSize(file.filePath),
                        builder: (context, sizeSnapshot) {
                          return Text(
                            sizeSnapshot.data ?? '0B',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Share'),
                        onTap: () => _shareFile(file),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete File?'),
                              content: Text('Delete ${file.fileName}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _deleteFile(file);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
