
# 🚀 Wisme - Quick Team Onboarding Guide

*Get up and running with Wisme development in 30 minutes*

---

## 📋 Quick Links

- **[📱 Product Vision](README.md)** - What we're building and why
- **[🎯 Complete Features](FEATURES_OVERVIEW.md)** - Detailed feature breakdown
- **[🛠️ Development Guide](DEVELOPMENT.md)** - Technical setup and architecture
- **[🎨 Design System](lib/design_system/README.md)** - UI components and styling
- **[🔌 API Integration](API_GUIDE.md)** - External services and internal APIs

---

## ⚡ 5-Minute Setup

### **1. Prerequisites Check**
```bash
# Verify Flutter installation
flutter doctor

# Should show ✓ for:
# - Flutter SDK
# - Android toolchain
# - Chrome (for web development)
# - VS Code or Android Studio
```

### **2. Get the Code**
```bash
# Clone repository
git clone <repository-url>
cd wisme_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **3. Add API Keys**
Edit `lib/utils/api_keys.dart`:
```dart
class ApiKeys {
  static const String openAiApiKey = 'your-openai-key-here';
  static const String elevenLabsApiKey = 'your-elevenlabs-key-here';
}
```

### **4. Verify Setup**
```bash
# Run tests
flutter test

# Check for issues
flutter analyze
```

**✅ You're ready to develop!**

---

## 🎯 What Wisme Does (30-Second Pitch)

**Wisme is Spotify for learning.**

1. **User types any topic** → "Startup Funding"
2. **AI categorizes & creates curriculum** → 5-day Business journey  
3. **AI coach delivers podcast-style episodes** → 12-min daily stories
4. **Smart system remembers everything** → Builds on previous knowledge

**The Magic:** Reusable content blocks + Personalized delivery = Infinite scalability

---

## 🧠 Architecture Overview

### **Core Philosophy**
- **🎨 Design System First** - All UI is customizable without touching logic
- **🔄 Provider Pattern** - Clean state management
- **🧱 Modular Content** - Reusable audio blocks with smart assembly
- **🤖 AI-Driven** - Everything is personalized and adaptive

### **Key Components**
```
🎨 UI Layer (Flutter)
├── Design System (tokens, components, themes)
├── Screens (onboarding, learning, profile)
└── Widgets (reusable UI components)

🧠 Business Logic
├── Providers (state management)
├── Services (API integrations)
└── Models (data structures)

🌐 External APIs
├── OpenAI (content generation)
├── ElevenLabs (text-to-speech)
└── Firebase (auth, database, storage)
```

---

## 🛠️ Development Workflow

### **Daily Development**
```bash
# Start your day
flutter pub get              # Update dependencies
flutter run                  # Start development server

# Make changes
# Edit code in your preferred IDE
# Hot reload automatically updates the app

# Before committing
flutter test                 # Run tests
flutter analyze              # Check code quality
flutter format .             # Format code
```

### **Feature Development Process**
1. **📋 Pick a feature** from FEATURES_OVERVIEW.md
2. **🎨 Design UI components** using the design system
3. **🔄 Add state management** with Provider pattern
4. **🌐 Integrate APIs** following API_GUIDE.md
5. **✅ Test thoroughly** with unit and widget tests
6. **📝 Update documentation** if needed

---

## 🎨 Design System Quick Reference

### **Using Design Tokens**
```dart
// Colors
WismeColors.primary          // Brand primary color
WismeColors.secondary        // Brand secondary color
WismeColors.background       // Background color

// Typography
WismeTypography.headline1    // Large headlines
WismeTypography.bodyLarge    // Body text
WismeTypography.caption      // Small text

// Spacing
WismeSpacing.xs             // 4px
WismeSpacing.sm             // 8px
WismeSpacing.md             // 16px
WismeSpacing.lg             // 24px
```

### **Creating Components**
```dart
// Always use design tokens
Container(
  padding: EdgeInsets.all(WismeSpacing.md),
  decoration: BoxDecoration(
    color: WismeColors.surface,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Hello Wisme!',
    style: WismeTypography.bodyLarge,
  ),
)
```

---

## 🤖 AI Integration Quick Start

### **OpenAI Content Generation**
```dart
// Analyze user topic
final analysis = await GPTService.analyzeUserTopic('startup funding');

// Generate content block
final content = await GPTService.generateContentBlock(
  topic: analysis.topic,
  category: analysis.category,
  level: analysis.suggestedLevel,
  contentType: 'story',
);
```

### **ElevenLabs Voice Generation**
```dart
// Generate speech
final audioBytes = await TTSService.generateSpeech(
  text: content.script,
  coachId: 'kai', // or 'vee' or custom
);

// Save audio file
final audioUrl = await StorageService.saveAudio(
  audioBytes: audioBytes,
  fileName: 'episode_${content.id}.mp3',
);
```

---

## 📱 Current Status & Next Steps

### **✅ What's Working**
- ✅ Complete design system with customizable components
- ✅ Clean project architecture with Provider state management  
- ✅ All UI screens and navigation structure
- ✅ Service layer ready for API integration
- ✅ Error-free codebase that runs on all platforms

### **🚧 What's In Progress**
- 🚧 OpenAI integration for content generation
- 🚧 ElevenLabs TTS for voice synthesis
- 🚧 Firebase authentication and data storage
- 🚧 Audio player with progress tracking

### **📋 Immediate Next Steps**
1. **Complete API integrations** (OpenAI, ElevenLabs, Firebase)
2. **Build content generation pipeline** (topic → content → audio)
3. **Implement learning progress tracking** (user state, analytics)
4. **Add offline capabilities** (audio caching, sync)
5. **Polish user experience** (animations, interactions, feedback)

---

## 🎯 Team Roles & Focus Areas

### **Frontend/UI Developers**
- **Focus:** `lib/UI/` and `lib/design_system/`
- **Tasks:** Screen layouts, component library, animations, responsive design
- **Key Files:** `UI/screens/*.dart`, `design_system/components/*.dart`

### **Backend/API Developers**  
- **Focus:** `lib/services/` and `lib/providers/`
- **Tasks:** API integrations, data models, state management, database design
- **Key Files:** `services/*.dart`, `providers/*.dart`, `models/*.dart`

### **AI/Content Developers**
- **Focus:** Content generation, voice synthesis, learning algorithms
- **Tasks:** OpenAI prompts, TTS optimization, content quality, personalization
- **Key Files:** `services/gpt_service.dart`, `services/tts_service.dart`

### **Product/QA**
- **Focus:** User experience, testing, feature validation
- **Tasks:** User journey testing, feature completeness, quality assurance
- **Key Files:** `test/`, user flows, feature specifications

---

## 🚨 Common Issues & Solutions

### **Flutter Issues**
```bash
# Package conflicts
flutter clean && flutter pub get

# iOS build issues (macOS only)
cd ios && pod install && cd ..

# Android build issues
flutter clean && flutter run --verbose
```

### **API Integration Issues**
- **Rate Limiting:** Check API usage limits and implement backoff
- **Authentication:** Verify API keys are correctly set
- **CORS Issues:** Use proper headers and handle preflight requests

### **Performance Issues**
- **Large Audio Files:** Implement streaming and caching
- **Memory Usage:** Use `const` constructors and dispose resources
- **Build Times:** Use `flutter run --debug` for development

---

## 📚 Learning Resources

### **Flutter Development**
- [Flutter Documentation](https://docs.flutter.dev/) - Official docs
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets) - Widget reference
- [Provider Package](https://pub.dev/packages/provider) - State management

### **AI Integration**
- [OpenAI API Documentation](https://platform.openai.com/docs/) - GPT integration
- [ElevenLabs API Docs](https://docs.elevenlabs.io/) - Text-to-speech
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup) - Backend services

### **Design & UX**
- [Material Design 3](https://m3.material.io/) - Google's design system
- [Flutter Theme Documentation](https://docs.flutter.dev/cookbook/design/themes) - Theming guide

---

## 💬 Getting Help

### **Code Questions**
1. Check existing documentation first
2. Search GitHub issues and Stack Overflow  
3. Ask team members in Slack/Discord
4. Create detailed issue with code samples

### **Architecture Questions**
1. Review DEVELOPMENT.md and FEATURES_OVERVIEW.md
2. Check similar implementations in the codebase
3. Discuss with senior developers
4. Document decisions for future reference

### **Product Questions**
1. Check README.md for product vision
2. Review user journey examples
3. Test user flows hands-on
4. Validate with product owner

---

**Welcome to the Wisme team! Let's build the future of learning together** 🚀

*Ready to make learning as addictive as social media and as effective as personal tutoring.*
