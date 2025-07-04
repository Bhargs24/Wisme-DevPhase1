# 🔌 Wisme API Integration Guide

*Complete guide for integrating external APIs and building internal endpoints*

---

## 🎯 Overview

This document outlines all API integrations needed for Wisme, including external services (OpenAI, ElevenLabs, Firebase) and internal API design for the learning system.

---

## 🤖 OpenAI Integration

### **Authentication**
```dart
class GPTService {
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String apiKey = ApiKeys.openAiApiKey;
  
  static Map<String, String> get headers => {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };
}
```

### **Topic Analysis Endpoint**
```dart
// Analyze user input and categorize
Future<TopicAnalysis> analyzeUserTopic(String userInput) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/completions'),
    headers: headers,
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {
          'role': 'system',
          'content': '''You are an educational content analyzer. Given a user topic, analyze it and return a JSON response with:
          - category: one of [Technology, Business, Psychology, Science, Creativity, Self-Growth, History, Skills, Career]
          - intent: what the user wants to learn (concepts, stories, tools, mixed)
          - difficulty: suggested level (beginner, intermediate, advanced)
          - keywords: relevant tags for content matching
          - clarification: questions to ask if topic is vague'''
        },
        {'role': 'user', 'content': userInput}
      ],
      'max_tokens': 500,
      'temperature': 0.3,
    }),
  );
  return TopicAnalysis.fromJson(jsonDecode(response.body));
}
```

### **Content Generation Endpoint**
```dart
// Generate learning content blocks
Future<ContentBlock> generateContentBlock({
  required String topic,
  required String category,
  required String level,
  required String contentType, // story, concept, tool, example
  String? userContext,
}) async {
  final systemPrompt = '''Generate educational content for a ${level} learner about ${topic} in the ${category} category.
  Content type: ${contentType}
  
  Format as a podcast script for an AI voice coach.
  Include:
  - Engaging hook (30 seconds)
  - Main content (8-10 minutes)
  - Key takeaway (1 minute)
  - Next episode tease (30 seconds)
  
  Style: Conversational, storytelling, practical insights.
  ${userContext != null ? 'User context: $userContext' : ''}''';
  
  final response = await http.post(
    Uri.parse('$baseUrl/chat/completions'),
    headers: headers,
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': 'Generate the content block.'}
      ],
      'max_tokens': 2000,
      'temperature': 0.7,
    }),
  );
  return ContentBlock.fromJson(jsonDecode(response.body));
}
```

### **Journey Creation Endpoint**
```dart
// Create complete learning journey
Future<LearningJourney> createLearningJourney({
  required String topic,
  required String category,
  required String level,
  required int durationDays,
  List<String>? existingKnowledge,
}) async {
  final systemPrompt = '''Create a ${durationDays}-day learning journey for "${topic}" in ${category} category at ${level} level.
  
  Structure each day with:
  - Learning objective
  - Content blocks needed (story, concept, tool, example)
  - Key questions to explore
  - Practical application
  
  Return as JSON with daily breakdown and content block specifications.
  ${existingKnowledge != null ? 'User already knows: ${existingKnowledge.join(", ")}' : ''}''';
  
  final response = await http.post(
    Uri.parse('$baseUrl/chat/completions'),
    headers: headers,
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': 'Create the learning journey.'}
      ],
      'max_tokens': 3000,
      'temperature': 0.5,
    }),
  );
  return LearningJourney.fromJson(jsonDecode(response.body));
}
```

---

## 🎙️ ElevenLabs TTS Integration

### **Authentication**
```dart
class TTSService {
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  static const String apiKey = ApiKeys.elevenLabsApiKey;
  
  static Map<String, String> get headers => {
    'xi-api-key': apiKey,
    'Content-Type': 'application/json',
  };
}
```

### **Voice Configuration**
```dart
// Coach voice mappings
class CoachVoices {
  static const Map<String, String> voiceIds = {
    'kai': '21m00Tcm4TlvDq8ikWAM',    // Professional male voice
    'vee': '2EiwWnXFnvU5JabPnv8n',    // Energetic female voice
    'custom': 'pNInz6obpgDQGcFmaJgB',  // Neutral voice for custom coaches
  };
  
  static const Map<String, VoiceSettings> voiceSettings = {
    'kai': VoiceSettings(stability: 0.7, similarityBoost: 0.6),
    'vee': VoiceSettings(stability: 0.5, similarityBoost: 0.8),
    'custom': VoiceSettings(stability: 0.6, similarityBoost: 0.7),
  };
}

class VoiceSettings {
  final double stability;
  final double similarityBoost;
  
  const VoiceSettings({required this.stability, required this.similarityBoost});
  
  Map<String, dynamic> toJson() => {
    'stability': stability,
    'similarity_boost': similarityBoost,
  };
}
```

### **Text-to-Speech Endpoint**
```dart
// Generate speech from text
Future<Uint8List> generateSpeech({
  required String text,
  required String coachId,
  String? customVoiceId,
}) async {
  final voiceId = customVoiceId ?? CoachVoices.voiceIds[coachId]!;
  final voiceSettings = CoachVoices.voiceSettings[coachId]!;
  
  final response = await http.post(
    Uri.parse('$baseUrl/text-to-speech/$voiceId'),
    headers: headers,
    body: jsonEncode({
      'text': text,
      'voice_settings': voiceSettings.toJson(),
      'model_id': 'eleven_monolingual_v1', // or 'eleven_multilingual_v2'
    }),
  );
  
  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw TTSException('Failed to generate speech: ${response.body}');
  }
}
```

### **Batch Processing for Episodes**
```dart
// Generate complete episode audio
Future<String> generateEpisodeAudio({
  required List<ContentBlock> blocks,
  required String coachId,
  required String episodeId,
}) async {
  final audioSegments = <Uint8List>[];
  
  for (final block in blocks) {
    final audioData = await generateSpeech(
      text: block.script,
      coachId: coachId,
    );
    audioSegments.add(audioData);
    
    // Add transition silence if needed
    if (block != blocks.last) {
      audioSegments.add(generateSilence(milliseconds: 500));
    }
  }
  
  // Combine all segments into single file
  final combinedAudio = combineAudioSegments(audioSegments);
  
  // Save to storage and return URL
  return await StorageService.saveEpisodeAudio(
    episodeId: episodeId,
    audioData: combinedAudio,
  );
}
```

---

## 🔥 Firebase Integration

### **Authentication Service**
```dart
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sign in with email/password
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }
  
  // Google Sign In
  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }
  
  // Create user profile
  static Future<void> createUserProfile(User user, {
    String? displayName,
    String? preferredCoach,
    List<String>? interests,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': displayName ?? user.displayName,
      'preferredCoach': preferredCoach ?? 'kai',
      'interests': interests ?? [],
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }
}
```

### **Firestore Database Structure**
```dart
// User profile document
class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String preferredCoach;
  final List<String> interests;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  
  // Firestore conversion methods
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      preferredCoach: data['preferredCoach'],
      interests: List<String>.from(data['interests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'preferredCoach': preferredCoach,
    'interests': interests,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastActiveAt': Timestamp.fromDate(lastActiveAt),
  };
}
```

### **Learning Progress Tracking**
```dart
// Track user progress on content blocks
class ProgressService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Record block completion
  static Future<void> recordBlockCompletion({
    required String userId,
    required String blockId,
    required String journeyId,
    required String episodeId,
    required Duration listenTime,
    double? completionPercentage,
    Map<String, dynamic>? engagementData,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(blockId)
        .set({
      'blockId': blockId,
      'journeyId': journeyId,
      'episodeId': episodeId,
      'completedAt': FieldValue.serverTimestamp(),
      'listenTime': listenTime.inSeconds,
      'completionPercentage': completionPercentage ?? 1.0,
      'engagementData': engagementData ?? {},
      'lastAccessed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
  
  // Get user's learning analytics
  static Future<LearningAnalytics> getLearningAnalytics(String userId) async {
    final progressDocs = await _db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .get();
    
    return LearningAnalytics.fromProgressDocs(progressDocs.docs);
  }
  
  // Check if user has completed prerequisite content
  static Future<bool> hasCompletedPrerequisites({
    required String userId,
    required List<String> prerequisiteBlockIds,
  }) async {
    final completedBlocks = await _db
        .collection('users')
        .doc(userId)
        .collection('progress')
        .where('blockId', whereIn: prerequisiteBlockIds)
        .where('completionPercentage', isGreaterThanOrEqualTo: 0.8)
        .get();
    
    return completedBlocks.docs.length == prerequisiteBlockIds.length;
  }
}
```

---

## 🏗️ Internal API Design

### **Content Block Management**
```dart
// Content block model for database storage
class ContentBlock {
  final String id;
  final String category;
  final String topic;
  final String contentType; // story, concept, tool, example
  final String difficulty;  // beginner, intermediate, advanced
  final String script;      // Text content for TTS
  final String audioUrl;    // Generated audio file URL
  final List<String> tags;  // Hashtags for content discovery
  final List<String> prerequisites; // Required prior knowledge
  final Duration duration;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  
  // Database conversion methods
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'category': category,
    'topic': topic,
    'contentType': contentType,
    'difficulty': difficulty,
    'script': script,
    'audioUrl': audioUrl,
    'tags': tags,
    'prerequisites': prerequisites,
    'durationSeconds': duration.inSeconds,
    'metadata': metadata,
    'createdAt': Timestamp.fromDate(createdAt),
  };
  
  factory ContentBlock.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentBlock(
      id: data['id'],
      category: data['category'],
      topic: data['topic'],
      contentType: data['contentType'],
      difficulty: data['difficulty'],
      script: data['script'],
      audioUrl: data['audioUrl'],
      tags: List<String>.from(data['tags']),
      prerequisites: List<String>.from(data['prerequisites']),
      duration: Duration(seconds: data['durationSeconds']),
      metadata: data['metadata'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
```

### **Learning Journey API**
```dart
// Journey management service
class JourneyService {
  static Future<LearningJourney> createJourney({
    required String userId,
    required String topic,
    required String category,
    required String level,
    required int durationDays,
  }) async {
    // 1. Check for existing content blocks
    final existingBlocks = await findExistingContentBlocks(
      topic: topic,
      category: category,
      level: level,
    );
    
    // 2. Generate journey structure with OpenAI
    final journeyStructure = await GPTService.createLearningJourney(
      topic: topic,
      category: category,
      level: level,
      durationDays: durationDays,
      existingKnowledge: await getUserKnowledge(userId),
    );
    
    // 3. Create missing content blocks
    final allBlocks = await ensureContentBlocks(
      existingBlocks: existingBlocks,
      requiredBlocks: journeyStructure.requiredBlocks,
    );
    
    // 4. Save journey to database
    final journey = LearningJourney(
      id: generateId(),
      userId: userId,
      topic: topic,
      category: category,
      level: level,
      blocks: allBlocks,
      estimatedDuration: Duration(days: durationDays),
      createdAt: DateTime.now(),
    );
    
    await FirebaseFirestore.instance
        .collection('journeys')
        .doc(journey.id)
        .set(journey.toFirestore());
    
    return journey;
  }
  
  // Smart content block discovery
  static Future<List<ContentBlock>> findExistingContentBlocks({
    required String topic,
    required String category,
    required String level,
  }) async {
    final query = await FirebaseFirestore.instance
        .collection('content_blocks')
        .where('category', isEqualTo: category)
        .where('difficulty', isEqualTo: level)
        .where('tags', arrayContainsAny: generateTopicTags(topic))
        .get();
    
    return query.docs
        .map((doc) => ContentBlock.fromFirestore(doc))
        .toList();
  }
}
```

### **Recommendation Engine API**
```dart
// Personalized content recommendations
class RecommendationService {
  // Get next content recommendations
  static Future<List<ContentBlock>> getRecommendations({
    required String userId,
    int limit = 10,
  }) async {
    final userProfile = await getUserProfile(userId);
    final completedBlocks = await getCompletedBlocks(userId);
    final learningPatterns = await analyzeLearningPatterns(userId);
    
    // AI-powered recommendation logic
    final recommendations = await GPTService.generateRecommendations(
      userInterests: userProfile.interests,
      completedContent: completedBlocks.map((b) => b.id).toList(),
      learningVelocity: learningPatterns.averageCompletionTime,
      preferredContentTypes: learningPatterns.preferredTypes,
      optimalLearningTimes: learningPatterns.optimalTimes,
    );
    
    return await fetchContentBlocks(recommendations.blockIds);
  }
  
  // Analyze user learning patterns
  static Future<LearningPatterns> analyzeLearningPatterns(String userId) async {
    final progressDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .orderBy('completedAt', descending: true)
        .limit(50)
        .get();
    
    // Analyze engagement patterns, completion times, content preferences
    return LearningPatterns.fromProgressData(progressDocs.docs);
  }
}
```

---

## 🔒 Security & Rate Limiting

### **API Key Management**
```dart
// Secure API key storage
class SecureApiKeys {
  static Future<void> initializeKeys() async {
    // Use flutter_secure_storage for production
    const storage = FlutterSecureStorage();
    
    // Store encrypted keys
    await storage.write(key: 'openai_key', value: ApiKeys.openAiApiKey);
    await storage.write(key: 'elevenlabs_key', value: ApiKeys.elevenLabsApiKey);
  }
  
  static Future<String?> getOpenAIKey() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'openai_key');
  }
}
```

### **Rate Limiting**
```dart
// Implement rate limiting for API calls
class RateLimiter {
  static final Map<String, int> _callCounts = {};
  static final Map<String, DateTime> _lastReset = {};
  
  // OpenAI rate limiting (60 requests/minute)
  static Future<bool> canMakeOpenAICall() async {
    const maxCalls = 60;
    const windowMinutes = 1;
    
    final now = DateTime.now();
    final key = 'openai_${now.hour}_${now.minute}';
    
    if (!_callCounts.containsKey(key)) {
      _callCounts[key] = 0;
      _lastReset[key] = now;
    }
    
    if (_callCounts[key]! >= maxCalls) {
      final timeSinceReset = now.difference(_lastReset[key]!);
      if (timeSinceReset.inMinutes >= windowMinutes) {
        _callCounts[key] = 0;
        _lastReset[key] = now;
      } else {
        return false; // Rate limit exceeded
      }
    }
    
    _callCounts[key] = _callCounts[key]! + 1;
    return true;
  }
}
```

---

## 📊 Error Handling & Monitoring

### **API Error Handling**
```dart
// Centralized error handling for API calls
class ApiErrorHandler {
  static Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on SocketException {
      throw NetworkException('No internet connection');
    } on HttpException catch (e) {
      if (e.message.contains('429')) {
        throw RateLimitException('Rate limit exceeded');
      } else if (e.message.contains('401')) {
        throw AuthException('Invalid API key');
      } else {
        throw ApiException('API error: ${e.message}');
      }
    } catch (e) {
      throw UnknownException('Unexpected error: $e');
    }
  }
}

// Custom exception classes
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}
```

### **Performance Monitoring**
```dart
// Track API performance metrics
class ApiMetrics {
  static Future<void> recordApiCall({
    required String endpoint,
    required Duration responseTime,
    required bool success,
    String? errorType,
  }) async {
    await FirebaseFirestore.instance.collection('api_metrics').add({
      'endpoint': endpoint,
      'responseTimeMs': responseTime.inMilliseconds,
      'success': success,
      'errorType': errorType,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

---

*Complete API integration guide for building a robust, scalable learning platform* 🚀
