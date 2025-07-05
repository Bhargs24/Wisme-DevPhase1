# 🛠️ Wisme Development Setup Guide

*Complete development environment setup and configuration guide for the Wisme AI-powered microlearning platform*

---

## 🎯 Quick Start

### ⚡ 5-Minute Setup

**Prerequisites Check**:
```bash
# Verify Flutter installation
flutter doctor

# Check Dart version
dart --version

# Verify Git setup
git --version
```

**Project Setup**:
```bash
# Clone the repository
git clone <repository-url>
cd wisme_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📋 System Requirements

### 💻 Development Machine

**Minimum Requirements**:
- **OS**: Windows 10+, macOS 10.14+, or Ubuntu 18.04+
- **RAM**: 8GB (16GB recommended)
- **Storage**: 10GB free space
- **Processor**: Intel i5/AMD Ryzen 5 or better

**Recommended Specifications**:
- **OS**: Latest stable OS version
- **RAM**: 16GB+ for smooth development
- **Storage**: SSD with 20GB+ free space
- **Processor**: Intel i7/AMD Ryzen 7 or better
- **Graphics**: Dedicated GPU for emulator performance

### 📱 Target Platforms

**Mobile Platforms**:
- **Android**: API Level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+ (iPhone 6s and newer)

**Desktop Platforms** (Future Support):
- **Windows**: Windows 10+
- **macOS**: macOS 10.14+
- **Linux**: Ubuntu 18.04+

**Web Platform**:
- **Browsers**: Chrome, Firefox, Safari, Edge (latest versions)

---

## 🔧 Development Environment Setup

### 1️⃣ Flutter SDK Installation

#### **Windows Setup**
```powershell
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (PowerShell)
$env:PATH += ";C:\flutter\bin"

# Verify installation
flutter doctor
```

#### **macOS Setup**
```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

#### **Linux Setup**
```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Add to .bashrc for persistence
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc

# Verify installation
flutter doctor
```

### 2️⃣ IDE Configuration

#### **VS Code Setup** (Recommended)

**Install Extensions**:
```bash
# Essential Flutter extensions
code --install-extension dart-code.flutter
code --install-extension dart-code.dart-code
code --install-extension alexisvt.flutter-snippets
code --install-extension nash.awesome-flutter-snippets
code --install-extension usernamehw.errorlens
```

**VS Code Settings** (`.vscode/settings.json`):
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.flutterSdkPath": "path/to/flutter",
  "dart.lineLength": 80,
  "dart.showInspectorNotificationsForWidgetErrors": true,
  "flutter.experiments.fastReload": true
}
```

#### **Android Studio Setup**

**Install Plugins**:
- Flutter plugin
- Dart plugin
- Flutter Inspector
- Flutter Widget Snippets

**Configure SDK Paths**:
1. File → Settings → Languages & Frameworks → Flutter
2. Set Flutter SDK path
3. Set Dart SDK path (auto-detected)

### 3️⃣ Platform-Specific Setup

#### **Android Development**

**Install Android Studio**:
1. Download Android Studio
2. Install Android SDK
3. Set up Android Virtual Device (AVD)

**SDK Configuration**:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Configure SDK path
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

**Create AVD**:
```bash
# List available system images
avdmanager list

# Create AVD
avdmanager create avd -n pixel_4 -k "system-images;android-30;google_apis;x86_64"

# Start emulator
emulator -avd pixel_4
```

#### **iOS Development** (macOS only)

**Install Xcode**:
1. Download Xcode from App Store
2. Install Xcode Command Line Tools
3. Set up iOS Simulator

**Xcode Configuration**:
```bash
# Install command line tools
xcode-select --install

# Open iOS Simulator
open -a Simulator

# Accept Xcode license
sudo xcodebuild -license accept
```

**CocoaPods Setup**:
```bash
# Install CocoaPods
sudo gem install cocoapods

# Initialize pods
cd ios
pod install
```

---

## 🔑 API Keys & Configuration

### 🛡️ Environment Variables

**Create `.env` file** (root directory):
```env
# OpenAI Configuration
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_ORGANIZATION_ID=your-org-id-here

# ElevenLabs Configuration
ELEVENLABS_API_KEY=your-elevenlabs-api-key-here

# Environment Configuration
ENVIRONMENT=development
DEBUG_MODE=true
LOG_LEVEL=info

# Feature Flags
ENABLE_PREMIUM_FEATURES=false
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

**API Keys Configuration** (`lib/utils/api_keys.dart`):
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  // Load from environment variables
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get elevenlabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  
  // Development defaults (for local testing)
  static const String defaultOpenAIKey = 'sk-dev-key-here';
  static const String defaultElevenLabsKey = 'el-dev-key-here';
  
  // Validation
  static bool get hasValidKeys => 
      openaiApiKey.isNotEmpty && elevenlabsApiKey.isNotEmpty;
}
```

### 🔥 Firebase Configuration

**Install Firebase CLI**:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init
```

**Flutter Firebase Setup**:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Generate configuration files
flutterfire configure --project=your-project-id
```

**Add Firebase Dependencies** (`pubspec.yaml`):
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8
```

---

## 📦 Dependencies & Packages

### 🔧 Core Dependencies

**State Management**:
```yaml
provider: ^6.1.1              # State management
flutter_riverpod: ^2.4.9      # Alternative state management
```

**Networking**:
```yaml
http: ^1.1.2                  # HTTP client
dio: ^5.4.0                   # Advanced HTTP client
connectivity_plus: ^5.0.2     # Network connectivity
```

**Storage**:
```yaml
shared_preferences: ^2.2.2    # Simple key-value storage
flutter_secure_storage: ^9.0.0 # Secure storage
path_provider: ^2.1.1         # File system paths
hive: ^2.2.3                  # Local database
```

**Audio & Media**:
```yaml
audioplayers: ^5.2.1          # Audio playback
flutter_tts: ^3.8.3           # Text-to-speech
record: ^5.0.4                # Audio recording
waveform: ^0.2.0              # Waveform visualization
```

**UI & Animation**:
```yaml
animations: ^2.0.8            # Pre-built animations
lottie: ^2.7.0               # Lottie animations
shimmer: ^3.0.0              # Loading shimmer effect
cached_network_image: ^3.3.0  # Image caching
```

### 🧪 Development Dependencies

**Testing**:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4              # Mocking framework
  bloc_test: ^9.1.5            # BLoC testing utilities
  integration_test:
    sdk: flutter
  test: ^1.24.9                # Core testing framework
```

**Code Generation**:
```yaml
build_runner: ^2.4.7          # Code generation
json_annotation: ^4.8.1       # JSON serialization
freezed: ^2.4.6               # Data classes
injectable: ^2.3.2            # Dependency injection
```

**Analysis & Formatting**:
```yaml
flutter_lints: ^3.0.1         # Linting rules
dart_code_metrics: ^5.7.6     # Code metrics
very_good_analysis: ^5.1.0    # Additional lints
```

---

## 🏗️ Project Structure

### 📁 Directory Organization

```
wisme_app/
├── 📱 android/                 # Android platform code
├── 🍎 ios/                     # iOS platform code
├── 🌐 web/                     # Web platform code
├── 🖥️ windows/                 # Windows platform code
├── 🐧 linux/                   # Linux platform code
├── 🍏 macos/                   # macOS platform code
├── 🧪 test/                    # Unit and widget tests
├── 🔗 integration_test/        # Integration tests
├── 📚 lib/                     # Main application code
│   ├── 🎯 main.dart           # App entry point
│   ├── 📱 app.dart            # App configuration
│   ├── 🛣️ routes.dart         # Navigation routes
│   ├── 📊 constants/          # App constants
│   ├── 🗃️ models/             # Data models
│   ├── 🔄 providers/          # State management
│   ├── 🔧 services/           # Business logic
│   ├── 🎨 UI/                 # User interface
│   └── 🛠️ utils/             # Utility functions
├── 📋 pubspec.yaml            # Dependencies and metadata
├── 🔧 pubspec.lock            # Dependency lock file
├── ⚙️ analysis_options.yaml   # Linting configuration
├── 📖 README.md              # Project documentation
└── 📁 docs/                  # Detailed documentation
```

### 🎯 Core Application Structure

**Entry Point** (`lib/main.dart`):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize services
  await ServiceLocator.initialize();
  
  // Run app
  runApp(const WismeApp());
}
```

**App Configuration** (`lib/app.dart`):
```dart
class WismeApp extends StatelessWidget {
  const WismeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: MaterialApp(
        title: 'Wisme',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: Routes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
```

---

## 🧪 Testing Configuration

### 🔬 Testing Strategy

**Test Types**:
1. **Unit Tests**: Individual function/class testing
2. **Widget Tests**: UI component testing
3. **Integration Tests**: End-to-end flow testing
4. **Golden Tests**: UI screenshot comparison

### ⚙️ Test Configuration

**Test Setup** (`test/helpers/test_helpers.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirestore extends Mock implements FirebaseFirestore {}
class MockStorageService extends Mock implements StorageService {}

TestWidgetsFlutterBinding get binding => TestWidgetsFlutterBinding.ensureInitialized();

Widget createTestWidget(Widget child) {
  return MaterialApp(
    home: child,
    theme: AppTheme.lightTheme,
  );
}

Future<void> pumpAndSettle(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(createTestWidget(widget));
  await tester.pumpAndSettle();
}
```

**Test Commands**:
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/audio_service_test.dart

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## 🚀 Build & Deployment

### 📱 Building for Different Platforms

#### **Android Build**

**Debug Build**:
```bash
# Debug APK
flutter build apk --debug

# Debug App Bundle
flutter build appbundle --debug
```

**Release Build**:
```bash
# Release APK
flutter build apk --release

# Release App Bundle (recommended)
flutter build appbundle --release

# Split APKs by ABI
flutter build apk --split-per-abi --release
```

#### **iOS Build** (macOS only)

**Debug Build**:
```bash
# Debug build
flutter build ios --debug
```

**Release Build**:
```bash
# Release build
flutter build ios --release

# Build for App Store
flutter build ipa --release
```

#### **Web Build**

```bash
# Web build
flutter build web --release

# Web build with specific renderer
flutter build web --web-renderer canvaskit
```

### 🔧 Build Configuration

**Android Configuration** (`android/app/build.gradle`):
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.wisme.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
            debuggable true
        }
    }
}
```

**iOS Configuration** (`ios/Runner/Info.plist`):
```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice features.</string>
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>background-fetch</string>
</array>
```

---

## 🔍 Debugging & Troubleshooting

### 🐛 Common Issues & Solutions

#### **Flutter Doctor Issues**

**Android License Issue**:
```bash
# Accept all Android licenses
flutter doctor --android-licenses
```

**iOS Development Issue**:
```bash
# Install missing iOS components
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

**Flutter Path Issue**:
```bash
# Add Flutter to PATH permanently
echo 'export PATH="$PATH:[PATH_TO_FLUTTER]/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

#### **Build Issues**

**Gradle Build Failure**:
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**iOS Build Failure**:
```bash
# Clean iOS build
rm -rf ios/Pods
rm ios/Podfile.lock
cd ios
pod install
cd ..
flutter clean
flutter build ios
```

**Dependency Conflicts**:
```bash
# Clear pub cache
flutter pub cache repair
flutter clean
flutter pub get
```

### 🔧 Debug Tools

**Flutter Inspector**:
- Available in VS Code and Android Studio
- Real-time widget tree inspection
- Performance profiling
- Memory usage analysis

**DevTools**:
```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or open directly
flutter run --debug
# Then open the DevTools URL in browser
```

**Logging**:
```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

// Usage
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

---

## 📊 Performance Optimization

### ⚡ Development Performance

**Hot Reload Optimization**:
```bash
# Enable hot reload
flutter run --hot

# Use with VS Code
# Save file to trigger hot reload

# Use with Android Studio
# Ctrl+S (Windows/Linux) or Cmd+S (macOS)
```

**Build Performance**:
```bash
# Use build cache
flutter build apk --build-shared-libraries

# Parallel builds
flutter build apk --split-per-abi

# Tree shaking (automatic in release)
flutter build apk --release
```

### 📱 App Performance

**Memory Management**:
```dart
// Dispose controllers and streams
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}

// Use const widgets
const Text('Static text');

// Implement AutomaticKeepAliveClientMixin when needed
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> 
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required
    return YourWidget();
  }
}
```

**Image Optimization**:
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheHeight: 200,
  memCacheWidth: 200,
);

// Optimize image loading
Image.asset(
  'assets/images/large_image.jpg',
  cacheHeight: 200,
  cacheWidth: 200,
);
```

---

## 🔐 Security Configuration

### 🛡️ Code Obfuscation

**Enable Obfuscation** (Android):
```bash
# Build with obfuscation
flutter build apk --obfuscate --split-debug-info=debug-info/

# Build App Bundle with obfuscation
flutter build appbundle --obfuscate --split-debug-info=debug-info/
```

**ProGuard Configuration** (`android/app/proguard-rules.pro`):
```proguard
# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep model classes
-keep class com.wisme.app.models.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
```

### 🔒 API Security

**Secure API Keys**:
```dart
// Use environment variables
class SecureConfig {
  static String get apiKey {
    // Never hardcode API keys
    return Platform.environment['API_KEY'] ?? '';
  }
  
  // Use secure storage for sensitive data
  static Future<String> getSecureKey(String key) async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: key) ?? '';
  }
}
```

**Network Security**:
```dart
// Use HTTPS only
const String baseUrl = 'https://api.wisme.com';

// Implement certificate pinning for production
class SecureHttpClient {
  static Dio createSecureClient() {
    final dio = Dio();
    
    (dio.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
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

## 📈 Monitoring & Analytics

### 📊 Development Metrics

**Performance Monitoring**:
```dart
// Firebase Performance
FirebasePerformance performance = FirebasePerformance.instance;

// Custom traces
Trace customTrace = performance.newTrace('custom_trace');
customTrace.start();
// ... perform operation
customTrace.stop();

// HTTP request monitoring
HttpMetric httpMetric = performance
    .newHttpMetric('https://api.example.com', HttpMethod.Get);
httpMetric.start();
// ... make request
httpMetric.stop();
```

**Error Tracking**:
```dart
// Firebase Crashlytics
FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;

// Record errors
crashlytics.recordError(
  error,
  stackTrace,
  fatal: false,
  information: ['Additional context'],
);

// Custom logging
crashlytics.log('Custom log message');

// User identification
crashlytics.setUserIdentifier('user123');
```

---

## 🎓 Learning Resources

### 📚 Essential Documentation

**Flutter Official**:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

**Architecture Patterns**:
- [Provider Package](https://pub.dev/packages/provider)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

**Testing**:
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/testing/widget-tests)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

### 🛠️ Useful Tools

**Development Tools**:
- [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)
- [DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)

**Design Tools**:
- [Flutter Gallery](https://gallery.flutter.dev/)
- [Material Design](https://material.io/design)
- [Cupertino Design](https://developer.apple.com/design/human-interface-guidelines/)

---

This comprehensive development guide provides everything needed to set up, configure, and optimize the Wisme development environment for maximum productivity and code quality!
