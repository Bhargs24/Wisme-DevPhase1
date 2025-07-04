import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';

class VoiceProvider extends ChangeNotifier {
  final TTSService _ttsService;
  final SharedPreferences _prefs;

  String _selectedVoice = 'default';
  List<String> _availableVoices = ['default', 'female', 'male', 'robot', 'child'];
  bool _isLoading = false;

  VoiceProvider({
    required TTSService ttsService,
    required SharedPreferences prefs,
  }) : _ttsService = ttsService, _prefs = prefs {
    _loadSavedVoice();
  }

  // Getters
  String get selectedVoice => _selectedVoice;
  List<String> get availableVoices => _availableVoices;
  bool get isLoading => _isLoading;

  void _loadSavedVoice() {
    _selectedVoice = _prefs.getString('selected_voice') ?? 'default';
    notifyListeners();
  }

  Future<void> selectVoice(String voice) async {
    if (!_availableVoices.contains(voice)) return;

    _selectedVoice = voice;
    await _prefs.setString('selected_voice', voice);
    notifyListeners();
  }

  Future<void> previewVoice(String voice, String text) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _ttsService.speak(text, voice: voice);
    } catch (e) {
      if (kDebugMode) {
        print('Error previewing voice: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getVoiceDisplayName(String voice) {
    switch (voice) {
      case 'default':
        return 'Default Voice';
      case 'female':
        return 'Female Voice';
      case 'male':
        return 'Male Voice';
      case 'robot':
        return 'Robot Voice';
      case 'child':
        return 'Child Voice';
      default:
        return voice.toUpperCase();
    }
  }

  String getVoiceDescription(String voice) {
    switch (voice) {
      case 'default':
        return 'Clear and natural speaking voice';
      case 'female':
        return 'Warm and engaging female voice';
      case 'male':
        return 'Deep and authoritative male voice';
      case 'robot':
        return 'Fun robotic voice for tech topics';
      case 'child':
        return 'Friendly voice perfect for learning';
      default:
        return 'Custom voice option';
    }
  }

  void stopPreview() {
    _ttsService.stop();
  }
}
