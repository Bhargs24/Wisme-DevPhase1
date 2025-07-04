# 🛠️ Wisme App - Technical Development Guide

*Complete setup and development reference for the AI-powered microlearning platform*

---

## 🚀 Quick Start

### **Prerequisites**
- **Flutter SDK** (latest stable version 3.x+)
- **Development Environment**: Android Studio, VS Code, or IntelliJ
- **Platform Tools**: 
  - Android Studio + Android SDK (for Android)
  - Xcode (for iOS - macOS only)
- **API Access**:
  - OpenAI API key (GPT-4/GPT-3.5)
  - ElevenLabs API key (Text-to-Speech)
  - Firebase project (Authentication & Firestore)

### **Setup**
```bash
# Clone and navigate to project
cd wisme_app

# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# Run the app
flutter run
```

### **Configuration**
1. **API Keys**: Add your keys to `lib/utils/api_keys.dart`
```dart
class ApiKeys {
  static const String openAiApiKey = 'your-openai-key-here';
  static const String elevenLabsApiKey = 'your-elevenlabs-key-here';
}
```

2. **Firebase Setup**: Follow Flutter Firebase setup guide for your platform
3. **Platform Configuration**: Ensure iOS/Android specific setup is complete

---

## 📁 Project Architecture

### **High-Level Structure**
```
lib/
├── main.dart                 # App entry point & configuration
├── app.dart                  # Main app widget & routing setup
├── routes.dart               # Navigation route definitions
├── constants/                # App-wide constants
│   ├── app_assets.dart       # Image/icon asset paths
│   ├── app_colors.dart       # Legacy color constants (use design_system)
│   └── app_text_styles.dart  # Legacy text styles (use design_system)
├── design_system/            # 🎨 Centralized design tokens & components
│   ├── tokens/              # Design tokens (colors, typography, spacing)
│   ├── theme/               # Flutter theme configuration
│   └── components/          # Reusable UI components
├── models/                   # 📊 Data models & schemas
│   ├── user_model.dart      # User profile & preferences
│   ├── coach_model.dart     # AI coach personalities & settings
│   └── lesson_model.dart    # Learning content & progress models
├── providers/                # 🔄 State management (Provider pattern)
│   ├── auth_provider.dart   # Authentication state
│   ├── lesson_provider.dart # Learning progress & content
│   ├── audio_provider.dart  # Audio playback & controls
│   └── user_provider.dart   # User preferences & profile
├── services/                 # 🌐 External API integrations
│   ├── auth_services.dart   # Firebase Authentication
│   ├── firestore_service.dart # Database operations
│   ├── gpt_service.dart     # OpenAI integration (content generation)
│   ├── tts_service.dart     # ElevenLabs text-to-speech
│   └── storage_service.dart # File storage & caching
├── UI/                       # 🎨 User interface components
│   ├── screens/             # Full-screen views
│   │   ├── onboarding/      # Welcome & setup flow
│   │   ├── auth/           # Login & registration
│   │   ├── home/           # Dashboard & navigation
│   │   ├── topic/          # Topic selection & configuration
│   │   ├── lesson/         # Audio player & learning interface
│   │   └── profile/        # Settings & user profile
│   └── widgets/             # Reusable UI components
│       ├── audio/          # Audio player controls
│       ├── cards/          # Content cards & tiles
│       ├── inputs/         # Form fields & controls
│       └── indicators/     # Progress bars & status
└── utils/                    # 🔧 Helper functions & utilities
    ├── api_keys.dart        # API key configuration
    ├── helper_functions.dart # Common utility functions
    └── logger.dart          # Debug logging utilities
```

---

## 🧠 Core Features Implementation

### **1. AI Topic Analysis & Content Generation**
**File**: `services/gpt_service.dart`
- **Purpose**: Analyzes user topics, categorizes content, generates learning paths
- **API**: OpenAI GPT-4/GPT-3.5
- **Key Functions**:
  - Topic intent detection
  - Content categorization (9 categories × 4 levels)
  - Learning journey creation
  - Content block generation

### **2. Voice Coach System**
**File**: `services/tts_service.dart`
- **Purpose**: Converts text to natural speech with AI personalities
- **API**: ElevenLabs Text-to-Speech
- **Features**:
  - Multiple coach personalities (Kai, Vee, Custom)
  - High-quality voice synthesis
  - Emotion and tone adaptation

### **3. Audio Management System**
**Files**: `providers/audio_provider.dart`, `services/storage_service.dart`
- **Purpose**: Handles audio playback, caching, and progress tracking
- **Features**:
  - Smart audio caching for offline learning
  - Progress tracking with resume capability
  - Speed controls and accessibility features

### **4. Learning Progress Engine**
**File**: `providers/lesson_provider.dart`
- **Purpose**: Tracks user progress, manages learning state
- **Storage**: Firebase Firestore + Local caching
- **Features**:
  - Block-level completion tracking
  - Learning analytics and insights
  - Spaced repetition scheduling

### **5. User Authentication & Profiles**
**Files**: `services/auth_services.dart`, `providers/auth_provider.dart`
- **Purpose**: User management and personalization
- **Backend**: Firebase Authentication
- **Features**:
  - Social login options
  - Profile customization
  - Coach personality preferences

---

## 🎨 Design System Usage

### **Design Tokens**
The design system provides centralized tokens for consistent styling:

```dart
// Colors
import 'package:wisme_app/design_system/tokens/app_colors.dart';
WismeColors.primary
WismeColors.secondary
WismeColors.background

// Typography
import 'package:wisme_app/design_system/tokens/app_typography.dart';
WismeTypography.headline1
WismeTypography.bodyText
WismeTypography.caption

// Spacing
import 'package:wisme_app/design_system/tokens/app_spacing.dart';
WismeSpacing.small
WismeSpacing.medium
WismeSpacing.large
```

### **Theme Integration**
```dart
// Apply theme
MaterialApp(
  theme: WismeTheme.lightTheme,
  darkTheme: WismeTheme.darkTheme,
  themeMode: ThemeMode.system,
  // ...
)
```

### **Component Usage**
```dart
// Reusable components
WismeCard(
  title: 'Lesson Title',
  subtitle: 'Episode description',
  onTap: () => Navigator.push(...),
)

WismeButton(
  text: 'Start Learning',
  onPressed: () => startLesson(),
  variant: ButtonVariant.primary,
)
```

---

## 🔧 Development Workflow

### **Running & Testing**
```bash
# Development
flutter run                    # Debug mode on connected device
flutter run --release          # Release mode for performance testing
flutter run -d chrome          # Web development

# Testing
flutter test                   # Run unit tests
flutter test integration_test/ # Run integration tests
flutter analyze                # Static code analysis

# Build
flutter build apk             # Android APK
flutter build ios             # iOS build (macOS only)
flutter build web             # Web build
```

### **Code Quality**
```bash
# Formatting
flutter format .               # Format all Dart files

# Dependencies
flutter pub get               # Install/update dependencies
flutter pub upgrade           # Upgrade to latest versions
flutter pub deps              # Dependency analysis

# Cleanup
flutter clean                 # Clean build artifacts
flutter pub cache repair      # Repair package cache
```

### **Debugging**
```bash
# Flutter Inspector
flutter inspector             # Visual debugging tool

# Device Logs
flutter logs                  # Real-time device logs
flutter logs --verbose        # Detailed logging

# Performance
flutter drive --profile test_driver/app_test.dart  # Performance profiling
```

---

## 📊 State Management Pattern

### **Provider Architecture**
Using Provider pattern for predictable state management:

```dart
// State provider example
class LessonProvider with ChangeNotifier {
  List<Lesson> _lessons = [];
  bool _isLoading = false;
  
  List<Lesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  
  Future<void> loadLessons() async {
    _isLoading = true;
    notifyListeners();
    
    _lessons = await LessonService.fetchLessons();
    _isLoading = false;
    notifyListeners();
  }
}

// UI consumption
Consumer<LessonProvider>(
  builder: (context, lessonProvider, child) {
    if (lessonProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return LessonList(lessons: lessonProvider.lessons);
  },
)
```

---

## 🌐 API Integration Guide

### **OpenAI Integration**
```dart
// GPT Service example
class GPTService {
  static Future<TopicAnalysis> analyzeUserTopic(String topic) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': 'Analyze this learning topic...'},
          {'role': 'user', 'content': topic},
        ],
      }),
    );
    return TopicAnalysis.fromJson(jsonDecode(response.body));
  }
}
```

### **ElevenLabs TTS Integration**
```dart
// TTS Service example
class TTSService {
  static Future<Uint8List> generateSpeech(String text, String voiceId) async {
    final response = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'),
      headers: {
        'xi-api-key': ApiKeys.elevenLabsApiKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.5,
        },
      }),
    );
    return response.bodyBytes;
  }
}
```

---

## 📱 Implementation Status

### **✅ Completed Features**
- ✅ **Design System Architecture** - Centralized tokens and theming
- ✅ **Project Structure** - Clean, scalable folder organization
- ✅ **Provider Setup** - State management foundation
- ✅ **Service Layer** - API integration architecture
- ✅ **Basic UI Screens** - Core user interface structure
- ✅ **Error-Free Codebase** - No compilation or runtime errors
- ✅ **Model Definitions** - Data structures for User, Coach, Lesson

### **🚧 In Development**
- 🚧 **OpenAI Integration** - Topic analysis and content generation
- 🚧 **ElevenLabs TTS** - Voice synthesis implementation
- 🚧 **Audio Player** - Full playback controls and progress tracking
- 🚧 **Firebase Integration** - Authentication and data storage
- 🚧 **Learning Journey Builder** - Dynamic curriculum creation

### **📋 Upcoming Features**
- 📋 **Offline Learning** - Content caching and offline playback
- 📋 **Progress Analytics** - Advanced learning insights
- 📋 **Social Features** - Sharing and collaborative learning
- 📋 **Advanced AI Features** - Personalized recommendations
- 📋 **Platform Optimization** - Performance and platform-specific features

---

## 🎯 Key Development Focus Areas

### **Priority 1: Core Learning Engine**
- Complete OpenAI integration for topic analysis
- Implement content generation and categorization
- Build learning journey creation system

### **Priority 2: Audio Experience**
- ElevenLabs TTS integration
- Audio player with full controls
- Content caching for offline learning

### **Priority 3: User Experience**
- Authentication and user profiles
- Progress tracking and analytics
- Onboarding and coach selection

### **Priority 4: Advanced Features**
- Social learning features
- Advanced personalization
- Performance optimization

---

## 🚀 Getting Started as a New Developer

### **Day 1: Environment Setup**
1. Install Flutter and dependencies
2. Clone repository and run `flutter pub get`
3. Set up IDE with Flutter/Dart plugins
4. Run the app with `flutter run`

### **Day 2: Explore Architecture**
1. Study project structure and design system
2. Read through model definitions
3. Understand Provider state management pattern
4. Review service layer architecture

### **Day 3: First Contribution**
1. Pick a feature from "In Development" list
2. Create feature branch
3. Implement following established patterns
4. Test thoroughly before submitting PR

### **Ongoing: Best Practices**
- Follow established naming conventions
- Use design system tokens for all styling
- Write tests for new functionality
- Update documentation for significant changes

---

## 📚 Additional Resources

- **[README.md](README.md)** - Product vision and user journey
- **[FEATURES_OVERVIEW.md](FEATURES_OVERVIEW.md)** - Complete feature breakdown
- **[Design System README](lib/design_system/README.md)** - UI component guide
- **[Flutter Documentation](https://docs.flutter.dev)** - Official Flutter docs
- **[Provider Package](https://pub.dev/packages/provider)** - State management docs

---

*Ready to build the future of AI-powered learning? Let's code! 🚀*
