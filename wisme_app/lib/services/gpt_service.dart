import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_keys.dart';
import '../models/topic_model.dart';

class GPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
    'Content-Type': 'application/json',
  };

  /// Analyze user topic input and categorize it
  Future<TopicAnalysis> analyzeUserTopic(String userInput) async {
    try {
      final systemPrompt = '''You are an educational content analyzer. Given a user topic, analyze it and return a JSON response with:
- category: one of [Technology, Business, Psychology, Science, Creativity, Self-Growth, History, Skills, Career]
- intent: what the user wants to learn (concepts, stories, tools, mixed)
- difficulty: suggested level (beginner, intermediate, advanced)
- keywords: relevant tags for content matching
- clarification: questions to ask if topic is vague

Be specific and helpful. If the topic is unclear, provide clarification questions.''';

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
          'model': 'gpt-4',
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
        
        return TopicAnalysis(
          originalTopic: userInput,
          category: analysisData['category'] ?? 'Technology',
          intent: analysisData['intent'] ?? 'concepts',
          difficulty: analysisData['difficulty'] ?? 'beginner',
          keywords: List<String>.from(analysisData['keywords'] ?? []),
          clarificationQuestions: List<String>.from(analysisData['clarification'] ?? []),
        );
      } else {
        throw Exception('Failed to analyze topic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing topic: $e');
    }
  }

  /// Generate a content block for a specific topic
  Future<Map<String, dynamic>> generateContentBlock({
    required String topic,
    required String category,
    required String level,
    required String contentType, // story, concept, tool, example
    String? userContext,
    String? coachPersonality,
  }) async {
    try {
      final systemPrompt = '''You are an expert educational content creator. Generate engaging, podcast-style content that feels like a conversation with a knowledgeable friend.

Content Guidelines:
- Write in a conversational, podcast-style format
- Include specific examples and real-world applications
- Make complex topics accessible and engaging
- Use storytelling when appropriate
- Keep the tone ${coachPersonality ?? 'professional but friendly'}
- Target duration: 8-12 minutes of spoken content

Format the response as JSON:
{
  "title": "Engaging episode title",
  "script": "Full podcast script with natural speech patterns",
  "summary": "2-3 sentence summary",
  "tags": ["relevant", "tags"],
  "estimated_duration": 600,
  "difficulty": "beginner|intermediate|advanced"
}''';

      final userPrompt = '''Create $contentType content about "$topic" in the $category category at $level level.
${userContext != null ? 'User context: $userContext' : ''}

Focus on making this educational and engaging for audio consumption.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating content: $e');
    }
  }

  /// Create a complete learning journey structure
  Future<Map<String, dynamic>> createLearningJourney({
    required String topic,
    required String category,
    required String level,
    required int durationDays,
    List<String>? existingKnowledge,
  }) async {
    try {
      final systemPrompt = '''You are an expert curriculum designer. Create a structured learning journey that progressively builds knowledge.

Design principles:
- Each day should build on previous knowledge
- Mix different content types (stories, concepts, tools, examples)
- Include practical applications
- Ensure logical progression
- Make each episode standalone but connected

Return JSON format:
{
  "title": "Journey title",
  "description": "Journey description",
  "total_days": $durationDays,
  "estimated_duration": "X hours total",
  "daily_structure": [
    {
      "day": 1,
      "title": "Day 1 title",
      "objective": "What learner will achieve",
      "content_blocks": [
        {
          "type": "story|concept|tool|example",
          "title": "Block title",
          "description": "What this block covers",
          "estimated_minutes": 10
        }
      ]
    }
  ]
}''';

      final userPrompt = '''Create a $durationDays-day learning journey for "$topic" in $category category at $level level.
${existingKnowledge != null ? 'Learner already knows: ${existingKnowledge.join(", ")}' : ''}

Focus on practical, engaging content that builds progressively.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 3000,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to create journey: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating journey: $e');
    }
  }

  /// Generate personalized recommendations
  Future<List<String>> generateRecommendations({
    required List<String> userInterests,
    required List<String> completedContent,
    String? learningVelocity,
    List<String>? preferredContentTypes,
    List<String>? optimalLearningTimes,
  }) async {
    try {
      final systemPrompt = '''You are a personalized learning recommendation engine. Based on user data, suggest relevant topics that would interest them and help them grow.

Guidelines:
- Consider their interests and learning history
- Suggest complementary topics that build on what they know
- Include a mix of familiar and stretch topics
- Focus on practical, applicable knowledge

Return JSON array of topic suggestions:
["Topic 1", "Topic 2", "Topic 3", "Topic 4", "Topic 5"]''';

      final userPrompt = '''User Profile:
Interests: ${userInterests.join(", ")}
Completed: ${completedContent.join(", ")}
Learning Pace: ${learningVelocity ?? "moderate"}
Preferred Types: ${preferredContentTypes?.join(", ") ?? "mixed"}

Suggest 5 relevant learning topics.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 300,
          'temperature': 0.6,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final recommendations = jsonDecode(content);
        return List<String>.from(recommendations);
      } else {
        throw Exception('Failed to generate recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating recommendations: $e');
    }
  }

  /// Enhance content script for better TTS
  Future<String> enhanceScriptForTTS(String script, String coachPersonality) async {
    try {
      final systemPrompt = '''You are an expert at optimizing text for text-to-speech conversion. Your goal is to make the script sound natural and engaging when spoken.

Optimization guidelines:
- Add natural pauses with commas and periods
- Use conversational contractions (don't, won't, it's)
- Break up long sentences
- Add emphasis markers for important points
- Include natural speech patterns and transitions
- Match the personality: $coachPersonality

Return the optimized script as plain text.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4',
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
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to enhance script: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error enhancing script: $e');
    }
  }

  /// Check if API key is valid
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
          'max_tokens': 5,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available models
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openai.com/v1/models'),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['data'] as List;
        return models
            .where((model) => model['id'].contains('gpt'))
            .map<String>((model) => model['id'])
            .toList();
      } else {
        return ['gpt-3.5-turbo', 'gpt-4'];
      }
    } catch (e) {
      return ['gpt-3.5-turbo', 'gpt-4'];
    }
  }
}