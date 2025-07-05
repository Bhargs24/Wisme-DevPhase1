# 🛠️ Development Setup Guide

*Complete setup guide for Flutter developers joining the Wisme project*

---

## 🎯 **Prerequisites**

### **Required Software**
- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher (comes with Flutter)
- **Android Studio**: Latest stable version
- **Xcode**: 15.0+ (macOS only, for iOS development)
- **VS Code**: Recommended with Flutter extensions
- **Git**: Latest version

### **Development Environment**
- **Node.js**: 18+ (for Firebase CLI)
- **Firebase CLI**: Latest version
- **FVM** (Flutter Version Manager): Recommended for version control

---

## 📱 **Flutter Setup**

### **1. Install Flutter**
```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Windows
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Add to PATH environment variable
```

### **2. Verify Installation**
```bash
flutter doctor -v
```

Expected output:
```
[✓] Flutter (Channel stable, 3.16.0)
[✓] Android toolchain
[✓] Xcode (macOS only)
[✓] Chrome
[✓] VS Code
[✓] Connected device
```

### **3. Install FVM (Recommended)**
```bash
dart pub global activate fvm

# Use specific Flutter version for project
fvm install 3.16.0
fvm use 3.16.0
```

---

## 🔧 **Project Setup**

### **1. Clone Repository**
```bash
git clone https://github.com/your-org/wisme-app.git
cd wisme-app
```

### **2. Environment Configuration**
```bash
# Copy environment template
cp .env.example .env

# Edit with your API keys
# OPENAI_API_KEY=sk-proj-xxxxx
# ELEVENLABS_API_KEY=xxxxx
# FIREBASE_CONFIG=xxxxx
```

### **3. Install Dependencies**
```bash
# Using FVM (recommended)
fvm flutter pub get

# Or regular Flutter
flutter pub get
```

### **4. Platform Setup**

#### **Android Setup**
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Create local.properties file
echo "sdk.dir=/path/to/Android/Sdk" > android/local.properties
```

#### **iOS Setup (macOS only)**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install iOS dependencies
cd ios && pod install && cd ..
```

---

## 🔥 **Firebase Configuration**

### **1. Install Firebase CLI**
```bash
npm install -g firebase-tools
firebase login
```

### **2. Initialize Firebase in Project**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for the project
flutterfire configure
```

### **3. Add Configuration Files**
The `flutterfire configure` command will create:
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### **4. Environment-Specific Setup**
```bash
# Development environment
flutterfire configure -p wisme-dev

# Production environment  
flutterfire configure -p wisme-prod
```

---

## 🔑 **API Keys Setup**

### **1. OpenAI API**
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Create account and get API key
3. Add to `.env` file:
```
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxx
OPENAI_ORG_ID=org-xxxxxxxxxxxxxxxx
```

### **2. ElevenLabs API**
1. Go to [ElevenLabs](https://elevenlabs.io/)
2. Create account and get API key
3. Add to `.env` file:
```
ELEVENLABS_API_KEY=xxxxxxxxxxxxxxxx
```

### **3. Environment Variables in Flutter**
```bash
# Build with environment variables
flutter build apk --dart-define=OPENAI_API_KEY=sk-xxx --dart-define=ELEVENLABS_API_KEY=xxx

# Or use build scripts (recommended)
./scripts/build_dev.sh
./scripts/build_prod.sh
```

---

## 🎨 **IDE Setup**

### **VS Code Extensions**
Install these essential extensions:
```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "usernamehw.errorlens",
    "gruntfuggly.todo-tree",
    "formulahendry.auto-rename-tag"
  ]
}
```

### **VS Code Settings**
Create `.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "dart.lineLength": 100,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

### **Launch Configuration**
Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENVIRONMENT=development",
        "--dart-define=OPENAI_API_KEY=${env:OPENAI_API_KEY}",
        "--dart-define=ELEVENLABS_API_KEY=${env:ELEVENLABS_API_KEY}"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=ENVIRONMENT=production",
        "--release"
      ]
    }
  ]
}
```

---

## 📦 **Package Management**

### **Core Dependencies**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  riverpod: ^2.4.9
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.8
  
  # HTTP & API
  dio: ^5.3.2
  http: ^1.1.2
  
  # Audio
  audioplayers: ^5.2.1
  just_audio: ^0.9.36
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  
  # Utils
  logger: ^2.0.2+1
  uuid: ^4.2.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
```

### **Development Scripts**
Create `scripts/` directory with:

**`scripts/setup.sh`**
```bash
#!/bin/bash
echo "Setting up Wisme development environment..."

# Install dependencies
fvm flutter pub get

# Generate code
fvm flutter packages pub run build_runner build

# Setup Firebase
flutterfire configure

echo "Setup complete! Run 'fvm flutter run' to start development."
```

**`scripts/build_dev.sh`**
```bash
#!/bin/bash
fvm flutter build apk \
  --dart-define=ENVIRONMENT=development \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dart-define=ELEVENLABS_API_KEY=$ELEVENLABS_API_KEY \
  --debug
```

**`scripts/build_prod.sh`**
```bash
#!/bin/bash
fvm flutter build apk \
  --dart-define=ENVIRONMENT=production \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY_PROD \
  --dart-define=ELEVENLABS_API_KEY=$ELEVENLABS_API_KEY_PROD \
  --release
```

---

## 🧪 **Testing Setup**

### **Test Configuration**
Create `test/` directory structure:
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── utils/
├── widget/
│   ├── screens/
│   └── components/
├── integration/
│   └── app_test.dart
└── test_helpers/
    ├── mock_data.dart
    └── test_utils.dart
```

### **Test Dependencies**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.1
  integration_test:
    sdk: flutter
  patrol: ^2.6.0
```

### **Mock Data Setup**
Create `test/test_helpers/mock_data.dart`:
```dart
class MockData {
  static const sampleUser = User(
    id: 'test-user-id',
    name: 'Test User',
    email: 'test@example.com',
  );
  
  static const sampleTopic = 'productivity';
  static const sampleCategory = 'Self-Growth';
  
  static const sampleCoach = Coach(
    id: 'kai',
    name: 'Kai',
    personality: CoachPersonality.strategic,
  );
}
```

---

## 🔍 **Development Workflow**

### **1. Daily Development**
```bash
# Start development server
fvm flutter run --dart-define=ENVIRONMENT=development

# Run with hot reload
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
```

### **2. Code Generation**
```bash
# Generate model classes and JSON serialization
fvm flutter packages pub run build_runner build

# Watch for changes (runs in background)
fvm flutter packages pub run build_runner watch
```

### **3. Testing**
```bash
# Run all tests
fvm flutter test

# Run specific test file
fvm flutter test test/unit/services/gpt_service_test.dart

# Run integration tests
fvm flutter test integration_test/
```

### **4. Code Quality**
```bash
# Analyze code
fvm flutter analyze

# Format code
fvm flutter format .

# Check for unused dependencies
fvm flutter pub deps --style=compact
```

---

## 🚀 **Build & Deployment**

### **Development Build**
```bash
# Android APK
./scripts/build_dev.sh

# iOS (macOS only)
fvm flutter build ios --dart-define=ENVIRONMENT=development
```

### **Production Build**
```bash
# Android AAB for Play Store
fvm flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY_PROD

# iOS for App Store (macOS only)
fvm flutter build ios --release \
  --dart-define=ENVIRONMENT=production
```

---

## 🐛 **Debugging Setup**

### **VS Code Debugging**
1. Set breakpoints in code
2. Press F5 or use "Run and Debug" panel
3. Select "Development" configuration
4. App launches with debugger attached

### **Device Debugging**
```bash
# List connected devices
fvm flutter devices

# Run on specific device
fvm flutter run -d <device-id>

# Enable inspector
# In app, press Ctrl+Shift+I (or Cmd+Shift+I on macOS)
```

### **Firebase Debugging**
```bash
# Enable Firebase emulator suite
firebase emulators:start

# Run app with emulators
fvm flutter run --dart-define=USE_FIREBASE_EMULATOR=true
```

---

## 📚 **Development Resources**

### **Documentation**
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider State Management](https://pub.dev/packages/provider)

### **Code Style**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` for consistent formatting
- Follow naming conventions in `docs/CODE_STANDARDS.md`

### **Git Workflow**
- Create feature branches: `feature/topic-analysis`
- Use conventional commits: `feat: add topic categorization`
- Pull request reviews required before merging
- Follow guidelines in `docs/GIT_WORKFLOW.md`

---

## ❓ **Troubleshooting**

### **Common Issues**

#### **Flutter Doctor Issues**
```bash
# Android license issues
flutter doctor --android-licenses

# iOS deployment issues (macOS)
sudo gem install cocoapods
cd ios && pod install
```

#### **Dependency Conflicts**
```bash
# Clean and rebuild
fvm flutter clean
fvm flutter pub get
fvm flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### **Firebase Issues**
```bash
# Reconfigure Firebase
flutterfire configure

# Check Firebase console for project setup
# Ensure SHA-1 fingerprints are added for Android
```

#### **API Key Issues**
- Verify API keys are correctly set in `.env`
- Check API key permissions and limits
- Ensure environment variables are passed to build

### **Getting Help**
- Check existing documentation in `docs/` folder
- Search GitHub issues in the repository
- Ask team members on Slack #development channel
- Create new issue with reproduction steps

---

*Happy coding! You're ready to build the future of learning with Wisme.* 🚀
