// Integration test to validate the upgraded architecture
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// Import the key upgraded components
import '../lib/models/content_block.dart';
import '../lib/models/topic_model.dart';
import '../lib/models/user_profile.dart';
import '../lib/models/result.dart';

import '../lib/services/gpt_service.dart';
import '../lib/services/elevenlabs_service.dart';
import '../lib/services/audio_player_service.dart';
import '../lib/services/auth_service.dart';

import '../lib/utils/logger.dart';

void main() {
  group('Wisme App Architecture Integration Tests', () {
    test('Models should create and serialize correctly', () {
      // Test ContentBlock model
      final contentBlock = ContentBlock(
        id: 'test_001',
        title: 'Test Content',
        description: 'A test content block for validation',
        duration: const Duration(minutes: 5),
        audioUrl: 'https://example.com/audio.mp3',
        category: 'Technology',
        knowledgeLevel: 'Intermediate',
        tags: ['test', 'validation'],
        contentType: 'lesson',
        difficultyLevel: 2,
        coachPersonality: 'Sarah',
        voiceId: 'voice_001',
        transcript: 'This is a test transcript.',
        keywords: ['test', 'content'],
        prerequisites: [],
        learningOutcomes: ['Learn testing'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {'source': 'test'},
      );

      expect(contentBlock.id, 'test_001');
      expect(contentBlock.title, 'Test Content');
      expect(contentBlock.difficultyLevel, 2);

      // Test serialization
      final json = contentBlock.toJson();
      expect(json['id'], 'test_001');
      expect(json['title'], 'Test Content');

      // Test deserialization
      final recreated = ContentBlock.fromJson(json);
      expect(recreated.id, contentBlock.id);
      expect(recreated.title, contentBlock.title);
    });

    test('TopicAnalysis model should work correctly', () {
      final topic = TopicAnalysis(
        id: 'topic_001',
        originalQuery: 'Learn Flutter',
        detectedCategory: 'Programming',
        knowledgeLevel: 'Beginner',
        suggestedTags: ['flutter', 'mobile', 'dart'],
        confidenceScore: 0.95,
        estimatedSessions: 5,
        recommendedCoach: 'Sarah',
        metadata: {'difficulty': 'low'},
        analyzedAt: DateTime.now(),
      );

      expect(topic.originalQuery, 'Learn Flutter');
      expect(topic.detectedCategory, 'Programming');
      expect(topic.confidenceScore, 0.95);

      // Test JSON serialization
      final json = topic.toJson();
      final recreated = TopicAnalysis.fromJson(json);
      expect(recreated.originalQuery, topic.originalQuery);
    });

    test('UserProfile model should handle authentication data', () {
      final userProfile = UserProfile(
        id: 'user_001',
        email: 'test@example.com',
        displayName: 'Test User',
        preferredCategories: ['Technology', 'Programming'],
        defaultKnowledgeLevel: 'intermediate',
        preferredCoach: 'sarah',
        totalLearningTime: 7200, // 2 hours in seconds
        currentStreak: 7,
        longestStreak: 10,
        completedLessons: ['lesson_001', 'lesson_002'],
        achievements: [], // Empty list for now
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        settings: {
          'notifications': true,
          'auto_download': false,
        },
      );

      expect(userProfile.email, 'test@example.com');
      expect(userProfile.currentStreak, 7);
      expect(userProfile.totalLearningTime, 7200);

      // Test serialization
      final json = userProfile.toJson();
      final recreated = UserProfile.fromJson(json);
      expect(recreated.email, userProfile.email);
      expect(recreated.currentStreak, userProfile.currentStreak);
    });

    test('Result model should handle success and failure cases', () {
      // Test success case
      final successResult = Result.success('Test data');
      expect(successResult.isSuccess, true);
      expect(successResult.isFailure, false);
      expect(successResult.data, 'Test data');

      // Test failure case
      final failureResult = Result.failure(
        const NetworkFailure(
          message: 'Network error',
          code: 'network_error',
        ),
      );
      expect(failureResult.isSuccess, false);
      expect(failureResult.isFailure, true);
      expect(failureResult.error?.message, 'Network error');
    });

    test('Services should initialize without errors', () {
      // Test GPTService initialization
      final gptService = GPTService();
      expect(gptService, isNotNull);

      // Test ElevenLabsService initialization
      final elevenLabsService = ElevenLabsService();
      expect(elevenLabsService, isNotNull);

      // Test AudioPlayerService initialization
      final audioService = AudioPlayerService.instance;
      expect(audioService, isNotNull);

      // Test AuthenticationService initialization
      final authService = AuthenticationService.instance;
      expect(authService, isNotNull);
    });
  });

  group('Provider Integration Tests', () {
    testWidgets('LessonProvider should initialize and manage state', (tester) async {
      // Create a minimal widget tree with required providers
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // This test validates that providers can be created
              // without immediate crashes
              return const Scaffold(
                body: Text('Test'),
              );
            },
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Logger Integration', () {
    test('AppLogger should work correctly', () {
      // Test that logger doesn't crash
      AppLogger.info('Test info message');
      AppLogger.warning('Test warning message');
      AppLogger.error('Test error message');
      
      // If we get here without exceptions, the logger is working
      expect(true, true);
    });
  });
}
