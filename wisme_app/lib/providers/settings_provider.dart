import '../core/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  // App preferences
  bool _notificationsEnabled = true;
  bool _autoDownload = true;
  bool _wifiOnlyDownload = true;
  double _playbackSpeed = 1.0;
  String _downloadQuality = 'High';
  
  // Learning preferences
  Duration _dailyGoal = const Duration(minutes: 30);
  bool _dailyReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  
  SettingsProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _loadSettings();
  }

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoDownload => _autoDownload;
  bool get wifiOnlyDownload => _wifiOnlyDownload;
  double get playbackSpeed => _playbackSpeed;
  String get downloadQuality => _downloadQuality;
  Duration get dailyGoal => _dailyGoal;
  bool get dailyReminders => _dailyReminders;
  TimeOfDay get reminderTime => _reminderTime;

  void _loadSettings() {
    _themeMode = ThemeMode.values[_prefs.getInt('theme_mode') ?? 0];
    _isDarkMode = _prefs.getBool('dark_mode') ?? false;
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
    _autoDownload = _prefs.getBool('auto_download') ?? true;
    _wifiOnlyDownload = _prefs.getBool('wifi_only_download') ?? true;
    _playbackSpeed = _prefs.getDouble('playback_speed') ?? 1.0;
    _downloadQuality = _prefs.getString('download_quality') ?? 'High';
    
    final dailyGoalMinutes = _prefs.getInt('daily_goal_minutes') ?? 30;
    _dailyGoal = Duration(minutes: dailyGoalMinutes);
    
    _dailyReminders = _prefs.getBool('daily_reminders') ?? true;
    
    final reminderHour = _prefs.getInt('reminder_hour') ?? 9;
    final reminderMinute = _prefs.getInt('reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    notifyListeners();
  }

  // Theme settings
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _isDarkMode = enabled;
    await _prefs.setBool('dark_mode', enabled);
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setInt('theme_mode', _themeMode.index);
    notifyListeners();
  }

  // App preferences
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> setAutoDownload(bool enabled) async {
    _autoDownload = enabled;
    await _prefs.setBool('auto_download', enabled);
    notifyListeners();
  }

  Future<void> setWifiOnlyDownload(bool enabled) async {
    _wifiOnlyDownload = enabled;
    await _prefs.setBool('wifi_only_download', enabled);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _prefs.setDouble('playback_speed', speed);
    notifyListeners();
  }

  Future<void> setDownloadQuality(String quality) async {
    _downloadQuality = quality;
    await _prefs.setString('download_quality', quality);
    notifyListeners();
  }

  // Learning preferences
  Future<void> setDailyGoal(Duration goal) async {
    _dailyGoal = goal;
    await _prefs.setInt('daily_goal_minutes', goal.inMinutes);
    notifyListeners();
  }

  Future<void> setDailyReminders(bool enabled) async {
    _dailyReminders = enabled;
    await _prefs.setBool('daily_reminders', enabled);
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    await _prefs.setInt('reminder_hour', time.hour);
    await _prefs.setInt('reminder_minute', time.minute);
    notifyListeners();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await _prefs.clear();
    _themeMode = ThemeMode.system;
    _isDarkMode = false;
    _notificationsEnabled = true;
    _autoDownload = true;
    _wifiOnlyDownload = true;
    _playbackSpeed = 1.0;
    _downloadQuality = 'High';
    _dailyGoal = const Duration(minutes: 30);
    _dailyReminders = true;
    _reminderTime = const TimeOfDay(hour: 9, minute: 0);
    notifyListeners();
  }
}

