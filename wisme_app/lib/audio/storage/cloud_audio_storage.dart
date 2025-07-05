class CloudAudioStorage {
  Future<String> uploadFile(String filePath, String fileName) async {
    // TODO: Implement cloud upload
    throw UnimplementedError('Cloud upload not implemented');
  }

  Future<String?> downloadFile(String fileId) async {
    // TODO: Implement cloud download
    return null;
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int filesUploaded;
  final int filesDownloaded;

  const SyncResult({
    required this.success,
    required this.message,
    required this.filesUploaded,
    required this.filesDownloaded,
  });
}

class CacheMaintenanceResult {
  final int filesDeleted;
  final int bytesFreed;
  final bool success;

  const CacheMaintenanceResult({
    required this.filesDeleted,
    required this.bytesFreed,
    required this.success,
  });
}
