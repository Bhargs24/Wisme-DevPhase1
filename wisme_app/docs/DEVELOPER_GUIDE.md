# 👨‍💻 Wisme Developer Guide

*Complete development guide for building, extending, and maintaining the Wisme platform*

---

## 🎯 Getting Started

### 📋 Prerequisites

**Required Software**:
- Flutter SDK >=3.7.2
- Dart SDK >=3.7.2
- Android Studio / VS Code
- Git

**Platform Requirements**:
- **Android**: API Level 21+ (Android 5.0)
- **iOS**: iOS 12.0+
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

### 🚀 Quick Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd wisme_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

4. **Run Tests**
   ```bash
   flutter test
   flutter test integration_test/
   ```

---

## 🏗️ Project Architecture

### 📁 Directory Structure

```
lib/
├── 🎯 main.dart                    # App entry point
├── 📱 app.dart                     # Main app configuration
├── 🛣️ routes.dart                  # Navigation routing
├── constants/                      # App-wide constants
│   ├── app_assets.dart            # Asset paths and references
│   ├── app_colors.dart            # Color palette
│   └── app_text_styles.dart       # Typography styles
├── models/                         # Data models
│   ├── user_model.dart            # User data structure
│   ├── lesson_model.dart          # Lesson content model
│   └── coach_model.dart           # AI coach model
├── providers/                      # State management
│   ├── user_provider.dart         # User state management
│   ├── lesson_provider.dart       # Lesson state management
│   ├── audio_provider.dart        # Audio playback state
│   ├── coach_provider.dart        # AI coach state
│   ├── voice_provider.dart        # Voice/TTS state
│   └── settings_provider.dart     # App settings state
├── services/                       # Business logic services
│   ├── auth_services.dart         # Authentication
│   ├── firestore_service.dart     # Database operations
│   ├── gpt_service.dart          # AI content generation
│   ├── tts_service.dart          # Text-to-speech
│   ├── elevenlabs_service.dart    # Premium voice synthesis
│   ├── audio_player_service.dart  # Audio playback
│   ├── storage_service.dart       # File storage
│   ├── cache_service.dart         # Caching system
│   └── notification_service.dart  # Push notifications
├── UI/                            # User interface
│   ├── screens/                   # App screens
│   │   ├── onboarding/           # Onboarding flow
│   │   ├── auth/                 # Authentication screens
│   │   ├── dashboard/            # Main dashboard
│   │   ├── lessons/              # Learning content
│   │   ├── profile/              # User profile
│   │   ├── settings/             # App settings
│   │   └── achievements/         # Gamification
│   └── widgets/                   # Reusable UI components
│       ├── common/               # Generic widgets
│       ├── audio/                # Audio-specific widgets
│       ├── learning/             # Learning-specific widgets
│       └── navigation/           # Navigation widgets
└── utils/                         # Utility functions
    ├── api_keys.dart             # API configuration
    ├── helper_functions.dart     # Common utilities
    └── logger.dart               # Logging system
```

### 🧱 Architecture Patterns

**1. Provider Pattern (State Management)**
```dart
// Provider usage example
class LessonProvider extends ChangeNotifier {
  List<Lesson> _lessons = [];
  
  List<Lesson> get lessons => _lessons;
  
  Future<void> loadLessons() async {
    _lessons = await LessonService.fetchLessons();
    notifyListeners();
  }
}

// Usage in widget
Consumer<LessonProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.lessons.length,
      itemBuilder: (context, index) => LessonTile(provider.lessons[index]),
    );
  },
)
```

**2. Service Layer Pattern**
```dart
// Service interface
abstract class StorageService {
  Future<void> saveData(String key, dynamic data);
  Future<T?> loadData<T>(String key);
  Future<void> deleteData(String key);
}

// Implementation
class LocalStorageService implements StorageService {
  // Implementation details
}
```

**3. Repository Pattern**
```dart
// Repository for data access abstraction
class LessonRepository {
  final FirestoreService _firestore;
  final CacheService _cache;
  
  Future<List<Lesson>> getLessons() async {
    // Try cache first, then firestore
    final cached = await _cache.get('lessons');
    if (cached != null) return cached;
    
    final lessons = await _firestore.getLessons();
    await _cache.set('lessons', lessons);
    return lessons;
  }
}
```

---

## 🛠️ Development Workflow

### 🔄 Git Workflow

**Branch Strategy**:
```
main                    # Production-ready code
├── develop            # Integration branch
├── feature/user-auth  # Feature branches
├── feature/audio-player
├── hotfix/critical-bug # Hotfix branches
└── release/v1.1.0     # Release branches
```

**Commit Convention**:
```
feat: add user authentication
fix: resolve audio playback issue
docs: update API documentation
style: format code according to standards
refactor: restructure provider architecture
test: add unit tests for audio service
chore: update dependencies
```

### 🧪 Testing Strategy

**1. Unit Tests**
```dart
// Example unit test
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LessonService Tests', () {
    late LessonService service;
    late MockFirestoreService mockFirestore;
    
    setUp(() {
      mockFirestore = MockFirestoreService();
      service = LessonService(mockFirestore);
    });
    
    test('should fetch lessons successfully', () async {
      // Arrange
      final mockLessons = [Lesson(id: '1', title: 'Test')];
      when(mockFirestore.getLessons()).thenAnswer((_) => Future.value(mockLessons));
      
      // Act
      final result = await service.fetchLessons();
      
      // Assert
      expect(result, equals(mockLessons));
      verify(mockFirestore.getLessons()).called(1);
    });
  });
}
```

**2. Widget Tests**
```dart
// Example widget test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LessonTile displays lesson title', (WidgetTester tester) async {
    // Arrange
    final lesson = Lesson(id: '1', title: 'Test Lesson');
    
    // Act
    await tester.pumpWidget(
      MaterialApp(home: LessonTile(lesson: lesson)),
    );
    
    // Assert
    expect(find.text('Test Lesson'), findsOneWidget);
  });
}
```

**3. Integration Tests**
```dart
// Example integration test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('User Authentication Flow', () {
    testWidgets('user can sign in with Google', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      
      // Find and tap sign in button
      await tester.tap(find.byKey(Key('google_sign_in_button')));
      await tester.pumpAndSettle();
      
      // Verify navigation to dashboard
      expect(find.byKey(Key('dashboard_screen')), findsOneWidget);
    });
  });
}
```

### 🚀 Build & Deployment

**Development Build**:
```bash
# Debug build
flutter run --debug

# Profile build (performance testing)
flutter run --profile

# Release build
flutter run --release
```

**Platform-Specific Builds**:
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

**Environment Configuration**:
```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.wisme.dev',
  );
  
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String elevenlabsApiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
  
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
}
```

---

## 🔧 Configuration & Setup

### 🔑 API Keys Configuration

**1. Create `lib/utils/api_keys.dart`**:
```dart
class ApiKeys {
  // OpenAI Configuration
  static const String openaiApiKey = 'your-openai-api-key';
  static const String openaiOrganization = 'your-org-id';
  
  // ElevenLabs Configuration
  static const String elevenlabsApiKey = 'your-elevenlabs-api-key';
  
  // Firebase Configuration (handled by Firebase CLI)
  // See firebase_options.dart for auto-generated config
  
  // Other API Keys
  static const String googleSignInClientId = 'your-google-client-id';
}
```

### 🔥 Firebase Setup

**1. Install Firebase CLI**:
```bash
npm install -g firebase-tools
firebase login
```

**2. Configure Firebase Project**:
```bash
firebase projects:create wisme-app
firebase use wisme-app
```

**3. Enable Firebase Services**:
```bash
firebase init firestore
firebase init auth
firebase init storage
firebase init functions
```

**4. Flutter Firebase Configuration**:
```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage

dart pub global activate flutterfire_cli
flutterfire configure
```

### 📱 Platform-Specific Configuration

**Android Configuration** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

**iOS Configuration** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for profile pictures.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-fetch</string>
</array>
```

---

## 🎨 UI Development Guidelines

### 🎭 Design System Usage

**1. Colors**:
```dart
// Use predefined colors from AppColors
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: AppTextStyles.headline1.copyWith(
      color: AppColors.onPrimary,
    ),
  ),
)
```

**2. Spacing**:
```dart
// Use consistent spacing
Padding(
  padding: const EdgeInsets.all(AppSpacing.medium),
  child: Column(
    children: [
      Widget1(),
      SizedBox(height: AppSpacing.small),
      Widget2(),
    ],
  ),
)
```

**3. Custom Widgets**:
```dart
// Create reusable widgets
class WismeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  
  const WismeButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _getButtonStyle(type),
      child: Text(text),
    );
  }
}
```

### 📱 Responsive Design

```dart
// Use LayoutBuilder for responsive design
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  },
)

// Use MediaQuery for screen information
final screenSize = MediaQuery.of(context).size;
final isTablet = screenSize.width > 600;
```

---

## 🔌 API Integration

### 🧠 OpenAI Integration

```dart
class GPTService {
  static const String baseUrl = 'https://api.openai.com/v1';
  
  Future<String> generateLessonContent({
    required String topic,
    required String difficulty,
    required String style,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${ApiKeys.openaiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert educational content creator...',
          },
          {
            'role': 'user',
            'content': 'Create a lesson about $topic for $difficulty level...',
          },
        ],
        'max_tokens': 2000,
        'temperature': 0.7,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to generate content: ${response.statusCode}');
    }
  }
}
```

### 🗣️ ElevenLabs Integration

```dart
class ElevenLabsService {
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  Future<Uint8List> synthesizeSpeech({
    required String text,
    required String voiceId,
    Map<String, dynamic>? voiceSettings,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/text-to-speech/$voiceId'),
      headers: {
        'xi-api-key': ApiKeys.elevenlabsApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'voice_settings': voiceSettings ?? {
          'stability': 0.5,
          'similarity_boost': 0.5,
        },
      }),
    );
    
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to synthesize speech: ${response.statusCode}');
    }
  }
}
```

---

## 🐛 Debugging & Troubleshooting

### 🔍 Debug Tools

**1. Flutter Inspector**:
```bash
# Enable inspector
flutter run --debug
# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

**2. Logging System**:
```dart
// Use the logger utility
import 'package:wisme_app/utils/logger.dart';

logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

**3. Performance Profiling**:
```bash
# Profile performance
flutter run --profile
flutter run --trace-startup
```

### 🚨 Common Issues & Solutions

**1. Build Issues**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Clear Gradle cache (Android)
cd android
./gradlew clean
cd ..
```

**2. API Connection Issues**:
```dart
// Add timeout and retry logic
final dio = Dio();
dio.options.connectTimeout = Duration(seconds: 30);
dio.options.receiveTimeout = Duration(seconds: 30);

// Add interceptor for retry logic
dio.interceptors.add(RetryInterceptor(
  dio: dio,
  options: RetryOptions(
    retries: 3,
    retryInterval: Duration(seconds: 2),
  ),
));
```

**3. State Management Issues**:
```dart
// Ensure proper provider usage
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 📚 Best Practices

### 💡 Code Quality

**1. Follow Dart Style Guide**:
```dart
// Good: descriptive names
final List<Lesson> userCompletedLessons = [];

// Bad: unclear abbreviations
final List<Lesson> usrCmpltLsns = [];

// Good: const constructors
class WismeButton extends StatelessWidget {
  const WismeButton({super.key, required this.title});
  final String title;
}
```

**2. Error Handling**:
```dart
// Use try-catch with specific exceptions
Future<List<Lesson>> fetchLessons() async {
  try {
    final response = await api.getLessons();
    return response.data.map((json) => Lesson.fromJson(json)).toList();
  } on NetworkException catch (e) {
    logger.e('Network error: ${e.message}');
    throw NetworkException('Failed to fetch lessons');
  } on JsonException catch (e) {
    logger.e('Parsing error: ${e.message}');
    throw DataException('Invalid lesson data format');
  } catch (e) {
    logger.e('Unexpected error: $e');
    throw UnknownException('An unexpected error occurred');
  }
}
```

**3. Performance Optimization**:
```dart
// Use const widgets when possible
const Text('Static text');

// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// Implement proper dispose methods
class AudioPlayerWidget extends StatefulWidget {
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  
  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }
  
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
```

### 🔒 Security Best Practices

**1. API Key Security**:
```dart
// Never commit API keys to version control
// Use environment variables or secure storage
class SecureApiKeys {
  static Future<String> getOpenAIKey() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'openai_api_key') ?? '';
  }
}
```

**2. Input Validation**:
```dart
// Validate user inputs
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email is required';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    return 'Please enter a valid email';
  }
  return null;
}
```

**3. Secure Network Requests**:
```dart
// Use certificate pinning for production
class SecureHttpClient {
  static Dio createSecureClient() {
    final dio = Dio();
    
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        // Implement certificate validation
        return validateCertificate(cert, host);
      };
      return client;
    };
    
    return dio;
  }
}
```

---

## 🚀 Advanced Development

### 🔮 Custom Plugins

**Creating a Custom Plugin**:
```bash
# Create plugin
flutter create --template=plugin wisme_audio_plugin

# Plugin structure
lib/
├── wisme_audio_plugin.dart
└── src/
    ├── audio_engine.dart
    └── platform_interface.dart

android/src/main/kotlin/
└── com/wisme/audio/WismeAudioPlugin.kt

ios/Classes/
└── WismeAudioPlugin.swift
```

### 🧪 Advanced Testing

**Golden Tests for UI**:
```dart
testWidgets('golden test for lesson card', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LessonCard(lesson: mockLesson),
      ),
    ),
  );
  
  await expectLater(
    find.byType(LessonCard),
    matchesGoldenFile('lesson_card.png'),
  );
});
```

**Performance Tests**:
```dart
void main() {
  testWidgets('lesson list performance', (WidgetTester tester) async {
    // Create large dataset
    final lessons = List.generate(1000, (i) => Lesson(id: '$i'));
    
    // Measure performance
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(
      MaterialApp(
        home: LessonList(lessons: lessons),
      ),
    );
    
    stopwatch.stop();
    
    // Assert performance requirements
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
```

### 🎯 Code Generation

**Using build_runner for code generation**:
```bash
# Add dependencies
flutter pub add json_annotation
flutter pub add --dev build_runner json_serializable

# Generate code
flutter pub run build_runner build
flutter pub run build_runner watch  # For continuous generation
```

```dart
// Model with JSON serialization
@JsonSerializable()
class Lesson {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  
  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });
  
  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
```

This comprehensive developer guide provides everything needed to successfully develop, test, and maintain the Wisme platform. Follow these guidelines to ensure code quality, performance, and maintainability.
