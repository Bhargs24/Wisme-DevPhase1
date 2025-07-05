# 🔌 API Integration Guide

*Complete setup and integration guide for all external APIs*

---

## 🎯 **Required APIs Overview**

Wisme integrates with multiple APIs to deliver AI-powered personalized learning:

| API Service | Purpose | Cost Impact | Criticality |
|-------------|---------|-------------|-------------|
| **OpenAI GPT-4** | Content generation, topic analysis | High | Critical |
| **ElevenLabs** | Voice synthesis, coach personalities | Medium | Critical |
| **Firebase** | Authentication, database, storage | Low | Critical |
| **Firebase Analytics** | User behavior tracking | Free | Important |
| **Firebase Crashlytics** | Error monitoring | Free | Important |

---

## 🤖 **OpenAI API Integration**

### **Setup Requirements**

#### **1. Account & API Key**
```bash
# Get API key from: https://platform.openai.com/account/api-keys
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxx
OPENAI_ORG_ID=org-xxxxxxxxxxxxxxxxxxxxx (optional)
```

#### **2. Environment Configuration**
```dart
// lib/utils/api_keys.dart
class ApiKeys {
  static const String openAI = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '', // Empty for offline mode
  );
  
  static const String openAIOrgId = String.fromEnvironment(
    'OPENAI_ORG_ID',
    defaultValue: '',
  );
}
```

#### **3. Service Implementation**
```dart
// lib/services/gpt_service.dart
class GPTService {
  static const String baseUrl = 'https://api.openai.com/v1';
  
  // Topic analysis and categorization
  Future<TopicAnalysis> analyzeTopic(String userInput) async {
    // Implementation details in service file
  }
  
  // Content generation for learning blocks
  Future<LearningContent> generateContent(
    String topic,
    String category,
    String knowledgeLevel,
    String coachPersonality,
  ) async {
    // Implementation details in service file
  }
}
```

### **API Usage Patterns**

#### **Topic Analysis (Step 2 of user flow)**
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "You are an educational content categorizer. Analyze user topics and map them to our 9 categories..."
    },
    {
      "role": "user", 
      "content": "I want to learn about productivity"
    }
  ],
  "temperature": 0.3,
  "max_tokens": 500
}
```

#### **Content Generation (Step 7 of user flow)**
```json
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "You are Sarah, a productivity coach with a strategic, calm personality. Create a 10-minute audio lesson script..."
    },
    {
      "role": "user",
      "content": "Create Day 1 of productivity journey: Foundations level, for user named Alex"
    }
  ],
  "temperature": 0.7,
  "max_tokens": 2000
}
```

### **Cost Optimization**
- **Caching**: Store generated content to avoid regeneration
- **Smart Reuse**: reuse existing content blocks by matching and mixing based on requirement instead of creating new ones
- **Batch Processing**: Generate multiple episodes in single API call
- **Content Versioning**: Track and reuse successful content patterns

### **Error Handling**
```dart
try {
  final response = await openAIClient.generateContent(params);
  return response;
} catch (e) {
  logger.warning('OpenAI API failed: $e');
  // Fallback to cached content or show offline message
  return await getCachedContent(topic, category);
}
```

---

## 🎙️ **ElevenLabs Voice Synthesis**

### **Setup Requirements**

#### **1. Account & API Key**
```bash
# Get API key from: https://elevenlabs.io/speech-synthesis
ELEVENLABS_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxx
```

#### **2. Voice Configuration**
```dart
// lib/models/voice_model.dart
class CoachVoice {
  final String voiceId;
  final String name;
  final CoachPersonality personality;
  final VoiceSettings settings;
  
  // Kai's voice - calm, strategic
  static const kaiVoice = CoachVoice(
    voiceId: 'pNInz6obpgDQGcFmaJgB', // Adam voice
    personality: CoachPersonality.strategic,
    settings: VoiceSettings(
      stability: 0.75,
      similarityBoost: 0.85,
      style: 0.30,
    ),
  );
  
  // Vee's voice - energetic, friendly  
  static const veeVoice = CoachVoice(
    voiceId: 'EXAVITQu4vr4xnSDxMaL', // Sarah voice
    personality: CoachPersonality.energetic,
    settings: VoiceSettings(
      stability: 0.65,
      similarityBoost: 0.75,
      style: 0.60,
    ),
  );
}
```

#### **3. TTS Service Implementation**
```dart
// lib/services/tts_service.dart
class TTSService {
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  
  Future<AudioFile> synthesizeSpeech(
    String text,
    String voiceId,
    VoiceSettings settings,
  ) async {
    // Implementation with file caching
  }
  
  Future<List<Voice>> getAvailableVoices() async {
    // Fetch voice library for custom coaches
  }
}
```

### **Voice Synthesis Flow**
```
GPT Content → Text Processing → ElevenLabs API → Audio File → Local Storage → Playback
```

### **Audio Optimization**
- **File Compression**: Use optimal bitrate for mobile
- **Streaming**: Progressive download for long episodes
- **Caching**: Store audio files locally after download
- **Quality Settings**: Adaptive quality based on connection

### **Error Handling**
```dart
try {
  final audioFile = await synthesizeSpeech(text, voiceId);
  return audioFile;
} catch (e) {
  logger.warning('TTS synthesis failed: $e');
  // Fallback to device TTS or cached audio
  return await deviceTTS.speak(text);
}
```

---

## 🔥 **Firebase Integration**

### **Setup Requirements**

#### **1. Project Configuration**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Add Firebase to Flutter
flutter pub add firebase_core
flutter pub add firebase_auth  
flutter pub add cloud_firestore
flutter pub add firebase_storage
flutter pub add firebase_analytics
flutter pub add firebase_crashlytics
```

#### **2. Configuration Files**
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart (auto-generated)
```

#### **3. Initialize in App**
```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('Firebase initialized successfully');
  } catch (e) {
    logger.warning('Firebase initialization failed: $e');
    // Continue in offline mode
  }
  
  runApp(WismeApp());
}
```

### **Authentication Service**
```dart
// lib/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Email/Password signup
  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Signup failed');
    }
  }
  
  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    // Implementation with google_sign_in package
  }
  
  // Apple Sign-In  
  Future<UserCredential?> signInWithApple() async {
    // Implementation with sign_in_with_apple package
  }
}
```

### **Firestore Database Structure**
```
users/
  {userId}/
    profile: {name, email, preferences}
    learning_progress: {streaks, completed_topics}
    coaches: {created_coaches, relationships}
    
content_blocks/
  {blockId}/
    audio_url: string
    transcript: string
    category: string
    knowledge_level: string
    tags: array
    
user_progress/
  {userId}/
    {topicId}/
      blocks_completed: array
      mastery_level: number
      last_accessed: timestamp
```

### **Storage for Audio Files**
```dart
// lib/services/storage_service.dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadAudio(File audioFile, String path) async {
    final ref = _storage.ref().child('audio/$path');
    final uploadTask = ref.putFile(audioFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
  
  Future<void> downloadAudio(String url, String localPath) async {
    // Download and cache audio files locally
  }
}
```

---

## 📊 **Analytics & Monitoring**

### **Firebase Analytics Events**
```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Track learning events
  Future<void> trackEpisodeCompleted(
    String topicId,
    String category,
    int duration,
  ) async {
    await _analytics.logEvent(
      name: 'episode_completed',
      parameters: {
        'topic_id': topicId,
        'category': category,
        'duration_minutes': duration,
      },
    );
  }
  
  // Track user engagement
  Future<void> trackCoachInteraction(
    String coachName,
    String interactionType,
  ) async {
    await _analytics.logEvent(
      name: 'coach_interaction',
      parameters: {
        'coach_name': coachName,
        'interaction_type': interactionType,
      },
    );
  }
}
```

### **Crashlytics Error Reporting**
```dart
// lib/utils/error_handler.dart
class ErrorHandler {
  static void handleError(dynamic error, StackTrace stackTrace) {
    // Log to console in debug mode
    logger.severe('Error: $error', error, stackTrace);
    
    // Report to Crashlytics in production
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: false,
      );
    }
  }
}
```

---

## 🔒 **Security Best Practices**

### **API Key Management**
```dart
// Never commit API keys to version control
// Use environment variables and dart-define

// Build command:
flutter build apk --dart-define=OPENAI_API_KEY=sk-xxx --dart-define=ELEVENLABS_API_KEY=xxx
```

### **Network Security**
```dart
// lib/services/http_client.dart
class SecureHttpClient {
  static final dio = Dio()
    ..interceptors.add(LogInterceptor())
    ..options.connectTimeout = Duration(seconds: 10)
    ..options.receiveTimeout = Duration(seconds: 30);
    
  // Add authentication headers
  static void addAuthHeaders(String apiKey) {
    dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }
}
```

### **User Data Protection**
- **Local Encryption**: Encrypt sensitive user data
- **HTTPS Only**: All API calls use secure connections
- **Token Refresh**: Implement proper token lifecycle
- **Data Minimization**: Only collect necessary information

---

## 🧪 **Testing API Integration**

### **Unit Tests**
```dart
// test/services/gpt_service_test.dart
void main() {
  group('GPTService Tests', () {
    test('should analyze topic correctly', () async {
      final service = GPTService();
      final result = await service.analyzeTopicMock('productivity');
      
      expect(result.category, equals('Self-Growth'));
      expect(result.confidence, greaterThan(0.8));
    });
  });
}
```

### **Integration Tests**
```dart
// integration_test/api_flow_test.dart
void main() {
  testWidgets('Complete API flow integration', (tester) async {
    // Test full user flow with API integrations
    await tester.pumpWidget(WismeApp());
    
    // Test topic input → analysis → content generation → TTS
    await tester.enterText(find.byType(TextField), 'productivity');
    await tester.tap(find.text('Analyze'));
    await tester.pumpAndSettle();
    
    expect(find.text('Self-Growth'), findsOneWidget);
  });
}
```

---

## 📈 **Monitoring & Optimization**

### **Performance Monitoring**
- **API Response Times**: Track latency for all services
- **Error Rates**: Monitor failed API calls
- **Cost Tracking**: Monitor API usage and costs
- **User Experience**: Track time-to-content metrics

### **Optimization Strategies**
- **Caching Layer**: Redis/Local storage for frequent requests
- **Request Batching**: Combine multiple API calls
- **Progressive Loading**: Stream content as it's generated
- **Fallback Systems**: Graceful degradation when APIs fail

---

*This integration guide ensures robust, scalable, and cost-effective API usage for a world-class learning platform.*
