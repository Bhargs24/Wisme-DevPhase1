import '../core/exports.dart';

class ProviderSetup {
  
  /// Create all providers with proper dependency injection
  static MultiProvider createProviders({required Widget child}) {
    return MultiProvider(
      providers: [
        // Services (can be accessed via context.read<Service>)
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<GPTService>(
          create: (_) => GPTService(),
        ),
        Provider<TTSService>(
          create: (_) => TTSService(),
        ),
        Provider<ElevenLabsService>(
          create: (_) => ElevenLabsService(),
        ),
        Provider<ContentMatchingService>(
          create: (context) => ContentMatchingService(
            firestoreService: context.read<FirestoreService>(),
            gptService: context.read<GPTService>(),
          ),
        ),
        
        // Providers (stateful, can be accessed via context.watch<Provider>)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<LessonProvider>(
          create: (context) => LessonProvider(
            firestoreService: context.read<FirestoreService>(),
            gptService: context.read<GPTService>(),
            ttsService: context.read<TTSService>(),
            contentMatchingService: context.read<ContentMatchingService>(),
          ),
        ),
      ],
      child: child,
    );
  }

  /// Simple initialization - just log that providers are ready
  static Future<void> initializeServices(BuildContext context) async {
    AppLogger.info('🔧 Provider setup complete');
    AppLogger.info('✅ All services initialized');
  }

  /// Clean shutdown
  static Future<void> cleanup(BuildContext context) async {
    AppLogger.info('🧹 Cleaning up provider resources...');
    // Add any cleanup logic here if needed
    AppLogger.info('✅ Cleanup complete');
  }
}

