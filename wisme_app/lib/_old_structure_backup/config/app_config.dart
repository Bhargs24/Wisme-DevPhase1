/// Production-Ready App Configuration
/// 
/// This file contains all configuration for deployment-ready features

class AppConfig {
  // API Configuration - to be filled during deployment
  static const String openAIApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String elevenLabsApiKey = String.fromEnvironment('ELEVENLABS_API_KEY', defaultValue: '');
  static const String elevenLabsApiUrl = 'https://api.elevenlabs.io/v1';
  static const String openAIApiUrl = 'https://api.openai.com/v1';
  
  // Performance Configuration
  static const int maxCacheSizeMB = 500;
  static const int maxOfflineContentMB = 200;
  static const Duration cacheExpiryDuration = Duration(days: 7);
  static const Duration backgroundSyncInterval = Duration(minutes: 30);
  
  // Content Generation Configuration
  static const int maxContentBlocksPerSession = 10;
  static const Duration contentGenerationTimeout = Duration(seconds: 45);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // User Experience Configuration
  static const Duration audioLoadTimeout = Duration(seconds: 30);
  static const double defaultPlaybackSpeed = 1.0;
  static const int maxRecentContent = 50;
  static const int maxBookmarks = 100;
  
  // Analytics Configuration
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const Duration analyticsFlushInterval = Duration(minutes: 5);
  static const int maxAnalyticsEvents = 1000;
  
  // Security Configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const bool requireBiometricAuth = false;
  
  // Offline Configuration
  static const int maxOfflineActions = 100;
  static const Duration offlineSyncRetryInterval = Duration(minutes: 5);
  static const int maxOfflineRetryAttempts = 5;
  
  // Development vs Production flags
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const bool enableDebugLogging = !isProduction;
  static const bool enablePerformanceMonitoring = true;
  
  // Content Quality Configuration
  static const double minContentSimilarityThreshold = 0.7;
  static const int maxContentReuseAge = 30; // days
  static const double contentQualityThreshold = 0.8;
  
  /// Check if app is properly configured for production
  static bool get isConfiguredForProduction {
    return openAIApiKey.isNotEmpty && 
           elevenLabsApiKey.isNotEmpty &&
           isProduction;
  }
  
  /// Get configuration status for debugging
  static Map<String, dynamic> get configStatus => {
    'openai_configured': openAIApiKey.isNotEmpty,
    'elevenlabs_configured': elevenLabsApiKey.isNotEmpty,
    'is_production': isProduction,
    'enable_debug_logging': enableDebugLogging,
    'enable_analytics': enableAnalytics,
    'max_cache_size_mb': maxCacheSizeMB,
    'content_generation_timeout_seconds': contentGenerationTimeout.inSeconds,
  };
}

/// Environment-specific configurations
class EnvironmentConfig {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.wisme.com';
      case 'staging':
        return 'https://staging-api.wisme.com';
      default:
        return 'https://dev-api.wisme.com';
    }
  }
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'User-Agent': 'Wisme-App/${AppVersion.version}',
    'Environment': environment,
  };
}

/// App version and build information
class AppVersion {
  static const String version = '1.0.0';
  static const String buildNumber = String.fromEnvironment('BUILD_NUMBER', defaultValue: '1');
  static const String gitCommit = String.fromEnvironment('GIT_COMMIT', defaultValue: 'unknown');
  static const String buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: 'unknown');
  
  static String get fullVersion => '$version+$buildNumber';
  
  static Map<String, String> get buildInfo => {
    'version': version,
    'build_number': buildNumber,
    'git_commit': gitCommit,
    'build_date': buildDate,
    'environment': EnvironmentConfig.environment,
  };
}
