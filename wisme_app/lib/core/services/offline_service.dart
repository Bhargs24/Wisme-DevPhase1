class OfflineService {
  static bool _isOnline = true;

  static bool get isOnline => _isOnline;

  static void setOnlineStatus(bool online) {
    _isOnline = online;
  }

  static Future<void> syncOfflineActions() async {
    // TODO: Implement offline action syncing
    print('Syncing offline actions...');
  }
}
