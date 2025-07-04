import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_keys.dart';

class GPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-4';

  /// Classify user input and detect subtopic
  Future<TopicClassification> classifyAndDetectSubtopic(String userInput) async {
    try {
      final prompt = '''
Analyze this user learning request and extract:
1. Main topic category
2. Specific subtopic
3. Suggested lesson title
4. Relevant tags

User Input: "$userInput"

Respond in JSON format:
{
  "topic": "Main category (e.g., AI in Healthcare, Startup Funding)",
  "subtopic": "Specific aspect (e.g., diagnosis_automation, chatbots_in_therapy)",
  "title": "Engaging lesson title",
  "tags": ["tag1", "tag2", "tag3"],
  "confidence": 0.95
}

Guidelines:
- Topics should be broad categories that can have multiple lessons
- Subtopics should be specific, learnable concepts
- Use underscores in subtopic names for consistency
- Include 3-5 relevant tags
- Confidence should be 0-1 based on clarity of intent
''';

      final response = await _makeGPTRequest(prompt);
      final classification = TopicClassification.fromJson(jsonDecode(response));
      
      return classification;
    } catch (e) {
      throw Exception('Failed to classify topic: $e');
    }
  }

  /// Generate lesson content for a specific subtopic
  Future<String> generateLessonContent({
    required String topic,
    required String subtopic,
    required String title,
    String coachPersonality = 'encouraging mentor',
    int targetWordCount = 1200,
  }) async {
    try {
      final prompt = '''
Create a $targetWordCount-word audio lesson about "$title" in the "$topic" category.

Topic: $topic
Subtopic: $subtopic
Title: $title
Coach Style: $coachPersonality
Target: ~$targetWordCount words (8-10 minutes when spoken)

Requirements:
- Write in a conversational, podcast-style tone
- Structure: Hook → Key concepts → Examples → Actionable insights → Recap
- Use "you" to directly address the listener
- Include real-world examples and case studies
- End with 2-3 practical takeaways
- Sound like a knowledgeable friend, not a textbook
- Be engaging and inspiring while staying educational

Write the complete lesson script ready for text-to-speech conversion:
''';

      final lessonContent = await _makeGPTRequest(prompt);
      return lessonContent.trim();
    } catch (e) {
      throw Exception('Failed to generate lesson content: $e');
    }
  }

  /// Suggest related topics based on user's learning history
  Future<List<String>> suggestRelatedTopics({
    required List<String> completedTopics,
    required List<String> userInterests,
    int maxSuggestions = 5,
  }) async {
    try {
      final prompt = '''
Based on a user's learning history and interests, suggest $maxSuggestions related topics they should explore next.

Completed Topics: ${completedTopics.join(', ')}
User Interests: ${userInterests.join(', ')}

Suggest topics that:
1. Build on their existing knowledge
2. Align with their interests
3. Provide natural progression
4. Are practical and applicable

Return as JSON array of topic names:
["Topic 1", "Topic 2", "Topic 3"]
''';

      final response = await _makeGPTRequest(prompt);
      final suggestions = List<String>.from(jsonDecode(response));
      
      return suggestions;
    } catch (e) {
      throw Exception('Failed to suggest topics: $e');
    }
  }

  /// Generate a multi-day learning path for a topic
  Future<LearningPath> generateLearningPath(String mainTopic) async {
    try {
      final prompt = '''
Create a 7-day learning path for "$mainTopic". Break it down into daily subtopics that build progressively.

Respond in JSON format:
{
  "topic": "$mainTopic",
  "description": "Brief overview of what they'll learn",
  "duration_days": 7,
  "daily_lessons": [
    {
      "day": 1,
      "subtopic": "foundation_concepts",
      "title": "Understanding the Basics",
      "description": "What they'll learn this day"
    }
  ]
}

Guidelines:
- Start with fundamentals, progress to advanced concepts
- Each lesson should be 8-10 minutes (learnable in one session)
- Use underscores in subtopic names
- Make titles engaging and specific
- Ensure logical progression
''';

      final response = await _makeGPTRequest(prompt);
      final learningPath = LearningPath.fromJson(jsonDecode(response));
      
      return learningPath;
    } catch (e) {
      throw Exception('Failed to generate learning path: $e');
    }
  }

  /// Make GPT API request
  Future<String> _makeGPTRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openaiApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an expert educational content creator specializing in creating engaging, practical learning experiences. Always respond in the exact format requested.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('GPT API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to make GPT request: $e');
    }
  }
}

/// Topic classification result
class TopicClassification {
  final String topic;
  final String subtopic;
  final String title;
  final List<String> tags;
  final double confidence;

  const TopicClassification({
    required this.topic,
    required this.subtopic,
    required this.title,
    required this.tags,
    required this.confidence,
  });

  factory TopicClassification.fromJson(Map<String, dynamic> json) {
    return TopicClassification(
      topic: json['topic'] as String,
      subtopic: json['subtopic'] as String,
      title: json['title'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'subtopic': subtopic,
      'title': title,
      'tags': tags,
      'confidence': confidence,
    };
  }

  @override
  String toString() {
    return 'TopicClassification(topic: $topic, subtopic: $subtopic, confidence: $confidence)';
  }
}

/// Learning path structure
class LearningPath {
  final String topic;
  final String description;
  final int durationDays;
  final List<DailyLesson> dailyLessons;

  const LearningPath({
    required this.topic,
    required this.description,
    required this.durationDays,
    required this.dailyLessons,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      topic: json['topic'] as String,
      description: json['description'] as String,
      durationDays: json['duration_days'] as int,
      dailyLessons: (json['daily_lessons'] as List)
          .map((lesson) => DailyLesson.fromJson(lesson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'description': description,
      'duration_days': durationDays,
      'daily_lessons': dailyLessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

/// Daily lesson in a learning path
class DailyLesson {
  final int day;
  final String subtopic;
  final String title;
  final String description;

  const DailyLesson({
    required this.day,
    required this.subtopic,
    required this.title,
    required this.description,
  });

  factory DailyLesson.fromJson(Map<String, dynamic> json) {
    return DailyLesson(
      day: json['day'] as int,
      subtopic: json['subtopic'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'subtopic': subtopic,
      'title': title,
      'description': description,
    };
  }
}