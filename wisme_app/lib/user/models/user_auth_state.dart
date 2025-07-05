import 'package:equatable/equatable.dart';

/// Production-grade user authentication state model
/// Manages authentication status, tokens, and security information
class UserAuthState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final AuthTokens? tokens;
  final UserSecurityInfo? securityInfo;
  final AuthError? error;
  final DateTime? lastAuthCheck;
  final AuthMethod? lastAuthMethod;
  final bool requiresReauth;
  final bool isBiometricEnabled;
  final Map<String, dynamic> authMetadata;

  const UserAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userId,
    this.tokens,
    this.securityInfo,
    this.error,
    this.lastAuthCheck,
    this.lastAuthMethod,
    this.requiresReauth = false,
    this.isBiometricEnabled = false,
    this.authMetadata = const {},
  });

  /// Create initial unauthenticated state
  factory UserAuthState.initial() {
    return const UserAuthState();
  }

  /// Create loading state
  factory UserAuthState.loading() {
    return const UserAuthState(isLoading: true);
  }

  /// Create authenticated state
  factory UserAuthState.authenticated({
    required String userId,
    required AuthTokens tokens,
    UserSecurityInfo? securityInfo,
    AuthMethod? authMethod,
    bool isBiometricEnabled = false,
    Map<String, dynamic> authMetadata = const {},
  }) {
    return UserAuthState(
      isAuthenticated: true,
      isLoading: false,
      userId: userId,
      tokens: tokens,
      securityInfo: securityInfo,
      lastAuthCheck: DateTime.now(),
      lastAuthMethod: authMethod,
      isBiometricEnabled: isBiometricEnabled,
      authMetadata: authMetadata,
    );
  }

  /// Create error state
  factory UserAuthState.error(AuthError error) {
    return UserAuthState(
      isAuthenticated: false,
      isLoading: false,
      error: error,
      lastAuthCheck: DateTime.now(),
    );
  }

  /// Create reauth required state
  factory UserAuthState.reauthRequired({
    String? userId,
    AuthTokens? tokens,
    String? reason,
  }) {
    return UserAuthState(
      isAuthenticated: false,
      isLoading: false,
      userId: userId,
      tokens: tokens,
      requiresReauth: true,
      error: reason != null ? AuthError.reauthRequired(reason) : null,
      lastAuthCheck: DateTime.now(),
    );
  }

  /// Check if tokens are valid and not expired
  bool get hasValidTokens {
    if (tokens == null) return false;
    return !tokens!.isExpired;
  }

  /// Check if refresh token is available and valid
  bool get canRefreshTokens {
    if (tokens?.refreshToken == null) return false;
    return !tokens!.isRefreshTokenExpired;
  }

  /// Check if session needs refresh
  bool get needsTokenRefresh {
    if (!isAuthenticated || tokens == null) return false;
    return tokens!.needsRefresh;
  }

  /// Check if auth state is stable (not loading, no pending operations)
  bool get isStable => !isLoading && !requiresReauth;

  /// Get time since last auth check
  Duration? get timeSinceLastCheck {
    if (lastAuthCheck == null) return null;
    return DateTime.now().difference(lastAuthCheck!);
  }

  /// Check if auth check is stale (older than specified duration)
  bool isAuthCheckStale(Duration maxAge) {
    final lastCheck = timeSinceLastCheck;
    if (lastCheck == null) return true;
    return lastCheck > maxAge;
  }

  UserAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userId,
    AuthTokens? tokens,
    UserSecurityInfo? securityInfo,
    AuthError? error,
    DateTime? lastAuthCheck,
    AuthMethod? lastAuthMethod,
    bool? requiresReauth,
    bool? isBiometricEnabled,
    Map<String, dynamic>? authMetadata,
  }) {
    return UserAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      tokens: tokens ?? this.tokens,
      securityInfo: securityInfo ?? this.securityInfo,
      error: error ?? this.error,
      lastAuthCheck: lastAuthCheck ?? this.lastAuthCheck,
      lastAuthMethod: lastAuthMethod ?? this.lastAuthMethod,
      requiresReauth: requiresReauth ?? this.requiresReauth,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      authMetadata: authMetadata ?? this.authMetadata,
    );
  }

  /// Clear authentication data
  UserAuthState clearAuth() {
    return const UserAuthState();
  }

  /// Update tokens while maintaining other state
  UserAuthState updateTokens(AuthTokens newTokens) {
    return copyWith(
      tokens: newTokens,
      lastAuthCheck: DateTime.now(),
      error: null,
    );
  }

  /// Mark as requiring reauthentication
  UserAuthState markReauthRequired(String reason) {
    return copyWith(
      isAuthenticated: false,
      requiresReauth: true,
      error: AuthError.reauthRequired(reason),
      lastAuthCheck: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isAuthenticated': isAuthenticated,
      'isLoading': isLoading,
      'userId': userId,
      'tokens': tokens?.toJson(),
      'securityInfo': securityInfo?.toJson(),
      'error': error?.toJson(),
      'lastAuthCheck': lastAuthCheck?.toIso8601String(),
      'lastAuthMethod': lastAuthMethod?.toString(),
      'requiresReauth': requiresReauth,
      'isBiometricEnabled': isBiometricEnabled,
      'authMetadata': authMetadata,
    };
  }

  factory UserAuthState.fromJson(Map<String, dynamic> json) {
    return UserAuthState(
      isAuthenticated: json['isAuthenticated'] ?? false,
      isLoading: json['isLoading'] ?? false,
      userId: json['userId'],
      tokens: json['tokens'] != null ? AuthTokens.fromJson(json['tokens']) : null,
      securityInfo: json['securityInfo'] != null 
          ? UserSecurityInfo.fromJson(json['securityInfo']) 
          : null,
      error: json['error'] != null ? AuthError.fromJson(json['error']) : null,
      lastAuthCheck: json['lastAuthCheck'] != null 
          ? DateTime.parse(json['lastAuthCheck']) 
          : null,
      lastAuthMethod: json['lastAuthMethod'] != null 
          ? AuthMethod.values.firstWhere((e) => e.toString() == json['lastAuthMethod'])
          : null,
      requiresReauth: json['requiresReauth'] ?? false,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      authMetadata: Map<String, dynamic>.from(json['authMetadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated, isLoading, userId, tokens, securityInfo,
    error, lastAuthCheck, lastAuthMethod, requiresReauth,
    isBiometricEnabled, authMetadata,
  ];
}

/// Authentication tokens model
class AuthTokens extends Equatable {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime expiresAt;
  final DateTime? refreshExpiresAt;
  final List<String> scopes;
  final Map<String, dynamic> claims;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresAt,
    this.refreshExpiresAt,
    this.scopes = const [],
    this.claims = const {},
  });

  /// Check if access token is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Check if refresh token is expired
  bool get isRefreshTokenExpired {
    if (refreshExpiresAt == null) return false;
    return DateTime.now().isAfter(refreshExpiresAt!);
  }

  /// Check if token needs refresh (expires within 5 minutes)
  bool get needsRefresh {
    final refreshThreshold = expiresAt.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshThreshold);
  }

  /// Get time remaining until expiry
  Duration get timeUntilExpiry {
    return expiresAt.difference(DateTime.now());
  }

  /// Get authorization header value
  String get authorizationHeader {
    return '$tokenType $accessToken';
  }

  /// Check if token has specific scope
  bool hasScope(String scope) {
    return scopes.contains(scope);
  }

  /// Get claim value
  T? getClaim<T>(String key) {
    return claims[key] as T?;
  }

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
    DateTime? refreshExpiresAt,
    List<String>? scopes,
    Map<String, dynamic>? claims,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
      refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
      scopes: scopes ?? this.scopes,
      claims: claims ?? this.claims,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresAt': expiresAt.toIso8601String(),
      'refreshExpiresAt': refreshExpiresAt?.toIso8601String(),
      'scopes': scopes,
      'claims': claims,
    };
  }

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresAt: DateTime.parse(json['expiresAt']),
      refreshExpiresAt: json['refreshExpiresAt'] != null 
          ? DateTime.parse(json['refreshExpiresAt']) 
          : null,
      scopes: List<String>.from(json['scopes'] ?? []),
      claims: Map<String, dynamic>.from(json['claims'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    accessToken, refreshToken, tokenType, expiresAt,
    refreshExpiresAt, scopes, claims,
  ];
}

/// User security information
class UserSecurityInfo extends Equatable {
  final List<SecurityDevice> trustedDevices;
  final List<AuthSession> activeSessions;
  final DateTime? lastPasswordChange;
  final bool hasTwoFactorAuth;
  final List<String> backupCodes;
  final SecuritySettings securitySettings;
  final List<SecurityEvent> recentEvents;
  final Map<String, dynamic> securityMetadata;

  const UserSecurityInfo({
    this.trustedDevices = const [],
    this.activeSessions = const [],
    this.lastPasswordChange,
    this.hasTwoFactorAuth = false,
    this.backupCodes = const [],
    required this.securitySettings,
    this.recentEvents = const [],
    this.securityMetadata = const {},
  });

  /// Check if current device is trusted
  bool isDeviceTrusted(String deviceId) {
    return trustedDevices.any((device) => device.deviceId == deviceId);
  }

  /// Get active session count
  int get activeSessionCount => activeSessions.length;

  /// Check if password needs update (older than specified duration)
  bool passwordNeedsUpdate(Duration maxAge) {
    if (lastPasswordChange == null) return true;
    return DateTime.now().difference(lastPasswordChange!) > maxAge;
  }

  /// Get recent security events of specific type
  List<SecurityEvent> getEventsByType(SecurityEventType type) {
    return recentEvents.where((event) => event.type == type).toList();
  }

  UserSecurityInfo copyWith({
    List<SecurityDevice>? trustedDevices,
    List<AuthSession>? activeSessions,
    DateTime? lastPasswordChange,
    bool? hasTwoFactorAuth,
    List<String>? backupCodes,
    SecuritySettings? securitySettings,
    List<SecurityEvent>? recentEvents,
    Map<String, dynamic>? securityMetadata,
  }) {
    return UserSecurityInfo(
      trustedDevices: trustedDevices ?? this.trustedDevices,
      activeSessions: activeSessions ?? this.activeSessions,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      hasTwoFactorAuth: hasTwoFactorAuth ?? this.hasTwoFactorAuth,
      backupCodes: backupCodes ?? this.backupCodes,
      securitySettings: securitySettings ?? this.securitySettings,
      recentEvents: recentEvents ?? this.recentEvents,
      securityMetadata: securityMetadata ?? this.securityMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trustedDevices': trustedDevices.map((d) => d.toJson()).toList(),
      'activeSessions': activeSessions.map((s) => s.toJson()).toList(),
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'hasTwoFactorAuth': hasTwoFactorAuth,
      'backupCodes': backupCodes,
      'securitySettings': securitySettings.toJson(),
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
      'securityMetadata': securityMetadata,
    };
  }

  factory UserSecurityInfo.fromJson(Map<String, dynamic> json) {
    return UserSecurityInfo(
      trustedDevices: (json['trustedDevices'] as List<dynamic>?)
          ?.map((d) => SecurityDevice.fromJson(d))
          .toList() ?? [],
      activeSessions: (json['activeSessions'] as List<dynamic>?)
          ?.map((s) => AuthSession.fromJson(s))
          .toList() ?? [],
      lastPasswordChange: json['lastPasswordChange'] != null 
          ? DateTime.parse(json['lastPasswordChange']) 
          : null,
      hasTwoFactorAuth: json['hasTwoFactorAuth'] ?? false,
      backupCodes: List<String>.from(json['backupCodes'] ?? []),
      securitySettings: SecuritySettings.fromJson(json['securitySettings']),
      recentEvents: (json['recentEvents'] as List<dynamic>?)
          ?.map((e) => SecurityEvent.fromJson(e))
          .toList() ?? [],
      securityMetadata: Map<String, dynamic>.from(json['securityMetadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    trustedDevices, activeSessions, lastPasswordChange,
    hasTwoFactorAuth, backupCodes, securitySettings,
    recentEvents, securityMetadata,
  ];
}

/// Authentication error model
class AuthError extends Equatable {
  final AuthErrorType type;
  final String message;
  final String? code;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const AuthError({
    required this.type,
    required this.message,
    this.code,
    this.details = const {},
    required this.timestamp,
  });

  factory AuthError.invalidCredentials([String? message]) {
    return AuthError(
      type: AuthErrorType.invalidCredentials,
      message: message ?? 'Invalid email or password',
      code: 'INVALID_CREDENTIALS',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.accountDisabled([String? message]) {
    return AuthError(
      type: AuthErrorType.accountDisabled,
      message: message ?? 'Account has been disabled',
      code: 'ACCOUNT_DISABLED',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.tooManyAttempts([String? message]) {
    return AuthError(
      type: AuthErrorType.tooManyAttempts,
      message: message ?? 'Too many failed attempts. Please try again later.',
      code: 'TOO_MANY_ATTEMPTS',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.tokenExpired([String? message]) {
    return AuthError(
      type: AuthErrorType.tokenExpired,
      message: message ?? 'Authentication token has expired',
      code: 'TOKEN_EXPIRED',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.networkError([String? message]) {
    return AuthError(
      type: AuthErrorType.networkError,
      message: message ?? 'Network connection error',
      code: 'NETWORK_ERROR',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.reauthRequired([String? message]) {
    return AuthError(
      type: AuthErrorType.reauthRequired,
      message: message ?? 'Please sign in again to continue',
      code: 'REAUTH_REQUIRED',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.biometricNotAvailable([String? message]) {
    return AuthError(
      type: AuthErrorType.biometricNotAvailable,
      message: message ?? 'Biometric authentication not available',
      code: 'BIOMETRIC_NOT_AVAILABLE',
      timestamp: DateTime.now(),
    );
  }

  factory AuthError.unknown(String message, [String? code]) {
    return AuthError(
      type: AuthErrorType.unknown,
      message: message,
      code: code ?? 'UNKNOWN_ERROR',
      timestamp: DateTime.now(),
    );
  }

  bool get isRetryable {
    return type == AuthErrorType.networkError ||
           type == AuthErrorType.serverError ||
           type == AuthErrorType.timeout;
  }

  bool get requiresUserAction {
    return type == AuthErrorType.invalidCredentials ||
           type == AuthErrorType.accountDisabled ||
           type == AuthErrorType.reauthRequired ||
           type == AuthErrorType.twoFactorRequired;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'message': message,
      'code': code,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuthError.fromJson(Map<String, dynamic> json) {
    return AuthError(
      type: AuthErrorType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AuthErrorType.unknown,
      ),
      message: json['message'],
      code: json['code'],
      details: Map<String, dynamic>.from(json['details'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object?> get props => [type, message, code, details, timestamp];
}

/// Security device model
class SecurityDevice extends Equatable {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final DateTime firstSeen;
  final DateTime lastUsed;
  final bool isTrusted;
  final String? location;
  final String? ipAddress;

  const SecurityDevice({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.firstSeen,
    required this.lastUsed,
    this.isTrusted = false,
    this.location,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'firstSeen': firstSeen.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'isTrusted': isTrusted,
      'location': location,
      'ipAddress': ipAddress,
    };
  }

  factory SecurityDevice.fromJson(Map<String, dynamic> json) {
    return SecurityDevice(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      firstSeen: DateTime.parse(json['firstSeen']),
      lastUsed: DateTime.parse(json['lastUsed']),
      isTrusted: json['isTrusted'] ?? false,
      location: json['location'],
      ipAddress: json['ipAddress'],
    );
  }

  @override
  List<Object?> get props => [
    deviceId, deviceName, deviceType, firstSeen,
    lastUsed, isTrusted, location, ipAddress,
  ];
}

/// Authentication session model
class AuthSession extends Equatable {
  final String sessionId;
  final DateTime startTime;
  final DateTime? endTime;
  final String deviceId;
  final String? location;
  final String? ipAddress;
  final bool isActive;

  const AuthSession({
    required this.sessionId,
    required this.startTime,
    this.endTime,
    required this.deviceId,
    this.location,
    this.ipAddress,
    this.isActive = true,
  });

  Duration? get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'deviceId': deviceId,
      'location': location,
      'ipAddress': ipAddress,
      'isActive': isActive,
    };
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      deviceId: json['deviceId'],
      location: json['location'],
      ipAddress: json['ipAddress'],
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    sessionId, startTime, endTime, deviceId,
    location, ipAddress, isActive,
  ];
}

/// Security settings model
class SecuritySettings extends Equatable {
  final bool requireTwoFactor;
  final bool allowRememberDevice;
  final Duration sessionTimeout;
  final bool requirePasswordChange;
  final int maxLoginAttempts;
  final Duration lockoutDuration;

  const SecuritySettings({
    this.requireTwoFactor = false,
    this.allowRememberDevice = true,
    this.sessionTimeout = const Duration(hours: 24),
    this.requirePasswordChange = false,
    this.maxLoginAttempts = 5,
    this.lockoutDuration = const Duration(minutes: 15),
  });

  Map<String, dynamic> toJson() {
    return {
      'requireTwoFactor': requireTwoFactor,
      'allowRememberDevice': allowRememberDevice,
      'sessionTimeout': sessionTimeout.inSeconds,
      'requirePasswordChange': requirePasswordChange,
      'maxLoginAttempts': maxLoginAttempts,
      'lockoutDuration': lockoutDuration.inSeconds,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      requireTwoFactor: json['requireTwoFactor'] ?? false,
      allowRememberDevice: json['allowRememberDevice'] ?? true,
      sessionTimeout: Duration(seconds: json['sessionTimeout'] ?? 86400),
      requirePasswordChange: json['requirePasswordChange'] ?? false,
      maxLoginAttempts: json['maxLoginAttempts'] ?? 5,
      lockoutDuration: Duration(seconds: json['lockoutDuration'] ?? 900),
    );
  }

  @override
  List<Object?> get props => [
    requireTwoFactor, allowRememberDevice, sessionTimeout,
    requirePasswordChange, maxLoginAttempts, lockoutDuration,
  ];
}

/// Security event model
class SecurityEvent extends Equatable {
  final String eventId;
  final SecurityEventType type;
  final String description;
  final DateTime timestamp;
  final String? deviceId;
  final String? location;
  final String? ipAddress;
  final Map<String, dynamic> metadata;

  const SecurityEvent({
    required this.eventId,
    required this.type,
    required this.description,
    required this.timestamp,
    this.deviceId,
    this.location,
    this.ipAddress,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'type': type.toString(),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'location': location,
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      eventId: json['eventId'],
      type: SecurityEventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SecurityEventType.other,
      ),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      deviceId: json['deviceId'],
      location: json['location'],
      ipAddress: json['ipAddress'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
    eventId, type, description, timestamp,
    deviceId, location, ipAddress, metadata,
  ];
}

/// Enums
enum AuthMethod {
  emailPassword,
  google,
  apple,
  facebook,
  biometric,
  twoFactor,
  sso,
}

enum AuthErrorType {
  invalidCredentials,
  accountDisabled,
  tooManyAttempts,
  tokenExpired,
  tokenInvalid,
  networkError,
  serverError,
  timeout,
  reauthRequired,
  twoFactorRequired,
  biometricNotAvailable,
  biometricFailed,
  unknown,
}

enum SecurityEventType {
  login,
  logout,
  passwordChange,
  twoFactorEnabled,
  twoFactorDisabled,
  deviceTrusted,
  deviceRemoved,
  suspiciousActivity,
  accountLocked,
  accountUnlocked,
  other,
}
