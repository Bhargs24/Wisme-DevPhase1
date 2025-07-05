# 📋 Wisme Codebase Documentation

*Complete documentation for every Dart file in the Wisme AI-powered microlearning platform*

---

## 🏗️ **Project Structure Overview**

```
lib/
├── main.dart                          # App entry point and provider setup
├── app.dart                           # Main app configuration and routing
├── routes.dart                        # Route definitions and navigation logic
├── constants/                         # App-wide constants and configurations
├── design_system/                     # Design tokens, themes, and components
├── models/                           # Data models and business logic
├── providers/                        # State management (Provider pattern)
├── services/                         # External API and data services
├── UI/                               # User interface components
│   ├── screens/                      # Application screens
│   └── widgets/                      # Reusable UI components
└── utils/                            # Helper functions and utilities
```

---

## 🎯 **Core Application Files**

### **main.dart**
- **Purpose**: Application entry point and dependency injection setup
- **Key Functions**:
  - Firebase initialization (graceful fallback when not configured)
  - SharedPreferences initialization for local storage
  - Provider setup for state management (UserProvider, LessonProvider, VoiceProvider, etc.)
  - Service registration (AuthService, FirestoreService, GPTService, etc.)
- **Dependencies**: All providers and services are initialized here
- **Firebase Handling**: Includes error handling for Firebase configuration issues

### **app.dart**
- **Purpose**: Main app widget with theme and routing configuration
- **Key Functions**:
  - MaterialApp configuration with theme switching
  - Route management integration
  - Settings provider consumption for theme mode
- **Theme Support**: Light/dark theme switching based on user preferences

### **routes.dart**
- **Purpose**: Centralized routing and navigation management
- **Key Components**:
  - **AppRoutes class**: Static route constants for all screens
  - **Route map**: Static routes for simple navigation
  - **Dynamic route generation**: Complex routes with parameters
- **Route Categories**:
  - Authentication routes (login, onboarding)
  - Learning flow routes (topic selection, coach selection, journey planning)
  - Premium feature routes (dashboard, stats, leaderboard, achievements)
  - Settings and profile routes

---

## 📊 **Data Models (`lib/models/`)**

### **user_model.dart**
- **Purpose**: User data structure and profile management
- **Key Classes**:
  - **User**: Core user information (ID, email, display name)
  - **UserProfile**: Extended profile with preferences and settings
  - **LearningProfile**: Learning-specific data (progress, strengths, areas for improvement)
- **Features**: Firestore serialization, preference management, learning analytics

### **lesson_model.dart**
- **Purpose**: Content and learning structure definitions
- **Key Classes**:
  - **ContentBlock**: Individual learning units with metadata
  - **LearningJourney**: Structured learning paths with multiple blocks
  - **TopicAnalysis**: AI-analyzed topic data with categories and difficulty
  - **BlockProgress**: Individual progress tracking per content block
- **Features**: Duration tracking, difficulty levels, tag system, progress analytics

### **coach_model.dart**
- **Purpose**: AI coach personality and voice management
- **Key Classes**:
  - **CoachPersonality**: Predefined coach types (Kai, Vee) with traits
  - **CustomCoach**: User-created coaches with personalized attributes
- **Features**: Voice mapping, personality traits, speaking style configuration

### **voice_model.dart**
- **Purpose**: Text-to-speech voice configuration
- **Key Classes**:
  - **VoiceOption**: Individual voice configurations
  - **VoiceSettings**: User voice preferences and settings
- **Features**: Voice quality selection, speed controls, language support

### **topic_model.dart**
- **Purpose**: Learning topic categorization and analysis
- **Key Classes**:
  - **TopicCategory**: Predefined learning categories (Tech, Business, etc.)
  - **TopicAnalysis**: AI analysis results for user queries
  - **KnowledgeLevel**: Difficulty and prerequisite management
- **Features**: Category mapping, difficulty assessment, prerequisite tracking

---

## 🔄 **State Management (`lib/providers/`)**

### **user_provider.dart**
- **Purpose**: User authentication and profile state management
- **Key Functions**:
  - Authentication flow management (login, logout, registration)
  - User profile data persistence
  - Onboarding state tracking
- **State**: Current user, authentication status, profile completion

### **lesson_provider.dart**
- **Purpose**: Content generation and lesson management
- **Key Functions**:
  - AI lesson generation via GPT integration
  - Content block library management
  - Learning journey creation and progress tracking
  - Topic analysis and categorization
- **State**: Available lessons, current journey, generation status

### **voice_provider.dart**
- **Purpose**: Voice and audio configuration management
- **Key Functions**:
  - TTS voice selection and configuration
  - Voice settings persistence
  - Audio playback preferences
- **State**: Selected voice, audio settings, voice options

### **coach_provider.dart**
- **Purpose**: AI coach personality management
- **Key Functions**:
  - Coach selection and customization
  - Personality trait configuration
  - Coach-user interaction history
- **State**: Active coach, personality settings, interaction context

### **audio_provider.dart**
- **Purpose**: Audio playback and control management
- **Key Functions**:
  - Audio playback control (play, pause, seek)
  - Playlist management
  - Offline audio handling
- **State**: Playback status, current track, playlist queue

### **settings_provider.dart**
- **Purpose**: App-wide settings and preferences
- **Key Functions**:
  - Theme mode management
  - User preference persistence
  - Feature flag management
- **State**: Theme settings, user preferences, app configuration

---

## 🔧 **Services (`lib/services/`)**

### **auth_services.dart**
- **Purpose**: Firebase Authentication integration
- **Key Functions**:
  - Email/password authentication
  - Social login (Google, Apple)
  - User session management
  - Password reset functionality
- **Error Handling**: Graceful fallback when Firebase is not configured

### **firestore_service.dart**
- **Purpose**: Firebase Firestore database operations
- **Key Functions**:
  - User data CRUD operations
  - Content block storage and retrieval
  - Learning progress tracking
  - Real-time data synchronization
- **Offline Support**: Local caching and sync when online

### **gpt_service.dart**
- **Purpose**: OpenAI GPT integration for content generation
- **Key Functions**:
  - Lesson content generation
  - Topic analysis and categorization
  - Personalized learning path creation
  - Context-aware content adaptation
- **API Management**: Rate limiting, error handling, cost optimization

### **tts_service.dart**
- **Purpose**: Text-to-speech audio generation
- **Key Functions**:
  - Voice synthesis with multiple voice options
  - Audio file generation and caching
  - Playback speed and quality controls
  - Voice personality mapping
- **Integration**: ElevenLabs API and native TTS fallback

### **storage_service.dart**
- **Purpose**: Firebase Cloud Storage for audio files
- **Key Functions**:
  - Audio file upload and download
  - Cache management for offline access
  - File compression and optimization
- **Offline Strategy**: Local storage with cloud sync

---

## 🎨 **Design System (`lib/design_system/`)**

### **design_system.dart**
- **Purpose**: Central export file for all design system components
- **Exports**: Tokens, themes, atoms, molecules, organisms

### **tokens/app_colors.dart**
- **Purpose**: Color palette and semantic color definitions
- **Features**: Primary/secondary colors, semantic colors (success, error, warning), dark/light mode variants

### **tokens/app_typography.dart**
- **Purpose**: Text styles and font hierarchy
- **Features**: Heading styles, body text, labels, custom font weights

### **tokens/app_spacing.dart**
- **Purpose**: Consistent spacing and layout dimensions
- **Features**: Spacing scale, padding/margin constants, responsive breakpoints

### **themes/app_theme.dart**
- **Purpose**: Complete theme configuration for Material Design
- **Features**: Light/dark themes, component themes, custom theme extensions

### **atoms/app_button.dart**
- **Purpose**: Reusable button component with variants
- **Features**: Primary/secondary styles, loading states, icon support, size variants

### **atoms/app_text_field.dart**
- **Purpose**: Consistent text input component
- **Features**: Validation, password fields, search fields, error states

---

## 📱 **User Interface (`lib/UI/`)**

### **Core Screens (`lib/UI/screens/`)**

#### **Authentication & Onboarding**

**login_screen.dart**
- **Purpose**: User authentication interface
- **Features**: Email/password login, social authentication, registration mode toggle
- **Design**: Gradient background, animated transitions, form validation

**onboarding_screen.dart**
- **Purpose**: New user introduction and setup
- **Features**: Feature overview, swipe navigation, skip option
- **Flow**: App introduction → Feature highlights → Get started

**splash_screen.dart**
- **Purpose**: App loading and initialization
- **Features**: Logo animation, loading progress, error handling
- **Logic**: Authentication check, data preloading

#### **Home & Discovery**

**home_screen.dart**
- **Purpose**: Main application dashboard
- **Features**: Search bar, lesson recommendations, quick actions, user greeting
- **Components**: Topic selector, voice selector, lesson generation dialog
- **State**: User progress, recent lessons, personalized content

**search_screen.dart**
- **Purpose**: Content discovery and search
- **Features**: Text search, voice search, filter options, suggestions
- **Logic**: Real-time search, recent searches, popular topics

**dashboard_screen.dart**
- **Purpose**: Comprehensive learning overview
- **Features**: Progress charts, achievement highlights, learning streaks
- **Analytics**: Time spent, topics mastered, performance metrics

#### **Learning Flow**

**topic_selection_screen.dart**
- **Purpose**: Learning topic selection interface
- **Features**: Category browsing, topic suggestions, difficulty indicators
- **Design**: Grid layout, visual categories, search integration

**topic_analysis_screen.dart**
- **Purpose**: AI-powered topic analysis and breakdown
- **Features**: Topic categorization, difficulty assessment, learning path preview
- **AI Integration**: GPT analysis, knowledge level detection

**knowledge_level_screen.dart**
- **Purpose**: User knowledge assessment
- **Features**: Self-assessment questionnaire, skill level selection
- **Logic**: Adaptive questioning, level recommendation

**coach_selection_screen.dart**
- **Purpose**: AI coach personality selection
- **Features**: Coach gallery, personality previews, voice samples
- **Coaches**: Kai (strategic), Vee (energetic), custom options

**coach_naming_screen.dart**
- **Purpose**: Personalize selected coach
- **Features**: Custom name input, personality fine-tuning
- **Personalization**: Name validation, coach relationship building

**journey_planning_screen.dart**
- **Purpose**: Learning path creation and customization
- **Features**: Duration selection, goal setting, schedule planning
- **AI Planning**: Intelligent content sequencing, progress milestones

#### **Audio & Learning**

**lesson_screen.dart**
- **Purpose**: Audio lesson playback interface
- **Features**: Audio controls, transcript view, progress tracking
- **Controls**: Play/pause, speed control, 10s skip, progress slider
- **Visual**: Audio visualizer, lesson metadata, action buttons

**enhanced_audio_player_screen.dart**
- **Purpose**: Advanced audio player with premium features
- **Features**: Advanced visualizations, bookmark system, note-taking
- **Premium**: Enhanced controls, audio effects, chapter navigation

#### **Social & Gamification**

**social_leaderboard_screen.dart**
- **Purpose**: Community learning competition
- **Features**: Friend rankings, global leaderboards, achievement comparison
- **Gamification**: Points system, streak tracking, social challenges

**achievements_gallery_screen.dart**
- **Purpose**: User achievement showcase
- **Features**: Badge collection, milestone celebrations, progress visualization
- **Categories**: Learning streaks, topic mastery, social achievements

#### **Analytics & Progress**

**learning_stats_screen.dart**
- **Purpose**: Detailed learning analytics
- **Features**: Time tracking, topic progress, performance insights
- **Charts**: Progress graphs, learning velocity, retention rates

**content_library_screen.dart**
- **Purpose**: Comprehensive content management
- **Features**: Downloaded content, favorites, history, collections
- **Organization**: Categories, tags, search, sort options

**offline_learning_screen.dart**
- **Purpose**: Offline content management
- **Features**: Download queue, offline playback, sync status
- **Storage**: Size management, auto-download settings

#### **Settings & Configuration**

**settings_screen.dart**
- **Purpose**: General app configuration
- **Features**: Notifications, theme selection, data management
- **Categories**: Account, privacy, storage, about

**advanced_settings_screen.dart**
- **Purpose**: Power user configuration options
- **Features**: Developer settings, API configurations, experimental features
- **Advanced**: Debug options, performance tuning, beta features

**voice_settings_screen.dart**
- **Purpose**: Voice and audio configuration
- **Features**: Voice selection, speed settings, quality preferences
- **TTS**: Voice samples, accent options, speech rate

**profile_screen.dart**
- **Purpose**: User profile management
- **Features**: Personal information, learning preferences, account settings
- **Data**: Progress summary, achievements, learning history

#### **Utility Screens**

**component_showcase_screen.dart**
- **Purpose**: Design system component gallery (development)
- **Features**: Component demos, style guide, interactive examples
- **Development**: Button variants, form fields, cards, colors, typography

**feature_showcase_screen.dart**
- **Purpose**: App feature introduction
- **Features**: Interactive feature tour, capability highlights
- **Marketing**: Feature benefits, visual demonstrations

### **Widgets (`lib/UI/widgets/`)**

#### **Navigation & Layout**

**main_navigation.dart**
- **Purpose**: Bottom navigation bar with tab management
- **Features**: 5-tab layout, badge notifications, smooth transitions
- **Tabs**: Home, Search, Learning, Social, Profile

**auth_wrapper.dart**
- **Purpose**: Authentication state management wrapper
- **Features**: Login state detection, route protection, splash handling
- **Logic**: Auto-navigation based on auth status

#### **Content Display**

**lesson_card.dart**
- **Purpose**: Highly reusable lesson display component
- **Features**: Multiple layouts (full, compact), progress indicators, action buttons
- **Customization**: Show/hide elements, different sizes, interaction callbacks
- **Variants**: Progress tracking, favorite toggle, play button

#### **Form Components**

**app_text_field.dart**
- **Purpose**: Consistent form input component
- **Features**: Validation, different input types, error states
- **Types**: Standard, search, password with strength indicator

**app_button.dart**
- **Purpose**: Standardized button component
- **Features**: Multiple sizes, loading states, icon support
- **Variants**: Primary, secondary, text, outlined

#### **Specialized Widgets**

**voice_selector_widget.dart**
- **Purpose**: Voice selection modal with preview
- **Features**: Voice list, audio samples, settings integration
- **UX**: Voice preview, selection persistence

**progress_widget.dart**
- **Purpose**: Learning progress visualization
- **Features**: Circular progress, linear progress, animated updates
- **Data**: Percentage display, milestone indicators

**topic_suggestion.dart**
- **Purpose**: Topic recommendation display
- **Features**: Topic cards, difficulty indicators, popularity metrics
- **AI**: Smart suggestions based on user history

**loading_widget.dart**
- **Purpose**: Consistent loading state indicator
- **Features**: Spinner animation, loading messages, progress indication
- **Context**: Adaptive loading for different screen contexts

#### **Enhanced UI Components**

**modern_components.dart**
- **Purpose**: Advanced UI components with premium styling
- **Features**: Gradient cards, animated buttons, glassmorphism effects
- **Design**: Modern Material Design 3, micro-interactions

**error_boundary.dart**
- **Purpose**: Error handling and graceful degradation
- **Features**: Error catching, user-friendly error messages, retry functionality
- **Development**: Error reporting, fallback UI

**loading_states.dart**
- **Purpose**: Comprehensive loading state management
- **Features**: Skeleton screens, shimmer effects, progress indicators
- **UX**: Perceived performance improvement, loading feedback

**micro_interactions.dart**
- **Purpose**: Subtle animations and feedback
- **Features**: Hover effects, tap feedback, transition animations
- **Polish**: Enhanced user experience, visual feedback

---

## 🛠️ **Utilities (`lib/utils/`)**

### **helper_functions.dart**
- **Purpose**: Common utility functions used across the app
- **Functions**: Date formatting, string manipulation, validation helpers

### **logger.dart**
- **Purpose**: Centralized logging system
- **Features**: Log levels, file output, performance tracking
- **Development**: Debug information, error tracking

### **api_keys.dart**
- **Purpose**: API key management and configuration
- **Security**: Environment-based configuration, key rotation support

### **validators.dart**
- **Purpose**: Form validation logic
- **Functions**: Email validation, password strength, input sanitization

### **date_utils.dart**
- **Purpose**: Date and time utility functions
- **Features**: Relative time display, formatting, timezone handling

### **exceptions.dart**
- **Purpose**: Custom exception definitions
- **Types**: API exceptions, validation errors, user-friendly messages

### **accessibility_helper.dart**
- **Purpose**: Accessibility features and support
- **Features**: Screen reader support, high contrast themes, font scaling

---

## 📋 **Constants (`lib/constants/`)**

### **app_colors.dart**
- **Purpose**: Color definitions and theme colors
- **Organization**: Primary colors, semantic colors, theme variants

### **app_text_styles.dart**
- **Purpose**: Typography system and text styles
- **Hierarchy**: Headings, body text, labels, custom styles

### **app_assets.dart**
- **Purpose**: Asset path definitions
- **Organization**: Images, icons, audio files, font references

### **app_dimensions.dart**
- **Purpose**: Spacing, sizing, and layout constants
- **System**: Consistent spacing scale, component dimensions

### **app_theme.dart**
- **Purpose**: Theme configuration and Material Design setup
- **Features**: Light/dark themes, component customization

---

## 📝 **Test Files**

### **test/widget_test.dart**
- **Purpose**: Widget testing for UI components
- **Coverage**: Component rendering, user interactions, state changes

### **test_integration.dart**
- **Purpose**: Integration testing setup
- **Features**: Provider testing, service mocking, end-to-end flows

### **test_integrity.dart**
- **Purpose**: Code integrity and consistency checks
- **Validation**: Import validation, provider instantiation, service availability

### **integration_test.dart**
- **Purpose**: Full app integration testing
- **Scope**: Complete user journeys, real device testing

---

## 🔧 **Development Guidelines**

### **Code Organization**
- Each file has a single responsibility
- Clear separation between UI, business logic, and data
- Consistent naming conventions across all files

### **State Management**
- Provider pattern for reactive state management
- Clear separation between UI state and business state
- Error handling and loading states in all providers

### **Design System**
- Consistent component usage across screens
- Centralized theme management
- Responsive design considerations

### **Documentation Standards**
- Every file has a clear purpose comment
- Complex functions include implementation details
- API integrations document error handling

---

## 🚀 **Future Development**

### **Planned Additions**
- More specialized widgets for enhanced UX
- Additional AI coach personalities
- Advanced analytics screens
- Social learning features expansion

### **Architecture Evolution**
- Potential migration to Riverpod for state management
- Microservice architecture for backend services
- Advanced caching strategies for offline functionality

---

*This documentation provides a complete overview of every Dart file in the Wisme codebase. Each file serves a specific purpose in creating a comprehensive AI-powered microlearning platform with premium UI/UX and advanced features.*
