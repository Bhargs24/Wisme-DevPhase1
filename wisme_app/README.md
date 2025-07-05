# 🧠 Wisme – AI-Powered Microlearning Platform

*Transform any topic into personalized podcast-style learning experiences in minutes*

[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎯 **Project Overview**

Wisme is a world-class AI-powered microlearning platform that transforms any learning topic into engaging, personalized podcast-style audio experiences. Built with Flutter and featuring premium UI/UX, the app delivers professional-grade learning content through AI coaches with distinct personalities.

### **✨ Key Features**
- 🤖 **AI Content Generation** - GPT-powered lesson creation and personalization
- 🎙️ **Voice Coach System** - Multiple AI personalities (Kai, Vee) with TTS integration
- 📊 **Advanced Analytics** - Comprehensive learning progress tracking and insights
- 🏆 **Social Learning** - Leaderboards, achievements, and community features
- 🎨 **Premium UI/UX** - Modern Material Design 3 with micro-interactions
- 📱 **Cross-Platform** - iOS, Android, Web, and Desktop support
- 🔄 **Offline Learning** - Download content for learning anywhere

---

## 🚀 **Quick Start**

### **Prerequisites**
- Flutter SDK 3.29.3+
- Dart 3.7.2+
- VS Code or Android Studio
- Java 17 (for Android development)

### **Installation**
```bash
# Clone the repository
git clone [repository-url]
cd wisme_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### **Development Setup**
```bash
# Clean and reset
flutter clean
flutter pub get

# Run code analysis
flutter analyze

# Run tests
flutter test
```

---

## 📁 **Project Structure**

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app configuration
├── routes.dart                  # Navigation and routing
├── constants/                   # App-wide constants
├── design_system/              # Design tokens and themes
├── models/                     # Data models
├── providers/                  # State management
├── services/                   # External APIs and services
├── UI/
│   ├── screens/               # Application screens
│   └── widgets/               # Reusable components
└── utils/                     # Helper functions
```

---

## �️ **Architecture & Tech Stack**

### **Frontend**
- **Flutter 3.29.3** - Cross-platform UI framework
- **Provider** - State management pattern
- **Material Design 3** - Modern UI components
- **Custom Design System** - Consistent UI/UX components

### **Backend & Services**
- **Firebase** - Authentication, Firestore, Cloud Storage
- **OpenAI GPT** - AI content generation
- **ElevenLabs** - Text-to-speech voice synthesis
- **SharedPreferences** - Local data persistence

### **Development Tools**
- **VS Code** - Primary IDE with Flutter extensions
- **Flutter Inspector** - UI debugging and performance
- **Firebase Console** - Backend management
- **Git** - Version control

---

## 🎨 **Design System**

The app features a comprehensive design system with:
- **Design Tokens** - Colors, typography, spacing, shadows
- **Component Library** - Reusable UI components
- **Theme Support** - Light/dark mode with system adaptation
- **Responsive Design** - Adaptive layouts for all screen sizes

Access the component showcase: `Navigator.pushNamed(context, '/component-showcase')`

---

## 📱 **Features Overview**

### **Core Learning Features**
- Smart topic analysis and categorization
- Knowledge level assessment
- AI coach selection and personalization
- Learning journey planning
- Enhanced audio player with visualizations
- Progress tracking and analytics

### **Social & Gamification**
- Friend connections and leaderboards
- Achievement system with badges
- Learning streaks and challenges
- Progress sharing and celebrations

### **Premium Features**
- Advanced analytics dashboard
- Offline content management
- Social learning platform
- Achievement gallery
- Enhanced audio controls
- Custom coach creation

See [Features.md](Features.md) for complete feature breakdown.

---

## 📖 **Documentation**

- **[CODEBASE_DOCUMENTATION.md](CODEBASE_DOCUMENTATION.md)** - Complete code documentation
- **[Features.md](Features.md)** - Comprehensive feature overview
- **[docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)** - Design system guide
- **[docs/UX_FLOW.md](docs/UX_FLOW.md)** - User experience flow
- **[docs/API_GUIDE.md](docs/API_GUIDE.md)** - API integration guide
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Development setup and architecture
- **[docs/TEAM_ONBOARDING.md](docs/TEAM_ONBOARDING.md)** - Team onboarding guide

---

## 🧪 **Testing**

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run specific test files
flutter test test/widget_test.dart
```

---

## 🔧 **Configuration**

### **API Keys Setup**
1. Create `lib/utils/api_keys.dart`
2. Add your API keys:
```dart
class ApiKeys {
  static const String openAI = 'your-openai-api-key';
  static const String elevenLabs = 'your-elevenlabs-api-key';
}
```

### **Firebase Setup**
1. Create Firebase project
2. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Update Firebase configuration files

---

## � **Deployment**

### **Android**
```bash
flutter build apk --release
flutter build appbundle --release
```

### **iOS**
```bash
flutter build ios --release
```

### **Web**
```bash
flutter build web --release
```

---

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### **Development Guidelines**
- Follow Flutter/Dart conventions
- Use the existing design system components
- Add tests for new features
- Update documentation for significant changes

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- Flutter team for the amazing framework
- Material Design for design inspiration
- OpenAI for GPT integration capabilities
- ElevenLabs for voice synthesis technology

---

## 📞 **Contact & Support**

For questions, suggestions, or support:
- 📧 Email: [contact@wisme.app](mailto:contact@wisme.app)
- 🐛 Issues: [GitHub Issues](https://github.com/wisme/wisme-app/issues)
- 📖 Documentation: [Project Wiki](https://github.com/wisme/wisme-app/wiki)

---

*Built with ❤️ using Flutter for learners worldwide*

🧠 **Kai** - Strategic, calm mentor-like (perfect for business topics)

⚡ **Vee** - Bold, energetic friend-like (great for creative/motivational content)

🎨 **Custom** - Name your coach, pick personality traits

Each coach develops memory and tracks your unique journey

### 5. Wisme Builds Your Learning Journey
A smart curriculum is created dynamically using existing audio blocks or generating new ones.

Audio blocks are:
- Categorized
- Tagged by knowledge level
- Reusable across users
- Slightly modified per context

### 6. Start Learning Daily
Episodes feel like podcast stories, not robotic lectures

Lessons are:
- ~10 minutes long
- Cached for reuse when possible
- Assembled with logic (Intro → Case Study → Actionable Insight)

---

## 🔍 Intent-Based Categorization Examples

**Topic: "Dogs"**
→ "What interests you most?"
- 🛠 Training → Skills & Tools
- 🧠 Behavior → Psychology & Mind
- 📚 Evolution → History & Culture

**Topic: "AI in Healthcare"**
→ Categorized under: 🌐 Technology
→ Knowledge Levels:
- 💡 Fundamentals
- 💼 Applications
- 🔬 Ethical Challenges

---

## 🎯 Core Features

### 🤖 Smart Learning Engine
- AI detects topic intent and maps to category + level
- Creates structured plans using tagged audio blocks
- Reuses previous content efficiently (lowers cost, faster delivery)

### 🎙️ Podcast-Style Voice Coaches
- Natural, human-like audio delivery
- Choose different coaches for different tones
- Lessons are stitched like episodes with smooth transitions

### 🔁 Dynamic Curriculum Builder
- Every topic becomes a structured path
- Content is recombined from a knowledge library
- Feels like a journey — not random content

### 🧠 Memory-Driven Learning
- Coaches remember your history
- Recommends what to learn next
- Avoids repeating lessons you've already heard

---

## 🧱 Architecture Principles

### Modular Audio Blocks
Stored as reusable lessons (e.g., "What is Crypto?", "How Airbnb Pivoted", "Case Study: Tesla")

### Hashtag Metadata System
- `#beginner`, `#case-study`, `#story`, `#tools`, `#inspiration`
- Used for indexing, personalization, and stitching

### Efficient Storage
Lessons saved with intelligent naming:
- `/tech/crypto/what-is-crypto.mp3`
- Enables personalization while keeping costs low

### Smart Retrieval
AI pulls related blocks based on hashtags, user preferences, and learning history

---

## 📚 Content Categories + Knowledge Levels

### 🌐 Technology
- 🔹 Core Concepts
- 💼 Case Studies
- 🛠 Tools & Trends
- 🎛 Bit of Everything

### 📊 Business & Finance
- 💡 Fundamentals
- 💼 Case Studies
- 📈 Growth Strategy
- 🎛 Balanced Mix

### 🧠 Psychology & Mind
- 🧠 Theories & Experiments
- 💬 Real-Life Application
- 🧘 Mindfulness & Behavior
- 🎛 Mixed Approach

### 🔍 Science & Nature
- 🔬 Scientific Concepts
- 🧬 Discoveries
- 🌱 Ethics & Controversies
- 🎛 Narrative Mix

### 💡 Creativity & Design
- 🎨 Design Fundamentals
- 📚 Iconic Examples
- 🛠 Frameworks & Tools
- 🎛 Creative Blend

### 🌱 Self-Growth
- 📖 Philosophy & Mental Models
- 🎯 Self-Development
- 💬 Habits & Mindset
- 🎛 Reflective Mix

### 📚 History & Culture
- 🗺️ Timelines
- 🌍 Cultural Impact
- 🎶 Media & Storytelling
- 🎛 Blended Approach

### 🛠 Skills & Tools
- 🧰 Getting Started
- 🔧 Pro Tools & Hacks
- 📈 Workflows & Systems
- 🎛 Practical Guide

### 🎯 Career & Strategy
- 🪞 Identity & Purpose
- 📄 Career Assets
- 🧭 Strategic Moves
- 🎛 Holistic Journey

### 🏛 Law & Governance
- 📜 Legal Foundations
- 🧭 Governance & Policy
- ⚖️ Case Law & Precedents
- 🎛 Civic Systems Mix

### 🗺 Geopolitics & Global Affairs
- 🌐 Power Dynamics
- 🤝 Diplomacy & Alliances
- 💣 Conflicts & Security
- 🎛 Global Narrative Mix

### 🌿 Environment & Sustainability
- 🌱 Climate & Ecology
- 🔋 Sustainable Systems
- 🧪 Environmental Tech
- 🎛 Eco-Strategy Blend

### 📐 Mathematics & Logic
- 🧮 Foundational Concepts
- 🔢 Applied Techniques
- 🧠 Logic & Formal Systems
- 🎛 Mathematical Narrative

### 🎮 Gaming & Interactive Media
- 🎮 Game Design Principles
- 🧠 Player Experience
- 📚 Iconic Games & Genres
- 🎛 Gaming Culture Mix

### 🌍 Society & Ethics
- 🧭 Social Structures
- 🧬 Moral Frameworks
- 💬 Real-World Ethics
- 🎛 Reflective Society Blend

### 🚀 Futurism & Exploration
- 🌌 Space & Cosmos
- 🤖 Emerging Futures
- 🔭 Exploration Scenarios
- 🎛 Futuristic Outlooks

---

## 🎉 User Delight Moments

- **"Wow" Onboarding** — Coach speaks your mind, explains your interest
- **First Daily Habit** — You open the app like Spotify, daily
- **Progress Feels Good** — Streaks, achievements, shareable insights
- **Coach Becomes Your Guide** — Nova or Kai feels like a real friend

---

## 🎬 Real Example Journey

**Topic:** "Startup Funding" → **Category:** 📊 Business & Finance → **Level:** 💼 Case Studies

**Generated Journey with Kai:**
- **Day 1:** "How Airbnb Almost Died - The $40k Debt Story"
- **Day 2:** "WhatsApp's $19B No-Revenue Miracle" 
- **Day 3:** "Uber's Controversial Path to Billions"
- **Day 4:** "Why 90% of Startups Fail at Fundraising"
- **Day 5:** "Your Fundraising Action Plan"

Each episode: ~12 minutes, story-driven, actionable insights.

---

## ❓ Smart Answers to Smart Questions

**"How is this different from podcasts?"**
→ Personalized to YOUR learning goals, remembers your progress, builds knowledge systematically

**"Will I get the same content as everyone else?"**
→ Modular blocks are reused efficiently, but delivery, order, and context are uniquely yours

**"How do you ensure quality?"**
→ AI-curated content blocks, human oversight, user feedback loops, and continuous improvement

**"What if I want to go deeper?"**
→ Every topic can expand - start with fundamentals, unlock advanced modules as you progress

---

## 🚀 Why Now? The Perfect Storm

- **📱 Audio-First World** - AirPods generation prefers audio learning
- **🤖 AI Maturity** - Voice synthesis and content generation finally feel human
- **⏰ Attention Economy** - People want learning that fits their lifestyle
- **📈 Creator Economy** - Demand for personalized, high-quality educational content
- **🎯 Micro-Learning Proven** - TikTok/Instagram proved bite-sized content works

---

## 📋 Documentation Hub

### **📚 For Everyone**
- **[docs/TEAM_ONBOARDING.md](docs/TEAM_ONBOARDING.md)** - Quick start guide for new team members
- **[docs/FEATURES_OVERVIEW.md](docs/FEATURES_OVERVIEW.md)** - Complete feature breakdown with AI learning system details

### **🛠️ For Developers**  
- **[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)** - Setup, architecture, and technical documentation
- **[docs/API_GUIDE.md](docs/API_GUIDE.md)** - OpenAI, ElevenLabs, Firebase, and internal APIs
- **[docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md)** - UI components, tokens, and theming

### **⚡ Quick Links**
- **Getting Started:** Check [docs/TEAM_ONBOARDING.md](docs/TEAM_ONBOARDING.md) for 30-minute setup
- **Understanding the Product:** Read [docs/FEATURES_OVERVIEW.md](docs/FEATURES_OVERVIEW.md) for complete vision
- **Building Features:** Follow [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) and [docs/API_GUIDE.md](docs/API_GUIDE.md)

---

*Ready to transform how the world learns? Let's build Wisme together.* 🚀
