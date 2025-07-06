import 'package:flutter/foundation.dart';
import '../models/coach_model.dart';
import '../utils/logger.dart';

class CoachProvider extends ChangeNotifier {
  List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel> _availableCoaches = [];
  Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel? _selectedCoach;
  bool _isLoading = false;
  String? _error;

  CoachProvider() {
    loadAvailableCoaches();
  }

  // Getters
  List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel> get availableCoaches => _availableCoaches;
  Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel? get selectedCoach => _selectedCoach;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load all available coaches
  Future<void> loadAvailableCoaches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load default coaches for now
      _availableCoaches = Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel.predefinedCoaches;
      AppLogger.info('Loaded ${_availableCoaches.length} available coaches');
    } catch (e) {
      AppLogger.error('Failed to load coaches: $e');
      _error = 'Failed to load coaches';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select a coach
  void selectCoach(Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel coach) {
    _selectedCoach = coach;
    notifyListeners();
    AppLogger.info('Selected coach: ${coach.name}');
  }

  // Set selected coach from Map data
  void setSelectedCoach(Map<String, dynamic> coachData) {
    try {
      final coach = Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel(
        id: coachData['id'] ?? '',
        name: coachData['name'] ?? '',
        personality: coachData['personality'] ?? '',
        voiceId: coachData['id'] ?? 'default',
        avatarUrl: coachData['avatar'] ?? 'ðŸ‘¨â€ðŸ«',
        description: coachData['description'] ?? '',
        specialties: List<String>.from(coachData['specialties'] ?? []),
        isCustom: false,
        createdAt: DateTime.now(),
      );
      _selectedCoach = coach;
      notifyListeners();
      AppLogger.info('Selected coach from data: ${coach.name}');
    } catch (e) {
      AppLogger.error('Failed to set selected coach: $e');
      _error = 'Failed to set selected coach';
      notifyListeners();
    }
  }

  // Get coach by ID
  Future<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel?> getCoach(String coachId) async {
    try {
      // Return coach from predefined coaches
      return _availableCoaches.firstWhere(
        (coach) => coach.id == coachId,
        orElse: () => Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel.kai, // Default fallback
      );
    } catch (e) {
      AppLogger.error('Failed to get coach: $e');
      return null;
    }
  }

  // Get coaches by category
  List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel> getCoachesByCategory(String category) {
    return _availableCoaches.where((coach) => 
        coach.specialties.contains(category)).toList();
  }

  // Get coaches by expertise
  List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with CoachModel> getCoachesByExpertise(String expertise) {
    return _availableCoaches.where((coach) => 
        coach.specialties.contains(expertise)).toList();
  }

  // Clear selection
  void clearSelection() {
    _selectedCoach = null;
    notifyListeners();
  }
}

