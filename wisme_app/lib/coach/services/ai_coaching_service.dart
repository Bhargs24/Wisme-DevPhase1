import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coaching_session.dart';
import '../models/ai_coach.dart';
import '../../core/utils/logger.dart';
import '../../core/exceptions/app_exceptions.dart';

/// Service for AI-powered coaching interactions using GPT
class AICoachingService {
  final String _apiKey;
  final String _baseUrl;
  final AppLogger _logger;
  
  // Session state
  final Map<String, List<CoachMessage>> _sessionHistory = {};
  final Map<String, Map<String, dynamic>> _sessionContext = {};

  AICoachingService({
    required String apiKey,
    String baseUrl = 'https://api.openai.com/v1',
    AppLogger? logger,
  }) : _apiKey = apiKey,
       _baseUrl = baseUrl,
       _logger = logger ?? AppLogger();

  /// Generate AI coach response based on user message and context
  Future<CoachMessage> generateResponse({
    required String sessionId,
    required String userMessage,
    required AICoach coach,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Get session history
      final history = _sessionHistory[sessionId] ?? [];
      
      // Update context
      if (context != null) {
        _sessionContext[sessionId] = {
          ..._sessionContext[sessionId] ?? {},
          ...context,
        };
      }

      // Build conversation context
      final conversationContext = _buildConversationContext(
        coach: coach,
        history: history,
        sessionContext: _sessionContext[sessionId] ?? {},
      );

      // Create messages for API
      final messages = [
        {
          'role': 'system',
          'content': conversationContext,
        },
        ...history.map((msg) => {
          'role': msg.sender == MessageSender.user ? 'user' : 'assistant',
          'content': msg.content,
        }),
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': messages,
          'max_tokens': 500,
          'temperature': coach.personality.formality < 0.5 ? 0.8 : 0.6,
          'presence_penalty': 0.2,
          'frequency_penalty': 0.1,
        }),
      );

      if (response.statusCode != 200) {
        throw ServiceException('AI API request failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      final confidence = _calculateConfidence(data);

      // Analyze message intent
      final intent = _analyzeMessageIntent(content, coach.type);

      // Create coach message
      final coachMessage = CoachMessage(
        id: _generateMessageId(),
        sender: MessageSender.coach,
        content: content,
        type: MessageType.text,
        timestamp: DateTime.now(),
        attachments: {},
        intent: intent,
        confidence: confidence,
        metadata: {
          'coachId': coach.id,
          'model': 'gpt-4-turbo-preview',
          'processingTime': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Add to session history
      _sessionHistory[sessionId] = [
        ...history,
        CoachMessage(
          id: _generateMessageId(),
          sender: MessageSender.user,
          content: userMessage,
          type: MessageType.text,
          timestamp: DateTime.now(),
          attachments: {},
          intent: MessageIntent.question,
          metadata: {},
        ),
        coachMessage,
      ];

      _logger.info('Generated AI response for session: $sessionId');
      return coachMessage;
    } catch (e, stack) {
      _logger.error('Failed to generate AI response', error: e, stackTrace: stack);
      throw ServiceException('Failed to generate AI response: $e');
    }
  }

  /// Generate personalized coaching suggestions
  Future<List<String>> generateSuggestions({
    required AICoach coach,
    required Map<String, dynamic> userContext,
    int maxSuggestions = 3,
  }) async {
    try {
      final systemPrompt = _buildSuggestionPrompt(coach, userContext);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt,
            },
            {
              'role': 'user',
              'content': 'Generate $maxSuggestions personalized coaching suggestions.',
            },
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        throw ServiceException('Suggestions API request failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;

      // Parse suggestions (assuming they're formatted as numbered list)
      final suggestions = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
          .where((suggestion) => suggestion.isNotEmpty)
          .take(maxSuggestions)
          .toList();

      _logger.info('Generated ${suggestions.length} coaching suggestions');
      return suggestions;
    } catch (e, stack) {
      _logger.error('Failed to generate suggestions', error: e, stackTrace: stack);
      throw ServiceException('Failed to generate suggestions: $e');
    }
  }

  /// Analyze user message sentiment and intent
  Future<MessageAnalysis> analyzeMessage(String message) async {
    try {
      final systemPrompt = '''
You are an expert at analyzing learning-related messages. Analyze the following message and return a JSON response with:
1. sentiment: "positive", "neutral", or "negative"
2. intent: "question", "complaint", "celebration", "confusion", "motivation_needed", "clarification"
3. urgency: number from 0.0 to 1.0
4. topics: array of relevant topics mentioned
5. emotions: array of detected emotions

Be concise and accurate.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 200,
          'temperature': 0.3,
        }),
      );

      if (response.statusCode != 200) {
        throw ServiceException('Analysis API request failed: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;

      // Parse JSON response
      final analysisData = jsonDecode(content) as Map<String, dynamic>;

      return MessageAnalysis(
        sentiment: analysisData['sentiment'] as String,
        intent: analysisData['intent'] as String,
        urgency: (analysisData['urgency'] as num).toDouble(),
        topics: List<String>.from(analysisData['topics'] as List),
        emotions: List<String>.from(analysisData['emotions'] as List),
      );
    } catch (e, stack) {
      _logger.error('Failed to analyze message', error: e, stackTrace: stack);
      // Return default analysis on error
      return MessageAnalysis(
        sentiment: 'neutral',
        intent: 'question',
        urgency: 0.5,
        topics: [],
        emotions: [],
      );
    }
  }

  /// Clear session history
  void clearSessionHistory(String sessionId) {
    _sessionHistory.remove(sessionId);
    _sessionContext.remove(sessionId);
  }

  /// Get session message count
  int getSessionMessageCount(String sessionId) {
    return _sessionHistory[sessionId]?.length ?? 0;
  }

  /// Build conversation context for AI
  String _buildConversationContext({
    required AICoach coach,
    required List<CoachMessage> history,
    required Map<String, dynamic> sessionContext,
  }) {
    final contextParts = [
      'You are ${coach.name}, an AI ${coach.type.name} with the following characteristics:',
      '- Personality: ${coach.personality.tone} tone, ${coach.personality.style} style',
      '- Formality level: ${(coach.personality.formality * 100).round()}%',
      '- Encouragement level: ${(coach.personality.encouragement * 100).round()}%',
      '- Directness level: ${(coach.personality.directness * 100).round()}%',
      '- Patience level: ${(coach.personality.patience * 100).round()}%',
      '- Key traits: ${coach.personality.characteristics.join(', ')}',
      '',
      'Your specializations: ${coach.specializations.join(', ')}',
      '',
      'Current session context:',
    ];

    // Add session-specific context
    sessionContext.forEach((key, value) {
      contextParts.add('- $key: $value');
    });

    contextParts.addAll([
      '',
      'Instructions:',
      '1. Stay in character based on your personality traits',
      '2. Provide helpful, personalized coaching responses',
      '3. Be encouraging but honest about challenges',
      '4. Ask follow-up questions when appropriate',
      '5. Keep responses concise but comprehensive',
      '6. Adapt your communication style to the user\'s needs',
    ]);

    return contextParts.join('\n');
  }

  /// Build suggestion generation prompt
  String _buildSuggestionPrompt(AICoach coach, Map<String, dynamic> userContext) {
    return '''
You are ${coach.name}, an AI ${coach.type.name}. Generate personalized coaching suggestions based on:

User Context:
${userContext.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Your personality:
- Tone: ${coach.personality.tone}
- Style: ${coach.personality.style}
- Encouragement: ${(coach.personality.encouragement * 100).round()}%
- Directness: ${(coach.personality.directness * 100).round()}%

Create actionable, motivating suggestions that match your personality and the user's current situation.
Format as a numbered list.
''';
  }

  /// Calculate response confidence based on API response
  double _calculateConfidence(Map<String, dynamic> apiResponse) {
    // This is a simplified confidence calculation
    // In a real implementation, you might use token probabilities or other metrics
    try {
      final usage = apiResponse['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        final completionTokens = usage['completion_tokens'] as int?;
        if (completionTokens != null && completionTokens > 10) {
          return 0.85; // High confidence for substantial responses
        }
      }
      return 0.7; // Default confidence
    } catch (e) {
      return 0.5; // Low confidence on error
    }
  }

  /// Analyze message intent based on content and coach type
  MessageIntent _analyzeMessageIntent(String content, CoachType coachType) {
    final contentLower = content.toLowerCase();

    if (contentLower.contains('congratulations') || 
        contentLower.contains('great job') ||
        contentLower.contains('excellent')) {
      return MessageIntent.celebration;
    }

    if (contentLower.contains('try') || 
        contentLower.contains('suggest') ||
        contentLower.contains('recommend')) {
      return MessageIntent.guidance;
    }

    if (contentLower.contains('keep going') || 
        contentLower.contains('you can do') ||
        contentLower.contains('motivation')) {
      return MessageIntent.motivation;
    }

    if (contentLower.contains('?')) {
      return MessageIntent.clarification;
    }

    // Default based on coach type
    switch (coachType) {
      case CoachType.motivator:
        return MessageIntent.encouragement;
      case CoachType.assessor:
        return MessageIntent.feedback;
      case CoachType.mentor:
        return MessageIntent.guidance;
      default:
        return MessageIntent.information;
    }
  }

  /// Generate unique message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(6)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt((chars.length * 0.5).round())));
  }
}

/// Message analysis result
class MessageAnalysis {
  final String sentiment;
  final String intent;
  final double urgency;
  final List<String> topics;
  final List<String> emotions;

  const MessageAnalysis({
    required this.sentiment,
    required this.intent,
    required this.urgency,
    required this.topics,
    required this.emotions,
  });

  Map<String, dynamic> toJson() => {
    'sentiment': sentiment,
    'intent': intent,
    'urgency': urgency,
    'topics': topics,
    'emotions': emotions,
  };
}
