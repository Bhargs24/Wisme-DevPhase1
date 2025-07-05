class StoredAudioFile {
  final String id;
  final String filePath;
  final String fileName;
  final int fileSizeBytes;
  final DateTime createdAt;
  final List<String> hashtags;
  final Map<String, dynamic> metadata;

  const StoredAudioFile({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.hashtags,
    required this.metadata,
  });
}
