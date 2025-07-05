import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../shared/models/result.dart';
import '../../coach/models/coach_model.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/api_keys.dart';

/// Production-grade OpenAI GPT service for the new architecture
class GPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _apiKey = ApiKeys.openAiApiKey;

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  /// Analyze user topic input and categorize it
  Future<Result<TopicAnalysis>> analyzeUserTopic(String userInput) async {
    try {
      final systemPrompt = '''You are an expert educational content analyzer for a premium podcast-style learning platform. Given a user topic, analyze it and return a JSON response with:

- category: one of [Technology, Business & Finance, Psychology & Mind, Science & Nature, Creativity & Design, Self-Growth, History & Culture, Skills & Tools, Career & Strategy, Law & Governance, Geopolitics & Global Affairs, Environment & Sustainability, Mathematics & Logic, Gaming & Interactive Media, Society & Ethics, Futurism & Exploration]
- intent: what the user wants to learn (concepts, stories, tools, mixed, practical_application)
- difficulty: suggested level (beginner, intermediate, advanced)
- keywords: relevant tags for content matching and discovery
- clarification: engaging questions to ask if topic is vague

Be specific and helpful. Make clarification questions engaging and conversational, like a curious podcast host.''';

      final userPrompt = '''Analyze this learning topic: "$userInput"

Return JSON format:
{
  "category": "Technology",
  "intent": "concepts",
  "difficulty": "beginner",
  "keywords": ["ai", "machine learning", "basics"],
  "clarification": ["Are you interested in building AI or understanding how it works?"]
}''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final analysisData = jsonDecode(content);

        final analysis = TopicAnalysis(
          originalTopic: userInput,
          category: analysisData['category'] ?? 'Technology',
          intent: analysisData['intent'] ?? 'concepts',
          difficulty: analysisData['difficulty'] ?? 'beginner',
          keywords: List<String>.from(analysisData['keywords'] ?? []),
          clarificationQuestions: List<String>.from(analysisData['clarification'] ?? []),
        );

        AppLogger.info('✅ Topic analyzed successfully: ${analysis.category}');
        return Result.success(analysis);
      } else {
        AppLogger.error('❌ Failed to analyze topic: ${response.statusCode}');
        return Result.failure('Failed to analyze topic: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error analyzing topic: $e');
      return Result.failure('Error analyzing topic: $e');
    }
  }

  /// Generate premium podcast-style content
  Future<Result<ContentBlock>> generateContent({
    required String topic,
    required String category,
    required String level,
    String? style,
    String? coachPersonality,
    Duration? targetDuration,
  }) async {
    try {
      final systemPrompt = '''You are an elite content creator for a premium AI-powered learning platform. You create world-class, podcast-style educational content that rivals the best human-produced episodes.

Your content is used by millions of learners worldwide who expect:
- Professional broadcast quality
- Engaging storytelling
- Clear explanations
- Premium production value
- Memorable insights

Create content that sounds like it was crafted by the world's best educational podcast producers, combining the expertise of NPR, TED, and premium educational content creators.

Return a JSON response with:
{
  "title": "Compelling episode title",
  "script": "Full episode script optimized for TTS",
  "summary": "Brief engaging summary",
  "key_points": ["Key takeaway 1", "Key takeaway 2", "Key takeaway 3"],
  "estimated_duration": 600
}

The script should be:
- Conversational and engaging
- Optimized for text-to-speech delivery
- Include natural pauses and emphasis
- Use storytelling techniques
- Be approximately ${targetDuration?.inSeconds ?? 600} seconds when spoken''';

      final userPrompt = '''Create premium podcast-style content for:
Topic: $topic
Category: $category
Level: $level
Style: ${style ?? 'engaging and conversational'}
Coach Personality: ${coachPersonality ?? 'professional and friendly'}
Target Duration: ${targetDuration?.inMinutes ?? 10} minutes

Make this sound like a premium podcast that listeners would eagerly recommend to friends.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 3000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final contentData = jsonDecode(content);

        final contentBlock = ContentBlock(
          id: _generateContentId(),
          topic: topic,
          category: category,
          level: level,
          title: contentData['title'] ?? 'Learning: $topic',
          script: contentData['script'] ?? '',
          summary: contentData['summary'] ?? '',
          keyPoints: List<String>.from(contentData['key_points'] ?? []),
          estimatedDuration: Duration(seconds: contentData['estimated_duration'] ?? 600),
          createdAt: DateTime.now(),
          metadata: {
            'style': style,
            'coach_personality': coachPersonality,
            'generated_by': 'gpt-4o',
          },
        );

        AppLogger.info('✅ Content generated successfully: ${contentBlock.title}');
        return Result.success(contentBlock);
      } else {
        AppLogger.error('❌ Failed to generate content: ${response.statusCode}');
        return Result.failure('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error generating content: $e');
      return Result.failure('Error generating content: $e');
    }
  }

  /// Enhance script for optimal TTS delivery
  Future<Result<String>> enhanceScriptForTTS({
    required String script,
    required String coachPersonality,
  }) async {
    try {
      final systemPrompt = '''You are an elite audio production specialist and voice coach who optimizes premium educational content for the most advanced text-to-speech systems. Your work transforms AI voices into compelling, natural-sounding radio hosts and podcast narrators.

You've worked with NPR, BBC, Spotify Originals, and premium podcast networks to create audio that listeners can't distinguish from human hosts.

ADVANCED TTS OPTIMIZATION:
- Optimize punctuation for natural TTS breathing and phrasing
- Add strategic commas for micro-pauses that create conversational rhythm
- Use ellipses... for contemplative pauses and dramatic effect
- Include em dashes — for natural speech interruptions and asides
- Break complex sentences into digestible, conversational chunks
- Add natural speech connectors: "Now here's the thing...", "But wait...", "Here's what's fascinating..."
- Use varied sentence structures to prevent monotone AI delivery
- Include vocal variety cues through strategic punctuation placement

PERSONALITY VOICE COACHING:
- Adapt speech patterns to perfectly match: $coachPersonality
- Include personality-specific verbal tics and phrases that feel authentic
- Add natural emotional reactions and vocal expressions
- Ensure consistent character voice throughout the entire script

Return the enhanced script as polished, TTS-optimized text that will sound like a professional radio host delivering premium educational content.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': 'Optimize this script for TTS: $script'},
          ],
          'max_tokens': 1500,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final enhancedScript = data['choices'][0]['message']['content'];

        AppLogger.info('✅ Script enhanced for TTS successfully');
        return Result.success(enhancedScript);
      } else {
        AppLogger.error('❌ Failed to enhance script: ${response.statusCode}');
        return Result.failure('Failed to enhance script: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error enhancing script: $e');
      return Result.failure('Error enhancing script: $e');
    }
  }

  /// Generate personalized learning recommendations
  Future<Result<List<String>>> generateRecommendations({
    required String userProfile,
    required List<String> completedTopics,
    required String preferredCategory,
    int count = 5,
  }) async {
    try {
      final systemPrompt = '''You are an AI learning advisor for a premium educational platform. Based on the user's profile and learning history, recommend engaging topics that will accelerate their growth.

Consider:
- User's current knowledge level and interests
- Topics they've already completed
- Natural progression paths
- Trending and valuable skills
- Personalized recommendations

Return a JSON array of topic recommendations:
["Topic 1", "Topic 2", "Topic 3", ...]

Make recommendations specific, actionable, and engaging.''';

      final userPrompt = '''Generate $count personalized learning recommendations for:

User Profile: $userProfile
Completed Topics: ${completedTopics.join(', ')}
Preferred Category: $preferredCategory

Focus on topics that build naturally from their existing knowledge while introducing exciting new concepts.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 800,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final recommendations = List<String>.from(jsonDecode(content));

        AppLogger.info('✅ Generated ${recommendations.length} recommendations');
        return Result.success(recommendations);
      } else {
        AppLogger.error('❌ Failed to generate recommendations: ${response.statusCode}');
        return Result.failure('Failed to generate recommendations: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error generating recommendations: $e');
      return Result.failure('Error generating recommendations: $e');
    }
  }

  /// Generate learning path for a topic
  Future<Result<LearningPath>> generateLearningPath({
    required String topic,
    required String userLevel,
    required Duration timeframe,
  }) async {
    try {
      final systemPrompt = '''You are an expert curriculum designer for a premium AI learning platform. Create a structured learning path that takes users from their current level to mastery.

Design a path that includes:
- Logical progression of concepts
- Appropriate pacing for the timeframe
- Mix of theory and practical application
- Clear milestones and checkpoints

Return JSON format:
{
  "title": "Learning Path Title",
  "description": "Path overview",
  "estimated_duration": "2 weeks",
  "milestones": [
    {
      "title": "Milestone 1",
      "description": "What they'll learn",
      "topics": ["Topic 1", "Topic 2"],
      "duration_days": 3
    }
  ]
}''';

      final userPrompt = '''Create a comprehensive learning path for:
Topic: $topic
User Level: $userLevel
Timeframe: ${timeframe.inDays} days

Design this to be engaging, practical, and achievable within the timeframe.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 1200,
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final pathData = jsonDecode(content);

        final learningPath = LearningPath(
          id: _generatePathId(),
          title: pathData['title'] ?? 'Learning Path: $topic',
          description: pathData['description'] ?? '',
          estimatedDuration: pathData['estimated_duration'] ?? '${timeframe.inDays} days',
          milestones: (pathData['milestones'] as List)
              .map((m) => LearningMilestone(
                    title: m['title'] ?? '',
                    description: m['description'] ?? '',
                    topics: List<String>.from(m['topics'] ?? []),
                    durationDays: m['duration_days'] ?? 1,
                  ))
              .toList(),
          createdAt: DateTime.now(),
        );

        AppLogger.info('✅ Learning path generated: ${learningPath.title}');
        return Result.success(learningPath);
      } else {
        AppLogger.error('❌ Failed to generate learning path: ${response.statusCode}');
        return Result.failure('Failed to generate learning path: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('❌ Error generating learning path: $e');
      return Result.failure('Error generating learning path: $e');
    }
  }

  /// Check API key validity
  Future<bool> validateApiKey() async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Hello'},
          ],
          'max_tokens': 1,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('❌ API key validation failed: $e');
      return false;
    }
  }

  String _generateContentId() {
    return 'content_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generatePathId() {
    return 'path_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Topic analysis result
class TopicAnalysis {
  final String originalTopic;
  final String category;
  final String intent;
  final String difficulty;
  final List<String> keywords;
  final List<String> clarificationQuestions;

  const TopicAnalysis({
    required this.originalTopic,
    required this.category,
    required this.intent,
    required this.difficulty,
    required this.keywords,
    required this.clarificationQuestions,
  });
}

/// Content block for generated content
class ContentBlock {
  final String id;
  final String topic;
  final String category;
  final String level;
  final String title;
  final String script;
  final String summary;
  final List<String> keyPoints;
  final Duration estimatedDuration;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const ContentBlock({
    required this.id,
    required this.topic,
    required this.category,
    required this.level,
    required this.title,
    required this.script,
    required this.summary,
    required this.keyPoints,
    required this.estimatedDuration,
    required this.createdAt,
    required this.metadata,
  });
}

/// Learning path structure
class LearningPath {
  final String id;
  final String title;
  final String description;
  final String estimatedDuration;
  final List<LearningMilestone> milestones;
  final DateTime createdAt;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedDuration,
    required this.milestones,
    required this.createdAt,
  });
}

/// Learning milestone within a path
class LearningMilestone {
  final String title;
  final String description;
  final List<String> topics;
  final int durationDays;

  const LearningMilestone({
    required this.title,
    required this.description,
    required this.topics,
    required this.durationDays,
  });
}
