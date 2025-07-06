import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/wisme_app_v2.dart';
import 'core/initialization/app_initialization_service_v2.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    AppLogger.info('🚀 Wisme App: Starting initialization...');
    
    // Initialize all production services with the new architecture
    await AppInitializationServiceV2.initialize();
    
    AppLogger.info('✅ Wisme App: Initialization completed, starting app...');
    runApp(const WismeAppV2());
  } catch (e) {
    AppLogger.error('❌ Wisme App: Critical initialization failure: $e');
    
    // If initialization fails, show error and allow graceful degradation
    runApp(_buildErrorApp(e));
  }
}

/// Build error app for initialization failures
Widget _buildErrorApp(Object error) {
  return MaterialApp(
    title: 'Wisme - Initialization Error',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Wisme Initialization Failed',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We encountered an issue starting the app. This might be due to network connectivity or device compatibility.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Technical Details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Restart the app
                    AppInitializationServiceV2.reset();
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart App'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Show more details or contact support
                  showDialog(
                    context: NavigationService.navigatorKey.currentContext!,
                    builder: (context) => AlertDialog(
                      title: const Text('Need Help?'),
                      content: const Text(
                        'If this issue persists, please check your internet connection and try again. For further assistance, contact our support team.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Need Help?'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Navigation service for global navigation
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
