# 🔌 Wisme API Integration Guide

*Complete guide for integrating external APIs and services*

---

## 🎯 **Overview**

This guide covers all API integrations for the Wisme platform, including OpenAI GPT, ElevenLabs TTS, Firebase services, and internal API architecture.

---

## 🤖 **OpenAI GPT Integration**

### **Setup**
```dart
// lib/utils/api_keys.dart
class ApiKeys {
  static const String openAI = 'your-openai-api-key-here';
  static const String openAIOrganization = 'your-org-id'; // Optional
}
```

### **GPT Service Implementation**
```dart
// lib/services/gpt_service.dart
class GPTService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String model = 'gpt-4-turbo-preview';
  
  Future<String> generateLessonContent({
    required String topic,
    required String category,
    required String knowledgeLevel,
    required String coachPersonality,
  }) async {
    // Implementation in gpt_service.dart
  }
}
```

### **Content Generation Prompts**
```dart
String _buildLessonPrompt(String topic, String category, String level) {
  return '''
  Create a ${level} level lesson about ${topic} in the ${category} category.
  
  Requirements:
  - 10-15 minutes of content
  - Engaging, podcast-style narrative
  - Include practical examples
  - End with actionable takeaways
  
  Format as structured learning blocks with timestamps.
  ''';
}
```

### **Error Handling**
```dart
try {
  final response = await _makeGPTRequest(prompt);
  return _parseResponse(response);
} catch (e) {
  if (e is RateLimitException) {
    // Handle rate limiting
    await Future.delayed(Duration(seconds: 60));
    return await generateLessonContent(/* retry */);
  }
  throw GPTServiceException('Failed to generate content: $e');
}
```

---

## 🎙️ **ElevenLabs TTS Integration**

### **Setup**
```dart
// lib/utils/api_keys.dart
class ApiKeys {
  static const String elevenLabs = 'your-elevenlabs-api-key';
}
```

### **Voice Configuration**
```dart
// Kai - Strategic Coach
static const String kaiVoiceId = 'voice-id-for-kai';

// Vee - Energetic Coach  
static const String veeVoiceId = 'voice-id-for-vee';

// Voice settings
Map<String, dynamic> get voiceSettings => {
  'stability': 0.75,
  'similarity_boost': 0.85,
  'style': 0.2,
  'use_speaker_boost': true,
};
```

### **Audio Generation**
```dart
Future<Uint8List> generateAudio({
  required String text,
  required String voiceId,
  Map<String, dynamic>? customSettings,
}) async {
  final url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Accept': 'audio/mpeg',
      'Content-Type': 'application/json',
      'xi-api-key': ApiKeys.elevenLabs,
    },
    body: jsonEncode({
      'text': text,
      'model_id': 'eleven_monolingual_v1',
      'voice_settings': customSettings ?? voiceSettings,
    }),
  );
  
  return response.bodyBytes;
}
```

### **Audio Caching Strategy**
```dart
class AudioCacheService {
  static const String cacheDir = 'audio_cache';
  
  Future<String> cacheAudio(Uint8List audioData, String blockId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$cacheDir/$blockId.mp3');
    await file.writeAsBytes(audioData);
    return file.path;
  }
}
```

---

## 🔥 **Firebase Integration**

### **Authentication**
```dart
// lib/services/auth_services.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Email/Password Authentication
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }
  
  // Google Sign In
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    
    final UserCredential result = await _auth.signInWithCredential(credential);
    return result.user;
  }
}
```

### **Firestore Database Structure**
```dart
// Users Collection
/users/{userId} {
  displayName: string,
  email: string,
  createdAt: timestamp,
  learningProfile: {
    totalLearningTime: number,
    streakDays: number,
    completedTopics: array,
    preferences: object
  }
}

// Content Blocks Collection
/contentBlocks/{blockId} {
  title: string,
  category: string,
  difficulty: string,
  script: string,
  audioUrl: string,
  duration: number,
  tags: array,
  createdAt: timestamp
}

// Learning Journeys Collection
/learningJourneys/{journeyId} {
  userId: string,
  topic: string,
  category: string,
  blocks: array,
  progress: object,
  startDate: timestamp,
  completedAt: timestamp
}
```

### **Firestore Service Implementation**
```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Save user progress
  Future<void> updateUserProgress(String userId, Map<String, dynamic> progress) async {
    await _db.collection('users').doc(userId).update({
      'learningProfile.progress': progress,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
  
  // Get content blocks by category
  Future<List<ContentBlock>> getContentBlocks({String? category, int? limit}) async {
    Query query = _db.collection('contentBlocks');
    
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    final QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) => ContentBlock.fromFirestore(doc)).toList();
  }
}
```

### **Cloud Storage for Audio Files**
```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadAudio(Uint8List audioData, String fileName) async {
    final ref = _storage.ref().child('audio/$fileName');
    final UploadTask uploadTask = ref.putData(audioData);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
  
  Future<Uint8List?> downloadAudio(String audioUrl) async {
    try {
      final ref = _storage.refFromURL(audioUrl);
      return await ref.getData();
    } catch (e) {
      AppLogger.error('Failed to download audio: $e');
      return null;
    }
  }
}
```

---

## 🌐 **Internal API Architecture**

### **API Response Models**
```dart
// Standard API Response Wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  
  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }
}
```

### **HTTP Client Configuration**
```dart
class ApiClient {
  static const String baseUrl = 'https://api.wisme.app/v1';
  late final Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token
        final token = UserProvider.instance.authToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        AppLogger.error('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
}
```

---

## 🔐 **Security & Error Handling**

### **API Key Security**
```dart
// Use environment variables in production
class ApiKeys {
  static String get openAI => const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'your-dev-key-here',
  );
  
  static String get elevenLabs => const String.fromEnvironment(
    'ELEVENLABS_API_KEY', 
    defaultValue: 'your-dev-key-here',
  );
}
```

### **Rate Limiting**
```dart
class RateLimiter {
  final Map<String, DateTime> _lastRequest = {};
  final Duration _minInterval = Duration(seconds: 1);
  
  Future<void> waitIfNeeded(String endpoint) async {
    final lastRequest = _lastRequest[endpoint];
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastRequest[endpoint] = DateTime.now();
  }
}
```

### **Offline Handling**
```dart
class OfflineService {
  static bool get isOnline => Connectivity().checkConnectivity() != ConnectivityResult.none;
  
  Future<T> executeWithFallback<T>(
    Future<T> Function() onlineAction,
    Future<T> Function() offlineAction,
  ) async {
    try {
      if (isOnline) {
        return await onlineAction();
      } else {
        return await offlineAction();
      }
    } catch (e) {
      if (e is SocketException || e is TimeoutException) {
        return await offlineAction();
      }
      rethrow;
    }
  }
}
```

---

## 📊 **API Performance Monitoring**

### **Request Logging**
```dart
class ApiLogger {
  static void logRequest(String endpoint, Duration duration, bool success) {
    final logData = {
      'endpoint': endpoint,
      'duration_ms': duration.inMilliseconds,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // Send to analytics service
    AnalyticsService.track('api_request', logData);
  }
}
```

### **Cache Strategy**
```dart
class ApiCache {
  static const Duration defaultTTL = Duration(hours: 1);
  
  Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cache_$key');
    if (data != null) {
      final cached = jsonDecode(data);
      final expiry = DateTime.parse(cached['expiry']);
      if (DateTime.now().isBefore(expiry)) {
        return cached['data'] as T;
      }
    }
    return null;
  }
  
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(ttl ?? defaultTTL);
    final cached = {
      'data': data,
      'expiry': expiry.toIso8601String(),
    };
    await prefs.setString('cache_$key', jsonEncode(cached));
  }
}
```

---

## 🧪 **Testing API Integrations**

### **Mock Services for Testing**
```dart
class MockGPTService implements GPTService {
  @override
  Future<String> generateLessonContent({
    required String topic,
    required String category,
    required String knowledgeLevel,
    required String coachPersonality,
  }) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay
    return 'Mock lesson content for $topic';
  }
}
```

### **Integration Tests**
```dart
void main() {
  group('API Integration Tests', () {
    late GPTService gptService;
    
    setUp(() {
      gptService = GPTService();
    });
    
    testWidgets('Generate lesson content', (tester) async {
      final content = await gptService.generateLessonContent(
        topic: 'Flutter State Management',
        category: 'Technology',
        knowledgeLevel: 'intermediate',
        coachPersonality: 'kai',
      );
      
      expect(content, isNotEmpty);
      expect(content.length, greaterThan(100));
    });
  });
}
```

---

## 📋 **API Checklist**

### **Before Production**
- [ ] Replace all development API keys with production keys
- [ ] Set up environment variable management
- [ ] Configure rate limiting and quotas
- [ ] Implement comprehensive error handling
- [ ] Set up monitoring and alerting
- [ ] Test offline functionality
- [ ] Validate security measures

### **Performance Optimization**
- [ ] Implement response caching
- [ ] Add request deduplication
- [ ] Optimize payload sizes
- [ ] Use connection pooling
- [ ] Monitor API response times
- [ ] Set up circuit breakers for failing services

---

## 🔗 **Additional Resources**

- **OpenAI API Documentation**: https://platform.openai.com/docs
- **ElevenLabs API Documentation**: https://docs.elevenlabs.io/
- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter HTTP Package**: https://pub.dev/packages/http
- **Dio HTTP Client**: https://pub.dev/packages/dio

---

*API integration guide for the Wisme development team*
*Last updated: July 5, 2025*
