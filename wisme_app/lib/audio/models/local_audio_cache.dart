class LocalAudioCache {
  final int totalFiles;
  final int totalSizeBytes;
  final DateTime lastCleanup;
  final List<String> cachedFileIds;

  const LocalAudioCache({
    required this.totalFiles,
    required this.totalSizeBytes,
    required this.lastCleanup,
    required this.cachedFileIds,
  });
}
