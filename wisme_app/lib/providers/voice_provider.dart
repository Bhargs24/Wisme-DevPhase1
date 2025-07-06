import '../core/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';
class VoiceProvider extends ChangeNotifier {
  final TTSService _ttsService;
  final SharedPreferences _prefs;

  String _selectedVoiceId = 'default';
  List<ElevenLabsVoice> _availableVoices = [];
  bool _isLoading = false;
  String? _error;
  bool _isPreviewPlaying = false;

  VoiceProvider({
    required TTSService ttsService,
    required SharedPreferences prefs,
  }) : _ttsService = ttsService, 
       _prefs = prefs {
    _loadSavedVoice();
    _loadAvailableVoices();
  }

  // Getters
  String get selectedVoiceId => _selectedVoiceId;
  List<ElevenLabsVoice> get availableVoices => _availableVoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPreviewPlaying => _isPreviewPlaying;

  ElevenLabsVoice? get selectedVoice {
    try {
      return _availableVoices.firstWhere(
        (voice) => voice.voiceId == _selectedVoiceId,
      );
    } catch (e) {
      return _availableVoices.isNotEmpty ? _availableVoices.first : null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _loadSavedVoice() {
    _selectedVoiceId = _prefs.getString('selected_voice_id') ?? 'default';
    notifyListeners();
  }

  Future<void> _loadAvailableVoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final voicesData = await _ttsService.getAvailableVoices();
      _availableVoices = voicesData
          .map((voiceData) => ElevenLabsVoice.fromJson(voiceData))
          .toList();
      
      // If selected voice is not available, select the first one
      if (_availableVoices.isNotEmpty && 
          !_availableVoices.any((voice) => voice.voiceId == _selectedVoiceId)) {
        _selectedVoiceId = _availableVoices.first.voiceId;
        await _saveSelectedVoice();
      }

      AppLogger.info('Loaded ${_availableVoices.length} available voices');
    } catch (e) {
      AppLogger.error('Failed to load voices: $e');
      _error = 'Failed to load available voices';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectVoice(String voiceId) async {
    if (_selectedVoiceId == voiceId) return;

    _selectedVoiceId = voiceId;
    await _saveSelectedVoice();
    notifyListeners();
    AppLogger.info('Selected voice: $voiceId');
  }

  Future<void> _saveSelectedVoice() async {
    await _prefs.setString('selected_voice_id', _selectedVoiceId);
  }

  // Preview voice with sample text
  Future<void> previewVoice(String voiceId, {String? sampleText}) async {
    if (_isPreviewPlaying) return;

    _isPreviewPlaying = true;
    _error = null;
    notifyListeners();

    try {
      final text = sampleText ?? _getDefaultSampleText();
      await _ttsService.previewVoice(voiceId, text);
      AppLogger.info('Playing voice preview for: $voiceId');
    } catch (e) {
      AppLogger.error('Failed to preview voice: $e');
      _error = 'Failed to preview voice';
    } finally {
      _isPreviewPlaying = false;
      notifyListeners();
    }
  }

  // Stop voice preview
  Future<void> stopPreview() async {
    try {
      await _ttsService.stop();
      _isPreviewPlaying = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to stop preview: $e');
    }
  }

  // Get voices by category
  List<ElevenLabsVoice> getVoicesByCategory(String category) {
    return _availableVoices.where((voice) => 
        voice.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Get voices by gender
  List<ElevenLabsVoice> getVoicesByGender(String gender) {
    return _availableVoices.where((voice) => 
        voice.description.toLowerCase().contains(gender.toLowerCase())).toList();
  }

  // Get voice categories
  List<String> get voiceCategories {
    return _availableVoices
        .map((voice) => voice.category)
        .toSet()
        .toList()
        ..sort();
  }

  // Refresh voices list
  Future<void> refreshVoices() async {
    await _loadAvailableVoices();
  }

  String _getDefaultSampleText() {
    return "Hello! This is a sample of my voice. I'm excited to help you learn new things through our audio content.";
  }

  // Check if voice is premium
  bool isVoicePremium(String voiceId) {
    final voice = _availableVoices.where((v) => v.voiceId == voiceId).firstOrNull;
    return voice?.category.toLowerCase() == 'premium';
  }

  // Get voice by ID
  ElevenLabsVoice? getVoiceById(String voiceId) {
    try {
      return _availableVoices.firstWhere((voice) => voice.voiceId == voiceId);
    } catch (e) {
      return null;
    }
  }

  // Get display name for voice
  String getVoiceDisplayName(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) return 'Default Voice';
    
    final voice = getVoiceById(voiceId);
    return voice?.name ?? 'Unknown Voice';
  }
}


