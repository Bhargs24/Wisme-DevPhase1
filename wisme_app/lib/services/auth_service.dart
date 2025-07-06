import '../core/exports.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthenticationService {
  static AuthenticationService? _instance;
  static AuthenticationService get instance => _instance ??= AuthenticationService._internal();
  
  AuthenticationService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();
  final String _serviceName = 'AuthenticationService';
  
  // Stream controllers
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  final StreamController<UserProfile?> _userProfileController = StreamController<UserProfile?>.broadcast();
  
  // Getters
  Stream<User?> get authStateStream => _authStateController.stream;
  Stream<UserProfile?> get userProfileStream => _userProfileController.stream;
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isSignedIn => currentUser != null;
  
  UserProfile? _currentUserProfile;
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// Initialize the authentication service
  Future<void> initialize() async {
    try {
      AppLogger.info('$_serviceName: Initializing authentication service');
      
      // Listen to auth state changes
      _firebaseAuth.authStateChanges().listen((User? user) async {
        AppLogger.info('$_serviceName: Auth state changed - User: ${user?.uid}');
        _authStateController.add(user);
        
        if (user != null) {
          // Load user profile when signed in
          await _loadUserProfile(user.uid);
        } else {
          // Clear user profile when signed out
          _currentUserProfile = null;
          _userProfileController.add(null);
        }
      });
      
      AppLogger.info('$_serviceName: Authentication service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Failed to initialize authentication service', e, stackTrace);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<Result<UserProfile>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('$_serviceName: Attempting email/password sign in for: $email');

      // Validate input
      if (email.trim().isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Email is required',
          code: 'email_required',
        ));
      }

      if (password.trim().isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Password is required',
          code: 'password_required',
        ));
      }

      // Attempt sign in
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(AuthFailure(
          message: 'Sign in failed',
          code: 'sign_in_failed',
        ));
      }

      // Load or create user profile
      final profileResult = await _loadOrCreateUserProfile(credential.user!);
      if (profileResult.isFailure) {
        return Result.failure(profileResult.error!);
      }

      AppLogger.info('$_serviceName: Successfully signed in user: ${credential.user!.uid}');
      return Result.success(profileResult.data!);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error during sign in', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error during sign in', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Sign in failed',
        code: 'sign_in_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Sign up with email and password
  Future<Result<UserProfile>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      AppLogger.info('$_serviceName: Attempting email/password sign up for: $email');

      // Validate input
      final validationResult = _validateSignUpInput(email, password, displayName);
      if (validationResult.isFailure) {
        return Result.failure(validationResult.error!);
      }

      // Attempt sign up
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(AuthFailure(
          message: 'Sign up failed',
          code: 'sign_up_failed',
        ));
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName.trim());

      // Create user profile
      final profileResult = await _createNewUserProfile(
        credential.user!,
        displayName: displayName.trim(),
      );
      if (profileResult.isFailure) {
        return Result.failure(profileResult.error!);
      }

      // Send email verification
      await credential.user!.sendEmailVerification();

      AppLogger.info('$_serviceName: Successfully signed up user: ${credential.user!.uid}');
      return Result.success(profileResult.data!);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error during sign up', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error during sign up', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Sign up failed',
        code: 'sign_up_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Sign in with Google
  Future<Result<UserProfile>> signInWithGoogle() async {
    try {
      AppLogger.info('$_serviceName: Attempting Google sign in');

      // Trigger Google sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(AuthFailure(
          message: 'Google sign in was cancelled',
          code: 'sign_in_cancelled',
        ));
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        return Result.failure(AuthFailure(
          message: 'Google sign in failed',
          code: 'google_sign_in_failed',
        ));
      }

      // Load or create user profile
      final profileResult = await _loadOrCreateUserProfile(
        userCredential.user!,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
      if (profileResult.isFailure) {
        return Result.failure(profileResult.error!);
      }

      AppLogger.info('$_serviceName: Successfully signed in with Google: ${userCredential.user!.uid}');
      return Result.success(profileResult.data!);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error during Google sign in', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error during Google sign in', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Google sign in failed',
        code: 'google_sign_in_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      AppLogger.info('$_serviceName: Signing out user');

      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Sign out from Google if signed in with Google
      await _googleSignIn.signOut();

      // Clear user profile
      _currentUserProfile = null;
      _userProfileController.add(null);

      AppLogger.info('$_serviceName: Successfully signed out');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error during sign out', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Sign out failed',
        code: 'sign_out_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('$_serviceName: Sending password reset email to: $email');

      if (email.trim().isEmpty) {
        return Result.failure(ValidationFailure(
          message: 'Email is required',
          code: 'email_required',
        ));
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      AppLogger.info('$_serviceName: Password reset email sent successfully');
      return Result.success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error sending password reset', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error sending password reset', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to send password reset email',
        code: 'password_reset_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Send email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        return Result.failure(AuthFailure(
          message: 'No user signed in',
          code: 'no_user',
        ));
      }

      if (user.emailVerified) {
        return Result.failure(ValidationFailure(
          message: 'Email is already verified',
          code: 'email_already_verified',
        ));
      }

      await user.sendEmailVerification();

      AppLogger.info('$_serviceName: Email verification sent to: ${user.email}');
      return Result.success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error sending email verification', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error sending email verification', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to send email verification',
        code: 'email_verification_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Update user profile
  Future<Result<UserProfile>> updateUserProfile(UserProfile updatedProfile) async {
    try {
      AppLogger.info('$_serviceName: Updating user profile: ${updatedProfile.id}');

      final user = currentUser;
      if (user == null) {
        return Result.failure(AuthFailure(
          message: 'No user signed in',
          code: 'no_user',
        ));
      }

      // Update Firebase Auth profile if display name changed
      if (updatedProfile.displayName != user.displayName) {
        await user.updateDisplayName(updatedProfile.displayName);
      }

      // Update profile in Firestore
      await _firestoreService.updateDocument(
        'user_profiles',
        updatedProfile.id,
        updatedProfile.toJson(),
      );

      // Update local cache
      _currentUserProfile = updatedProfile;
      _userProfileController.add(updatedProfile);

      AppLogger.info('$_serviceName: Successfully updated user profile');
      return Result.success(updatedProfile);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error updating user profile', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to update user profile',
        code: 'profile_update_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Delete user account
  Future<Result<void>> deleteAccount() async {
    try {
      AppLogger.info('$_serviceName: Deleting user account');

      final user = currentUser;
      if (user == null) {
        return Result.failure(AuthFailure(
          message: 'No user signed in',
          code: 'no_user',
        ));
      }

      final userId = user.uid;

      // Delete user data from Firestore
      await _firestoreService.deleteDocument('user_profiles', userId);
      
      // Delete user activities, sessions, etc.
      // Note: In production, you'd want to implement a proper data deletion process
      await _firestoreService.deleteCollection('user_activities', 
          where: [['user_id', '==', userId]]);

      // Delete Firebase Auth account
      await user.delete();

      // Clear local data
      _currentUserProfile = null;
      _userProfileController.add(null);

      AppLogger.info('$_serviceName: Successfully deleted user account');
      return Result.success(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Firebase auth error deleting account', e, stackTrace);
      return Result.failure(_mapFirebaseAuthError(e));
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Unexpected error deleting account', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to delete account',
        code: 'account_deletion_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String userId) async {
    try {
      final doc = await _firestoreService.getDocument('user_profiles', userId);
      if (doc != null) {
        _currentUserProfile = UserProfile.fromJson(doc);
        _userProfileController.add(_currentUserProfile);
        AppLogger.debug('$_serviceName: Loaded user profile for: $userId');
      }
    } catch (e) {
      AppLogger.error('$_serviceName: Error loading user profile', e);
    }
  }

  /// Load or create user profile
  Future<Result<UserProfile>> _loadOrCreateUserProfile(User user, {bool isNewUser = false}) async {
    try {
      // Try to load existing profile
      final existingDoc = await _firestoreService.getDocument('user_profiles', user.uid);
      
      if (existingDoc != null) {
        // Profile exists, load it
        final profile = UserProfile.fromJson(existingDoc);
        _currentUserProfile = profile;
        _userProfileController.add(profile);
        return Result.success(profile);
      } else {
        // Profile doesn't exist, create new one
        return await _createNewUserProfile(user);
      }
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error loading or creating user profile', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to load user profile',
        code: 'profile_load_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Create new user profile
  Future<Result<UserProfile>> _createNewUserProfile(User user, {String? displayName}) async {
    try {
      final profile = UserProfile(
        id: user.uid,
        email: user.email ?? '',
        displayName: displayName ?? user.displayName ?? '',
        avatarUrl: user.photoURL,
        preferredCategories: [],
        defaultKnowledgeLevel: 'Mixed',
        preferredCoach: 'kai',
        learningPreferences: {},
        totalLearningTime: 0,
        currentStreak: 0,
        longestStreak: 0,
        completedLessons: [],
        categoryProgress: {},
        achievements: [],
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        settings: {
          'notifications_enabled': true,
          'email_notifications': false,
          'sound_enabled': true,
          'offline_downloads': true,
        },
      );

      // Save to Firestore
      await _firestoreService.setDocument(
        'user_profiles',
        user.uid,
        profile.toJson(),
      );

      // Update local cache
      _currentUserProfile = profile;
      _userProfileController.add(profile);

      AppLogger.info('$_serviceName: Created new user profile for: ${user.uid}');
      return Result.success(profile);
    } catch (e, stackTrace) {
      AppLogger.error('$_serviceName: Error creating user profile', e, stackTrace);
      return Result.failure(AuthFailure(
        message: 'Failed to create user profile',
        code: 'profile_creation_error',
        exception: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      ));
    }
  }

  /// Validate sign up input
  Result<void> _validateSignUpInput(String email, String password, String displayName) {
    if (email.trim().isEmpty) {
      return Result.failure(ValidationFailure(
        message: 'Email is required',
        code: 'email_required',
      ));
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return Result.failure(ValidationFailure(
        message: 'Please enter a valid email address',
        code: 'invalid_email',
      ));
    }

    if (password.trim().isEmpty) {
      return Result.failure(ValidationFailure(
        message: 'Password is required',
        code: 'password_required',
      ));
    }

    if (password.length < 8) {
      return Result.failure(ValidationFailure(
        message: 'Password must be at least 8 characters long',
        code: 'password_too_short',
      ));
    }

    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return Result.failure(ValidationFailure(
        message: 'Password must contain uppercase, lowercase, and number',
        code: 'weak_password',
      ));
    }

    if (displayName.trim().isEmpty) {
      return Result.failure(ValidationFailure(
        message: 'Display name is required',
        code: 'display_name_required',
      ));
    }

    if (displayName.trim().length < 2) {
      return Result.failure(ValidationFailure(
        message: 'Display name must be at least 2 characters',
        code: 'display_name_too_short',
      ));
    }

    return Result.success(null);
  }

  /// Map Firebase Auth exceptions to app failures
  AuthFailure _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure(
          message: 'No account found with this email',
          code: 'user_not_found',
        );
      case 'wrong-password':
        return AuthFailure(
          message: 'Incorrect password',
          code: 'wrong_password',
        );
      case 'email-already-in-use':
        return AuthFailure(
          message: 'An account with this email already exists',
          code: 'email_already_in_use',
        );
      case 'weak-password':
        return AuthFailure(
          message: 'Password is too weak',
          code: 'weak_password',
        );
      case 'invalid-email':
        return AuthFailure(
          message: 'Invalid email address',
          code: 'invalid_email',
        );
      case 'user-disabled':
        return AuthFailure(
          message: 'This account has been disabled',
          code: 'account_disabled',
        );
      case 'too-many-requests':
        return AuthFailure(
          message: 'Too many attempts. Please try again later',
          code: 'too_many_requests',
        );
      case 'requires-recent-login':
        return AuthFailure(
          message: 'This action requires recent authentication. Please sign in again',
          code: 'requires_recent_login',
        );
      case 'network-request-failed':
        return AuthFailure(
          message: 'Network error. Please check your connection',
          code: 'network_error',
        );
      default:
        return AuthFailure(
          message: e.message ?? 'Authentication failed',
          code: e.code,
        );
    }
  }

  /// Dispose of resources
  void dispose() {
    _authStateController.close();
    _userProfileController.close();
    AppLogger.info('$_serviceName: Authentication service disposed');
  }
}

