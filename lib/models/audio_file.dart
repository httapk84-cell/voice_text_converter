class AudioFile {
  final String id;
  final String text;
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;

  AudioFile({
    required this.id,
    required this.text,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    this.duration = Duration.zero,
  });
}
