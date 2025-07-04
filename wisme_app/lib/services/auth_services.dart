import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update last active time
        await _updateLastActiveTime(userCredential.user!.uid);
        return await getCurrentUser(userCredential.user!.uid);
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
    return null;
  }

  // Create user with email and password
  Future<Map<String, dynamic>?> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final userData = {
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'preferred_voice': 'default',
          'learning_goals': <String>[],
          'preferences': <String, dynamic>{},
          'created_at': DateTime.now().toIso8601String(),
          'last_active_at': DateTime.now().toIso8601String(),
          'total_lessons_completed': 0,
          'streak_days': 0,
        };

        await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
        return userData;
      }
    } catch (e) {
      throw Exception('Account creation failed: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Update last active time
  Future<void> _updateLastActiveTime(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'last_active_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw error for this non-critical operation
      print('Failed to update last active time: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
}
