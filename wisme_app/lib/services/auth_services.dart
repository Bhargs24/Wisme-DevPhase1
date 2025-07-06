import '../core/exports.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
class AuthService {
  static final _logger = Logger();
  
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  FirebaseFirestore? _firestore;
  
  bool _isFirebaseAvailable = false;

  AuthService() {
    try {
      // Only initialize if Firebase is properly configured
      // This will fail gracefully if Firebase is not set up
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      _logger.i('AuthService: Firebase services initialized');
    } catch (e) {
      _logger.w('AuthService: Firebase not available (this is expected in offline mode): $e');
      _isFirebaseAvailable = false;
    }
  }

  // Get current user
  User? get currentUser {
    if (!_isFirebaseAvailable || _auth == null) return null;
    try {
      return _auth!.currentUser;
    } catch (e) {
      _logger.w('⚠️ Cannot get current user - Firebase not initialized');
      return null;
    }
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges {
    if (!_isFirebaseAvailable || _auth == null) {
      return Stream.value(null);
    }
    try {
      return _auth!.authStateChanges();
    } catch (e) {
      _logger.w('⚠️ Cannot get auth state changes - Firebase not initialized');
      return Stream.value(null);
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail(String email, String password) async {
    if (!_isFirebaseAvailable || _auth == null) {
      throw Exception('Firebase Authentication not available. Please configure Firebase first.');
    }
    
    try {
      final UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _updateLastActiveTime(result.user!.uid);
        return await getUserProfile(result.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Register with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? preferredCoach,
    List<String>? interests,
  }) async {
    try {
      if (!_isFirebaseAvailable || _auth == null) {
        throw Exception('Firebase authentication is not available. Please configure Firebase to use this feature.');
      }

      final UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);
        
        // Create user profile
        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          displayName: name,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          preferences: UserPreferences(
            interests: interests ?? [],
          ),
          learningProfile: LearningProfile(
            lastActiveDate: DateTime.now(),
          ),
          progress: UserProgress(
            lastProgressUpdate: DateTime.now(),
          ),
        );

        await _createUserProfile(userModel);
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not configured. Please set up Firebase to use Google Sign-In.');
    }
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth!.signInWithCredential(credential);
      
      if (result.user != null) {
        // Check if user profile exists, create if not
        UserModel? userModel = await getUserProfile(result.user!.uid);
        
        if (userModel == null) {
          userModel = UserModel(
            id: result.user!.uid,
            email: result.user!.email ?? '',
            displayName: result.user!.displayName ?? 'User',
            photoURL: result.user!.photoURL,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            preferences: UserPreferences(),
            learningProfile: LearningProfile(
              lastActiveDate: DateTime.now(),
            ),
            progress: UserProgress(
              lastProgressUpdate: DateTime.now(),
            ),
          );
          await _createUserProfile(userModel);
        } else {
          await _updateLastActiveTime(result.user!.uid);
        }
        
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase is not configured. Cannot sign out.');
    }
    
    try {
      await Future.wait([
        if (_auth != null) _auth!.signOut(),
        if (_googleSignIn != null) _googleSignIn!.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (!_isFirebaseAvailable || _auth == null) {
        throw Exception('Firebase authentication is not available. Please configure Firebase to use this feature.');
      }

      await _auth!.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Update email
  Future<void> updateEmail(String newEmail, String password) async {
    try {
      if (!_isFirebaseAvailable || _auth == null || _firestore == null) {
        throw Exception('Firebase is not available. Please configure Firebase to use this feature.');
      }

      final user = _auth!.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email with verification
      await user.verifyBeforeUpdateEmail(newEmail);
      
      // Update in Firestore
      await _firestore!.collection('users').doc(user.uid).update({
        'email': newEmail,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      if (!_isFirebaseAvailable || _auth == null) {
        throw Exception('Firebase authentication is not available. Please configure Firebase to use this feature.');
      }

      final user = _auth!.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  /// Delete account
  Future<void> deleteAccount(String password) async {
    try {
      if (!_isFirebaseAvailable || _auth == null || _firestore == null) {
        throw Exception('Firebase is not available. Please configure Firebase to use this feature.');
      }

      final user = _auth!.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _deleteUserData(user.uid);

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      if (!_isFirebaseAvailable || _firestore == null) {
        throw Exception('Firestore is not available. Please configure Firebase to use this feature.');
      }

      final doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Create user profile in Firestore
  Future<void> _createUserProfile(UserModel userModel) async {
    try {
      if (!_isFirebaseAvailable || _firestore == null) {
        _logger.w('Firestore is not available. User profile will not be saved.');
        return;
      }

      await _firestore!
          .collection('users')
          .doc(userModel.id)
          .set(userModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      if (!_isFirebaseAvailable || _firestore == null) {
        throw Exception('Firestore is not available. Please configure Firebase to use this feature.');
      }

      await _firestore!
          .collection('users')
          .doc(userModel.id)
          .update(userModel.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update last active time
  Future<void> _updateLastActiveTime(String uid) async {
    try {
      if (!_isFirebaseAvailable || _firestore == null) {
        _logger.w('Firestore is not available. Last active time will not be updated.');
        return;
      }

      await _firestore!.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Failed to update last active time: $e');
    }
  }

  /// Delete all user data
  Future<void> _deleteUserData(String uid) async {
    try {
      if (!_isFirebaseAvailable || _firestore == null) {
        _logger.w('Firestore is not available. User data will not be deleted.');
        return;
      }

      final batch = _firestore!.batch();

      // Delete user profile
      batch.delete(_firestore!.collection('users').doc(uid));

      // Delete user progress
      final progressQuery = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('progress')
          .get();
      
      for (final doc in progressQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user journeys
      final journeysQuery = await _firestore!
          .collection('journeys')
          .where('userId', isEqualTo: uid)
          .get();
      
      for (final doc in journeysQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      _logger.e('Failed to delete user data: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => _isFirebaseAvailable && _auth?.currentUser != null;

  /// Get current user ID
  String? get currentUserId => _isFirebaseAvailable ? _auth?.currentUser?.uid : null;

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      if (!_isFirebaseAvailable || _auth == null) {
        throw Exception('Firebase authentication is not available. Please configure Firebase to use this feature.');
      }

      final user = _auth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _isFirebaseAvailable ? (_auth?.currentUser?.emailVerified ?? false) : false;

  /// Reload user data
  Future<void> reloadUser() async {
    try {
      if (_isFirebaseAvailable && _auth != null) {
        await _auth!.currentUser?.reload();
      }
    } catch (e) {
      _logger.e('Failed to reload user: $e');
    }
  }
}

