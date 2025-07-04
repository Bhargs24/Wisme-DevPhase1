import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  final SharedPreferences _prefs;

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserProvider({
    required AuthService authService,
    required SharedPreferences prefs,
  }) : _authService = authService, _prefs = prefs {
    _initialize();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already logged in
      final userId = _prefs.getString('user_id');
      if (userId != null) {
        final userData = await _authService.getCurrentUser(userId);
        if (userData != null) {
          _user = UserModel.fromMap(userData);
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing user: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.signInWithEmailAndPassword(email, password);
      if (userData != null) {
        _user = UserModel.fromMap(userData);
        _isLoggedIn = true;
        await _prefs.setString('user_id', _user!.id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging in: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _authService.createUserWithEmailAndPassword(email, password, name);
      if (userData != null) {
        _user = UserModel.fromMap(userData);
        _isLoggedIn = true;
        await _prefs.setString('user_id', _user!.id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      await _prefs.remove('user_id');
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return;

    try {
      await _authService.updateUserProfile(_user!.id, data);
      _user = _user!.copyWith(
        name: data['name'] ?? _user!.name,
        email: data['email'] ?? _user!.email,
        preferredVoice: data['preferredVoice'] ?? _user!.preferredVoice,
        learningGoals: data['learningGoals'] ?? _user!.learningGoals,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
    }
  }
}
