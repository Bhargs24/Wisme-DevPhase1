# 🧠 Wisme App - Complete Project Blueprint for Fresh Build

**Purpose:** Complete specification for building the Wisme AI-powered microlearning platform from scratch with industrial-grade architecture.

---

## 🎯 PROJECT OVERVIEW

Wisme is a premium AI-powered microlearning platform that transforms any topic into personalized, podcast-style audio learning experiences. The app uses GPT for content generation, ElevenLabs for voice synthesis, and features a sophisticated coach system with memory-driven personalization.

### Key Features
- 🤖 **AI Content Generation** - GPT-powered lesson creation and categorization
- 🎙️ **Voice Coach System** - Multiple AI personalities (Kai, Vee) with distinct voices
- 📊 **Advanced Analytics** - Comprehensive learning progress tracking
- 🏆 **Gamification** - Achievements, streaks, leaderboards, social features
- 🔄 **Offline Learning** - Download content for offline consumption
- 📱 **Cross-Platform** - iOS, Android, Web support

---

## 🏗️ TECHNICAL ARCHITECTURE

### Tech Stack
- **Frontend:** Flutter 3.29.3+ with Dart 3.7.2+
- **State Management:** Provider pattern with Manager layer
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI Services:** OpenAI GPT-4, ElevenLabs TTS
- **Local Storage:** Hive/SQLite for offline data
- **Audio:** audioplayers package
- **Design:** Material Design 3 with custom design system

### Architecture Pattern
```
lib/
├── main.dart                     # App entry point
├── app/
│   ├── wisme_app.dart           # Main app widget
│   ├── app_config.dart          # Environment configuration
│   └── initialization/
│       └── app_initializer.dart # Startup logic
├── core/
│   ├── managers/
│   │   ├── core_manager.dart
│   │   ├── audio_manager.dart
│   │   ├── content_manager.dart
│   │   ├── user_manager.dart
│   │   ├── analytics_manager.dart
│   │   ├── offline_manager.dart
│   │   ├── notification_manager.dart
│   │   └── gamification_manager.dart
│   ├── services/
│   │   ├── firestore_service.dart
│   │   ├── auth_service.dart
│   │   ├── gpt_service.dart
│   │   ├── elevenlabs_service.dart
│   │   ├── tts_service.dart
│   │   ├── storage_service.dart
│   │   ├── audio_player_service.dart
│   │   ├── analytics_service.dart
│   │   ├── offline_service.dart
│   │   ├── notification_service.dart
│   │   ├── leaderboard_service.dart
│   │   ├── social_service.dart
│   │   ├── achievement_service.dart
│   │   └── content_management_service.dart
│   ├── storage/
│   │   ├── local_storage_service.dart
│   │   ├── cache_service.dart
│   │   ├── hive_storage.dart
│   │   └── sqlite_storage.dart
│   ├── network/
│   │   ├── http_client.dart
│   │   └── connectivity_service.dart
│   ├── error/
│   │   ├── error_handler.dart
│   │   ├── exceptions.dart
│   │   └── failure.dart
│   └── utils/
│       ├── logger.dart
│       ├── api_keys.dart
│       ├── helper_functions.dart
│       ├── validators.dart
│       ├── formatters.dart
│       └── analytics_utils.dart
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── verify_email_screen.dart
│   │   ├── auth_provider.dart
│   │   └── auth_routes.dart
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   ├── learning_goals_screen.dart
│   │   ├── knowledge_level_screen.dart
│   │   ├── coach_selection_screen.dart
│   │   ├── notification_permission_screen.dart
│   │   ├── setup_complete_screen.dart
│   │   ├── onboarding_provider.dart
│   │   └── onboarding_routes.dart
│   ├── learning/
│   │   ├── home_screen.dart
│   │   ├── topic_selection_screen.dart
│   │   ├── topic_analysis_screen.dart
│   │   ├── learning_path_screen.dart
│   │   ├── lesson_screen.dart
│   │   ├── learning_session_screen.dart
│   │   ├── progress_dashboard_screen.dart
│   │   ├── transcript_screen.dart
│   │   ├── note_taking_screen.dart
│   │   ├── related_content_screen.dart
│   │   ├── learning_provider.dart
│   │   └── learning_routes.dart
│   ├── audio/
│   │   ├── audio_player_widget.dart
│   │   ├── audio_queue_widget.dart
│   │   ├── playback_controls_widget.dart
│   │   ├── audio_provider.dart
│   │   └── audio_routes.dart
│   ├── coaches/
│   │   ├── coach_profile_screen.dart
│   │   ├── coach_list_screen.dart
│   │   ├── coach_detail_screen.dart
│   │   ├── create_coach_screen.dart
│   │   ├── coach_avatar.dart
│   │   ├── coach_provider.dart
│   │   └── coaches_routes.dart
│   ├── analytics/
│   │   ├── analytics_dashboard_screen.dart
│   │   ├── streak_calendar_screen.dart
│   │   ├── achievement_gallery_screen.dart
│   │   ├── analytics_provider.dart
│   │   └── analytics_routes.dart
│   ├── social/
│   │   ├── leaderboard_screen.dart
│   │   ├── friends_screen.dart
│   │   ├── activity_feed_screen.dart
│   │   ├── challenges_screen.dart
│   │   ├── discussion_forum_screen.dart
│   │   ├── social_provider.dart
│   │   └── social_routes.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── account_settings_screen.dart
│       ├── privacy_screen.dart
│       ├── notification_settings_screen.dart
│       ├── settings_provider.dart
│       └── settings_routes.dart
├── shared/
│   ├── models/
│   │   ├── topic_analysis.dart
│   │   ├── content_block.dart
│   │   ├── user_profile.dart
│   │   ├── learning_session.dart
│   │   ├── coach.dart
│   │   ├── achievement.dart
│   │   ├── voice.dart
│   │   ├── result.dart
│   │   └── analytics.dart
│   ├── widgets/
│   │   ├── wisme_card.dart
│   │   ├── wisme_button.dart
│   │   ├── wisme_text_field.dart
│   │   ├── audio_player_widget.dart
│   │   ├── learning_progress_indicator.dart
│   │   ├── coach_avatar.dart
│   │   ├── modal_dialog.dart
│   │   ├── progress_bar.dart
│   │   └── rating_stars.dart
│   ├── theme/
│   │   ├── wisme_colors.dart
│   │   ├── wisme_text_styles.dart
│   │   ├── wisme_spacing.dart
│   │   └── app_theme.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── categories.dart
│   │   ├── error_messages.dart
│   │   └── routes.dart
│   └── extensions/
│       ├── string_extensions.dart
│       ├── date_extensions.dart
│       ├── context_extensions.dart
│       └── list_extensions.dart
└── navigation/
    ├── app_router.dart
    ├── route_guards.dart
    └── navigation_utils.dart
```

---

## 📊 DATA MODELS

### Core Models

#### TopicAnalysis Model
```dart
class TopicAnalysis {
  final String id;
  final String originalQuery;
  final String detectedCategory;        // Technology, Business, Psychology, etc.
  final String knowledgeLevel;          // Fundamentals, Case Studies, Advanced, Mixed
  final List<String> suggestedTags;     // #beginner, #case-study, #practical
  final double confidenceScore;         // 0.0 - 1.0
  final int estimatedSessions;          // Recommended learning sessions
  final String recommendedCoach;        // kai, vee, custom
  final Map<String, dynamic> metadata;  // Additional GPT analysis data
  final DateTime analyzedAt;

  // Methods: toJson, fromJson, fromGPTResponse, copyWith
  // Business logic: categoryDisplayName, isHighConfidence, etc.
}
```

#### ContentBlock Model
```dart
class ContentBlock {
  final String id;
  final String title;
  final String description;
  final Duration duration;
  final String audioUrl;
  final String? localAudioPath;         // For offline storage
  final String category;
  final String knowledgeLevel;
  final List<String> tags;
  final String contentType;             // intro, case-study, actionable, summary
  final int difficultyLevel;            // 1-5
  final String coachPersonality;        // kai, vee, custom
  final String voiceId;                 // ElevenLabs voice ID
  final String transcript;              // Full text content
  final List<String> keywords;          // For search and matching
  final List<String> prerequisites;     // Required prior knowledge
  final List<String> learningOutcomes;  // What user will learn
  final int playCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDownloaded;
  final int fileSizeBytes;
  final Map<String, dynamic> metadata;

  // Methods: toJson, fromJson, copyWith
  // Business logic: formattedDuration, matchesTags, isPlayable, etc.
}
```

#### UserProfile Model
```dart
class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final List<String> preferredCategories;
  final String defaultKnowledgeLevel;
  final String preferredCoach;
  final Map<String, dynamic> learningPreferences;
  final int totalLearningTime;          // minutes
  final int currentStreak;
  final int longestStreak;
  final List<String> completedLessons;
  final Map<String, int> categoryProgress;
  final List<Achievement> achievements;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> settings;

  // Methods: toJson, fromJson, copyWith
  // Business logic: learningLevel, streakStatus, etc.
}
```

#### LearningSession Model
```dart
class LearningSession {
  final String id;
  final String userId;
  final String topicId;
  final List<String> contentBlockIds;
  final Duration totalDuration;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double progressPercentage;      // 0.0 - 1.0
  final Map<String, dynamic> analytics; // Time spent, interactions, etc.
  final bool isCompleted;
  final double? userRating;
  final String? userFeedback;

  // Methods: toJson, fromJson, copyWith
  // Business logic: isInProgress, timeRemaining, etc.
}
```

#### Coach Model
```dart
class Coach {
  final String id;
  final String name;
  final String personality;             // strategic, energetic, calm, etc.
  final String description;
  final String voiceId;                 // ElevenLabs voice ID
  final Color primaryColor;
  final String avatarUrl;
  final List<String> specialties;       // Categories this coach excels at
  final Map<String, String> personalityTraits;
  final bool isCustom;                  // User-created coach
  final DateTime createdAt;

  // Predefined coaches: Kai (strategic), Vee (energetic)
  // Methods: toJson, fromJson, copyWith
}
```

---

## 🔧 CORE SERVICES

### AIContentService
```dart
class AIContentService {
  // GPT Integration
  Future<TopicAnalysis> analyzeUserTopic(String query);
  Future<List<ContentBlock>> generateLearningPath(TopicAnalysis analysis);
  Future<String> generateLessonScript(ContentBlock block);
  Future<List<String>> suggestRelatedTopics(String topic);
  
  // Content Assembly
  Future<LearningSession> createLearningSession(TopicAnalysis analysis);
  Future<List<ContentBlock>> getReusableContent(List<String> tags);
}
```

### VoiceSynthesisService
```dart
class VoiceSynthesisService {
  // ElevenLabs Integration
  Future<String> synthesizeAudio(String text, String voiceId);
  Future<List<Voice>> getAvailableVoices();
  Future<AudioGenerationStatus> checkGenerationStatus(String jobId);
  
  // Local Management
  Future<String> downloadAudioFile(String url, String filename);
  Future<bool> deleteAudioFile(String path);
}
```

### AudioPlayerService
```dart
class AudioPlayerService {
  // Playback Control
  Future<void> play(ContentBlock block);
  Future<void> pause();
  Future<void> stop();
  Future<void> seekTo(Duration position);
  Future<void> setPlaybackSpeed(double speed);
  
  // State Management
  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  
  // Queue Management
  Future<void> addToQueue(List<ContentBlock> blocks);
  Future<void> removeFromQueue(String blockId);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
}
```

### OfflineService
```dart
class OfflineService {
  // Download Management
  Future<void> downloadContentBlock(ContentBlock block);
  Future<void> deleteDownload(String blockId);
  Future<List<ContentBlock>> getDownloadedContent();
  Future<double> getDownloadProgress(String blockId);
  
  // Storage Management
  Future<int> getTotalStorageUsed();
  Future<void> cleanupOldDownloads();
  Future<bool> hasEnoughSpace(int requiredBytes);
}
```

### AnalyticsService
```dart
class AnalyticsService {
  // Progress Tracking
  Future<void> trackLessonStarted(String lessonId);
  Future<void> trackLessonCompleted(String lessonId, Duration duration);
  Future<void> trackUserInteraction(String action, Map<String, dynamic> data);
  
  // Insights Generation
  Future<LearningInsights> generateLearningInsights(String userId);
  Future<List<Achievement>> checkAchievements(String userId);
  Future<Map<String, dynamic>> getWeeklyProgress(String userId);
}
```

---

## 🎨 UI COMPONENTS SYSTEM

### Design Tokens
```dart
class WismeColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
}

class WismeTextStyles {
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );
}

class WismeSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
```

### Core UI Components
```dart
// WismeCard - Elevated card with consistent styling
class WismeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
}

// WismeButton - Primary action button
class WismeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant; // primary, secondary, outline, text
  final ButtonSize size; // large, medium, small
  final IconData? icon;
  final bool isLoading;
}

// WismeTextField - Styled text input
class WismeTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
}

// AudioPlayerWidget - Audio playback controls
class AudioPlayerWidget extends StatelessWidget {
  final ContentBlock contentBlock;
  final VoidCallback? onPlayPause;
  final VoidCallback? onSeek;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
}

// ProgressIndicator - Learning progress visualization
class LearningProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String? label;
  final Color? color;
  final bool showPercentage;
}

// CoachAvatar - Coach profile picture with personality indicator
class CoachAvatar extends StatelessWidget {
  final Coach coach;
  final double size;
  final bool showPersonalityRing;
  final VoidCallback? onTap;
}
```

---

## 📱 FEATURE SPECIFICATIONS

### 1. Onboarding Flow
```
Screens:
1. WelcomeScreen - App introduction and value proposition
2. LearningGoalsScreen - Select learning interests and goals
3. KnowledgeLevelScreen - Assess user's general knowledge level
4. CoachSelectionScreen - Choose preferred AI coach
5. NotificationPermissionScreen - Request notification permissions
6. SetupCompleteScreen - Onboarding completion and first topic suggestion

Navigation: Linear flow with progress indicator
Data Collection: Learning preferences, coach selection, notification preferences
Persistence: Save onboarding data to UserProfile
```

### 2. Topic Analysis & Learning Path Creation
```
User Flow:
1. User enters learning topic (text input)
2. Show loading screen with AI analysis animation
3. Display categorization results and confidence score
4. Present learning path options (duration, complexity)
5. User confirms selection
6. Generate and cache content blocks
7. Navigate to first lesson

AI Integration:
- GPT-4 for topic analysis and categorization
- Content block generation with reusability checks
- Estimated time and session calculations
- Fallback for low-confidence analyses
```

### 3. Audio Learning Session
```
Features:
- Immersive audio player with coach personality
- Progress tracking with visual feedback
- Playback controls (play/pause, seek, speed adjustment)
- Background playback support
- Session interruption handling
- Transcript view with highlighting
- Note-taking capability
- Related content suggestions

Technical Requirements:
- MediaPlayer integration
- Background audio permissions
- Lock screen controls
- Bluetooth/headphone support
- Offline playback capability
```

### 4. Progress Analytics Dashboard
```
Visualizations:
- Learning streak calendar
- Time spent by category (charts)
- Knowledge level progression
- Achievement gallery
- Weekly/monthly insights
- Comparative analytics (vs. other learners)

Data Sources:
- LearningSession completions
- Audio playback analytics
- User interaction patterns
- Achievement unlocks
- Streak calculations
```

### 5. Social Features
```
Components:
- Friend connections and activity feeds
- Learning challenges and competitions
- Public leaderboards (optional participation)
- Content sharing and recommendations
- Discussion forums by topic
- Coach personality preferences sharing

Privacy Controls:
- Granular sharing settings
- Anonymous leaderboard participation
- Content sharing permissions
- Data visibility controls
```

---

## 🔐 SECURITY & PRIVACY

### Data Protection
- End-to-end encryption for user data
- GDPR and CCPA compliance
- Secure API key management
- User consent management
- Data retention policies
- Anonymous analytics options

### Authentication
- Firebase Authentication integration
- Social login options (Google, Apple)
- Secure token management
- Session timeout handling
- Account deletion capabilities

---

## 🚀 DEPLOYMENT STRATEGY

### Environment Configuration
```dart
enum Environment { development, staging, production }

class AppConfig {
  static const Environment environment = Environment.production;
  
  static const Map<Environment, Config> configs = {
    Environment.development: Config(
      apiBaseUrl: 'https://dev-api.wisme.app',
      firebaseConfig: DevFirebaseConfig(),
      analyticsEnabled: false,
    ),
    Environment.production: Config(
      apiBaseUrl: 'https://api.wisme.app',
      firebaseConfig: ProdFirebaseConfig(),
      analyticsEnabled: true,
    ),
  };
}
```

### Build & Release
- Automated CI/CD pipeline
- Code signing for iOS/Android
- App Store optimization
- Crash reporting integration
- Performance monitoring
- A/B testing framework

---

## 🧪 TESTING STRATEGY

### Unit Tests
- Model serialization/deserialization
- Business logic validation
- Service method testing
- Utility function verification

### Widget Tests
- UI component rendering
- User interaction handling
- State management verification
- Accessibility compliance

### Integration Tests
- Complete user flows
- API integration testing
- Audio playback functionality
- Offline behavior validation

---

## 📊 ANALYTICS & MONITORING

### Key Metrics
- Daily/Monthly Active Users
- Session duration and completion rates
- Content engagement by category
- Learning streak maintenance
- Feature adoption rates
- User retention analysis

### Crash Reporting
- Firebase Crashlytics integration
- Performance monitoring
- Error tracking and alerting
- User feedback collection

---

## 🔄 CONTENT MANAGEMENT SYSTEM

### Content Pipeline
```
1. Topic Analysis (GPT-4)
2. Content Block Generation
3. Script Creation and Review
4. Voice Synthesis (ElevenLabs)
5. Quality Assurance
6. Content Deployment
7. Usage Analytics
8. Continuous Improvement
```

### Content Caching Strategy
- Intelligent pre-loading based on user preferences
- LRU cache implementation for audio files
- Compression for efficient storage
- CDN integration for global distribution

---

## 📱 PLATFORM-SPECIFIC CONSIDERATIONS

### iOS
- App Store guidelines compliance
- iOS-specific UI adaptations
- Background app refresh handling
- Notification rich content
- Apple CarPlay integration

### Android
- Material You design integration
- Background processing optimization
- Android Auto support
- Adaptive icon implementation
- Storage scoped access

### Web
- Progressive Web App capabilities
- Responsive design implementation
- Web audio API integration
- Service worker for offline functionality

---

## 🎯 SUCCESS METRICS & KPIs

### User Engagement
- Session completion rate > 80%
- Daily active users growth > 15% monthly
- Average session duration > 12 minutes
- Content rating > 4.5/5

### Learning Effectiveness
- Knowledge retention measurement
- Skill progression tracking
- User-reported learning outcomes
- Behavioral change indicators

### Business Metrics
- User acquisition cost
- Lifetime value calculation
- Subscription conversion rates
- Revenue per user

---

This comprehensive blueprint provides everything needed to build the Wisme app from scratch with industrial-grade architecture, proper separation of concerns, and scalable design patterns. Each component is specified with clear interfaces, business logic, and implementation guidelines.
