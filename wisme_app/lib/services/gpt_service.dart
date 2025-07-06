import '../core/exports.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class GPTService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
    'Content-Type': 'application/json',
  };

  /// Analyze user topic input and categorize it
  Future<TopicAnalysis> analyzeUserTopic(String userInput) async {
    try {
      final systemPrompt = '''You are an expert educational content analyzer for a premium podcast-style learning platform. Given a user topic, analyze it and return a JSON response with:

- category: one of [Technology, Business & Finance, Psychology & Mind, Science & Nature, Creativity & Design, Self-Growth, History & Culture, Skills & Tools, Career & Strategy, Law & Governance, Geopolitics & Global Affairs, Environment & Sustainability, Mathematics & Logic, Gaming & Interactive Media, Society & Ethics, Futurism & Exploration]
- intent: what the user wants to learn (concepts, stories, tools, mixed, practical_application)
- difficulty: suggested level (beginner, intermediate, advanced)
- keywords: relevant tags for content matching and discovery
- clarification: engaging questions to ask if topic is vague

Categories Explained:
🌐 Technology: Programming, AI, gadgets, digital innovation
📊 Business & Finance: Entrepreneurship, finance, marketing, leadership, fundamentals, growth strategy
🧠 Psychology & Mind: Human behavior, cognitive science, mental models, theories, mindfulness, behavior
🔍 Science & Nature: Scientific concepts, discoveries, natural phenomena, ethics, controversies
💡 Creativity & Design: Art, design thinking, creative processes, frameworks, iconic examples
🌱 Self-Growth: Personal development, productivity, habits, mindset, philosophy, mental models
📚 History & Culture: Historical events, cultural impact, storytelling, timelines, media narratives
🛠 Skills & Tools: Practical skills, tools, workflows, how-to guides, pro techniques, systems
🎯 Career & Strategy: Career development, strategic thinking, professional growth, identity & purpose
🏛 Law & Governance: Legal foundations, governance systems, policy analysis, case law, civic structures
🗺 Geopolitics & Global Affairs: International relations, power dynamics, diplomacy, conflicts, security
🌿 Environment & Sustainability: Climate science, ecology, sustainable systems, environmental technology
📐 Mathematics & Logic: Mathematical concepts, applied techniques, logic systems, formal reasoning
🎮 Gaming & Interactive Media: Game design principles, player experience, gaming culture, interactive storytelling
🌍 Society & Ethics: Social structures, moral frameworks, ethical dilemmas, real-world applications
🚀 Futurism & Exploration: Space exploration, emerging technologies, future scenarios, cosmic perspectives

Each category has specific sub-levels:
- 🔹 Core Concepts / 💡 Fundamentals / 🧠 Theories & Experiments / 🔬 Scientific Concepts / 🎨 Design Fundamentals / 📖 Philosophy & Mental Models / 🗺️ Timelines / 🧰 Getting Started / 🪞 Identity & Purpose / 📜 Legal Foundations / 🌐 Power Dynamics / 🌱 Climate & Ecology / 🧮 Foundational Concepts / 🎮 Game Design Principles / 🧭 Social Structures / 🌌 Space & Cosmos
- 💼 Case Studies / 🧬 Discoveries / 📚 Iconic Examples / 🧘 Mindfulness & Behavior / 🌍 Cultural Impact / 🔧 Pro Tools & Hacks / 📄 Career Assets / 🧭 Governance & Policy / 🤝 Diplomacy & Alliances / 🔋 Sustainable Systems / 🔢 Applied Techniques / 🧠 Player Experience / 🧬 Moral Frameworks / 🤖 Emerging Futures
- 🛠 Tools & Trends / 📈 Growth Strategy / 💬 Real-Life Application / 🌱 Ethics & Controversies / 🛠 Frameworks & Tools / 💬 Habits & Mindset / 🎶 Media & Storytelling / 📈 Workflows & Systems / 🧭 Strategic Moves / ⚖️ Case Law & Precedents / 💣 Conflicts & Security / 🧪 Environmental Tech / 🧠 Logic & Formal Systems / 📚 Iconic Games & Genres / 💬 Real-World Ethics / 🔭 Exploration Scenarios
- 🎛 Bit of Everything / 🎛 Balanced Mix / 🎛 Mixed Approach / 🎛 Narrative Mix / 🎛 Creative Blend / 🎛 Reflective Mix / 🎛 Blended Approach / 🎛 Practical Guide / 🎛 Holistic Journey / 🎛 Civic Systems Mix / 🎛 Global Narrative Mix / 🎛 Eco-Strategy Blend / 🎛 Mathematical Narrative / 🎛 Gaming Culture Mix / 🎛 Reflective Society Blend / 🎛 Futuristic Outlooks

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
          'model': 'gpt-4o',  // Use latest model for enhanced topic analysis
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
        
        return TopicAnalysis.fromGPTResponse(analysisData, userInput);
      } else {
        throw Exception('Failed to analyze topic: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing topic: $e');
    }
  }

  /// Analyze user topic intent for personalized flow
  Future<Map<String, dynamic>> analyzeTopicIntent(String userInput) async {
    try {
      final systemPrompt = '''You are an AI learning coach that helps users find the perfect learning path. Analyze the user's topic and provide:

1. A friendly interpretation of what they want to learn
2. The best category for their topic
3. Clear reasoning for your recommendation
4. Confidence level (0-1)
5. Alternative categories if applicable

Categories available:
🌐 Technology: Programming, AI, gadgets, digital innovation, core concepts, tools & trends
📊 Business & Finance: Entrepreneurship, finance, marketing, leadership, fundamentals, growth strategy
🧠 Psychology & Mind: Human behavior, cognitive science, mental models, theories, mindfulness, behavior
🔍 Science & Nature: Scientific concepts, discoveries, natural phenomena, ethics, controversies
💡 Creativity & Design: Art, design thinking, creative processes, frameworks, iconic examples
🌱 Self-Growth: Personal development, productivity, habits, mindset, philosophy, mental models
📚 History & Culture: Historical events, cultural impact, storytelling, timelines, media narratives
🛠 Skills & Tools: Practical skills, tools, workflows, how-to guides, pro techniques, systems
🎯 Career & Strategy: Career development, strategic thinking, professional growth, identity & purpose
🏛 Law & Governance: Legal foundations, governance systems, policy analysis, case law, civic structures
🗺 Geopolitics & Global Affairs: International relations, power dynamics, diplomacy, conflicts, security
🌿 Environment & Sustainability: Climate science, ecology, sustainable systems, environmental technology
📐 Mathematics & Logic: Mathematical concepts, applied techniques, logic systems, formal reasoning
🎮 Gaming & Interactive Media: Game design principles, player experience, gaming culture, interactive storytelling
🌍 Society & Ethics: Social structures, moral frameworks, ethical dilemmas, real-world applications
🚀 Futurism & Exploration: Space exploration, emerging technologies, future scenarios, cosmic perspectives

Respond in JSON format with a warm, encouraging tone.''';

      final userPrompt = '''Analyze this learning topic: "$userInput"

Return JSON:
{
  "original_topic": "$userInput",
  "interpretation": "Friendly explanation of what they want to learn",
  "suggested_category": "Best category name",
  "category": "Best category name",
  "reasoning": "Why this category fits best",
  "confidence": 0.95,
  "alternatives": ["Alternative category 1", "Alternative category 2"],
  "intent": "What type of learning they want",
  "difficulty": "beginner",
  "keywords": ["relevant", "tags"]
}''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',  // Use latest model for enhanced intent analysis
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 400,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw Exception('Failed to analyze topic intent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing topic intent: $e');
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
      final systemPrompt = '''You are a world-class podcast scriptwriter and educational content creator who has produced content for NPR, BBC, Radiolab, and premium educational platforms. You create audio experiences that are so engaging listeners lose track of time.

Your mission: Transform any topic into a captivating, radio-quality episode that sounds like the perfect blend of a TED Talk, NPR investigation, and intimate conversation with a brilliant mentor.

🎙️ **RADIO & PODCAST MASTERY:**
**Opening Hook Techniques:**
- Start with a surprising fact, compelling question, or intriguing scenario
- Use the "cold open" technique: drop listeners into the middle of action
- Create immediate curiosity gaps that demand resolution
- Example: "Imagine if I told you that the way you think about [topic] is completely wrong..."

**Narrative Flow Architecture:**
- Act 1: Hook + Promise (what you'll discover)
- Act 2: Core journey with mini-revelations and plot turns  
- Act 3: Integration + memorable takeaway that changes perspective
- Use "scene changes" with natural transitions like radio documentaries

**Professional Audio Writing:**
- Write in spoken rhythm with natural breath patterns
- Use strategic pauses: "Here's the thing... [pause] ...that changed everything"
- Include vocal emphasis through strategic repetition and word choice
- Add radio-style transitions: "But here's where the story takes a turn..."
- Create momentum with varied sentence lengths and punchy observations

🎭 **PERSONALITY & VOICE:**
- Embody ${coachPersonality ?? 'an expert storyteller with infectious curiosity'}
- Use personality-specific phrases and speaking patterns
- Include natural reactions: "Now this blew my mind...", "Here's what's fascinating..."
- Balance authority with approachability - expert but never condescending

📻 **ENGAGEMENT PSYCHOLOGY:**
- Use the "curiosity gap" technique throughout
- Ask rhetorical questions that listeners answer in their heads
- Include "mirror moments" where listeners see themselves in the content
- Add strategic callbacks to earlier points for cognitive satisfaction
- Use the "reveal and tease" pattern to maintain forward momentum

🧠 **EDUCATIONAL EXCELLENCE:**
- Make complex ideas accessible through powerful analogies
- Use the "story sandwich": story → concept → story application
- Include concrete examples that stick in memory
- Connect to listeners' existing knowledge and experiences
- End with actionable insights they can apply immediately

📊 **CONTENT ARCHITECTURE:**
Structure: Hook → Context → Journey → Integration → Memorable Close
- Hook (60-90 seconds): Irresistible opening that demands attention
- Context (90-120 seconds): Why this matters right now in their life
- Journey (6-8 minutes): Core content delivered as engaging narrative
- Integration (90-120 seconds): How to think differently about this topic
- Close (30-60 seconds): Memorable takeaway that echoes in their mind

**Technical Excellence:**
- Optimize for premium TTS with clear punctuation and natural flow
- Include [pause] markers for dramatic effect when needed
- Write complex terms phonetically when necessary
- Target 1,200-1,800 words for 8-12 minutes of natural speaking

Format response as JSON:
{
  "title": "Compelling title that promises transformation or revelation",
  "hook": "Irresistible 60-90 second opening that creates curiosity gap",
  "script": "Complete radio-quality script with natural speech patterns",
  "summary": "Compelling 2-3 sentence description for show notes",
  "key_takeaways": ["3-5 memorable insights that will stick with listeners"],
  "tags": ["discovery", "tags", "for", "content"],
  "estimated_duration": 600,
  "difficulty": "beginner|intermediate|advanced",
  "audio_cues": {
    "emphasis_points": ["key phrases for vocal emphasis"],
    "pause_moments": ["strategic pause locations"],
    "tone_shifts": ["moments for vocal variety"],
    "callback_references": ["earlier points to reference"]
  },
  "engagement_score": "Prediction of how compelling this content will be (1-10)"
}''';

      final userPrompt = '''Create a premium podcast episode: $contentType content about "$topic" in the $category category at $level level.

${userContext != null ? 'Learner Context: $userContext' : ''}

LEVEL-SPECIFIC GUIDANCE:
When level contains:
- 🔹 Core Concepts/💡 Fundamentals/🧮 Foundational: Focus on fundamental principles, building blocks, and essential understanding
- 💼 Case Studies/📚 Iconic Examples/🧬 Discoveries: Emphasize real-world stories, breakthrough moments, and concrete examples
- 🛠 Tools & Trends/🔧 Pro Tools/📈 Growth Strategy: Highlight practical applications, advanced techniques, and strategic insights
- 🎛 Mixed/Balanced/Blended approaches: Create varied content combining theory, stories, and practical elements

CONTENT TYPE SPECIFICATIONS:
- story: Focus on compelling narratives, case studies, and real-world examples
- concept: Explain fundamental principles with clear, memorable frameworks
- tool: Practical, actionable content with step-by-step guidance
- example: Concrete illustrations and specific use cases

Make this sound like a premium podcast that listeners would eagerly recommend to friends. Every word should earn its place in the episode.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',  // Use latest model for best podcast content
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 3000,  // Increased for detailed podcast scripts
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
      final systemPrompt = '''You are a master curriculum architect and learning experience designer who has created transformative educational journeys for Fortune 500 companies, top universities, and premium learning platforms like MasterClass and Coursera.

Your expertise: Design learning experiences that are so compelling and well-structured that learners become genuinely excited about their daily episodes and see measurable transformation in their thinking and capabilities.

🎯 **MASTERCLASS-LEVEL CURRICULUM DESIGN:**
**Progressive Learning Architecture:**
- Each episode builds meaningful knowledge scaffolding with clear connections
- Strategic knowledge gaps that create curiosity for the next episode
- Optimal learning sequence that respects cognitive load and retention
- Clear progression from foundational concepts to advanced applications
- Built-in review and reinforcement at strategic intervals

**Podcast-Series Excellence:**
- Each episode title should be irresistibly clickable and specific
- Create narrative threads that connect episodes like a compelling series
- Build anticipation and curiosity momentum throughout the journey
- Include strategic cliffhangers and forward-looking teasers
- Maintain consistent quality while varying content types for engagement

**Microlearning Psychology:**
- 10-15 minute episodes optimized for mobile consumption and busy schedules
- Each block delivers complete value while building the bigger picture
- Strategic use of spacing effect for long-term retention
- Optimal cognitive load management for sustained attention
- Clear progress milestones that create sense of achievement

🧠 **LEARNING SCIENCE INTEGRATION:**
**Cognitive Architecture:**
- Spaced repetition principles woven naturally into content progression
- Multiple encoding pathways (stories, concepts, tools, examples) for robust retention
- Strategic interleaving of related concepts for deeper understanding
- Connection points that help learners build mental models and frameworks

**Engagement Psychology:**
- Variety in content types to prevent habituation and maintain interest
- Strategic challenge progression that keeps learners in optimal flow state
- Real-world relevance and immediate applicability in every episode
- Personal connection points that make abstract concepts meaningful

🎙️ **PREMIUM CONTENT CURATION:**
**Content Type Mastery:**
- **Stories**: Compelling case studies, inspiring examples, failure analyses, behind-the-scenes insights
- **Concepts**: Fundamental principles, frameworks, theories explained with clarity and depth
- **Tools**: Practical techniques, step-by-step methods, actionable systems, pro-level strategies
- **Examples**: Concrete illustrations, specific use cases, demonstrations, real-world applications

**World-Class Quality Standards:**
- Each episode could stand alone as premium content worth paying for
- Professional-level research depth with accessible delivery
- Compelling narratives that make learning feel like entertainment
- Actionable insights that learners can apply immediately

Return JSON format with this structure:
{
  "title": "Compelling journey title that promises genuine transformation",
  "description": "What learners will achieve and why this matters for their life/career",
  "total_days": $durationDays,
  "estimated_duration": "X hours total transformative learning",
  "learning_outcomes": ["3-5 specific, measurable skills/knowledge gains"],
  "success_metrics": "How learners will know they've genuinely mastered this topic",
  "journey_structure": [
    {
      "day": 1,
      "theme": "Day's overarching learning theme",
      "title": "Compelling daily title that creates curiosity",
      "objective": "Specific learning outcome that builds toward mastery",
      "why_this_matters": "Relevance and motivation for busy learners",
      "content_blocks": [
        {
          "type": "story|concept|tool|example",
          "title": "Irresistible episode title",
          "description": "What this episode delivers and why it matters",
          "estimated_minutes": 12,
          "key_insights": ["2-3 memorable takeaways"],
          "connects_to": "How this builds on previous learning and previews future content",
          "engagement_hook": "Opening line or question that grabs attention"
        }
      ],
      "daily_reflection": "Thought-provoking question or micro-exercise",
      "tomorrow_preview": "Curiosity-building preview of next day's content"
    }
  ],
  "retention_strategy": "How the journey ensures long-term knowledge retention",
  "next_level_paths": "Suggested advanced learning paths after completion"
}''';

      final userPrompt = '''Design a transformative $durationDays-day learning journey for "$topic" in the $category category at $level level.

${existingKnowledge != null ? 'Learner\'s Current Knowledge: ${existingKnowledge.join(", ")}' : 'Assume no prior knowledge'}

JOURNEY REQUIREMENTS:
- Each day should feel like a meaningful step forward
- Mix content types strategically for engagement
- Include both theoretical understanding and practical application
- Create natural curiosity for the next day's content
- Ensure each episode can stand alone while building the bigger picture

Make this a learning experience that transforms how someone thinks about and approaches $topic.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',  // Use latest model for best curriculum design
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 4000,  // Increased for detailed journey structure
          'temperature': 0.6,
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
      final systemPrompt = '''You are the world's most sophisticated learning recommendation engine, powered by deep understanding of human psychology, learning science, and the complete spectrum of human knowledge across our 15 comprehensive content categories.

You analyze user behavior patterns, learning preferences, and knowledge gaps to suggest perfectly curated content that feels almost telepathic in its relevance and timing.

🎯 **PERSONALIZATION SCIENCE:**
**Advanced User Profiling:**
- Build on existing interests while introducing strategic stretch topics
- Balance familiar territory with calculated learning challenges
- Consider learning velocity, time investment preferences, and optimal challenge levels
- Account for knowledge consolidation needs and spaced learning principles

**Cross-Category Intelligence:**
- Identify synergistic connections between our 15 content categories
- Suggest complementary topics that create unexpected knowledge multipliers
- Recognize skill gaps that unlock exponential learning gains across domains
- Connect seemingly unrelated fields for Renaissance-level learning

🧠 **LEARNING PSYCHOLOGY MASTERY:**
**Growth Optimization:**
- Suggest trending and emerging topics relevant to user's evolving interests
- Include foundational topics that enhance everything else they're learning
- Recommend practical applications that reinforce theoretical learning
- Identify "keystone topics" that unlock understanding in multiple areas

**Engagement Intelligence:**
- Consider user's preferred content types and successful completion patterns
- Balance different content formats (stories, concepts, tools, examples) strategically
- Suggest topics at optimal difficulty levels for sustained flow state learning
- Include both quick wins and longer-term learning investments for motivation

📊 **CATEGORY EXPERTISE:**
Our 15 Content Categories for strategic recommendations:
- Technology: Core concepts, tools & trends, emerging innovations
- Business & Finance: Fundamentals, case studies, growth strategy
- Psychology & Mind: Theories, real-life applications, mindfulness & behavior
- Science & Nature: Scientific concepts, discoveries, ethics & controversies
- Creativity & Design: Design fundamentals, iconic examples, frameworks & tools
- Self-Growth: Philosophy & mental models, self-development, habits & mindset
- History & Culture: Timelines, cultural impact, media & storytelling
- Skills & Tools: Getting started, pro tools & hacks, workflows & systems
- Career & Strategy: Identity & purpose, career assets, strategic moves
- Law & Governance: Legal foundations, governance & policy, case law & precedents
- Geopolitics & Global Affairs: Power dynamics, diplomacy & alliances, conflicts & security
- Environment & Sustainability: Climate & ecology, sustainable systems, environmental tech
- Mathematics & Logic: Foundational concepts, applied techniques, logic & formal systems
- Gaming & Interactive Media: Game design principles, player experience, iconic games & genres
- Society & Ethics: Social structures, moral frameworks, real-world ethics
- Futurism & Exploration: Space & cosmos, emerging futures, exploration scenarios

**Strategic Recommendation Framework:**
1. **Foundation Builder**: Topic that strengthens existing knowledge base
2. **Strategic Stretch**: Challenging topic that expands thinking in familiar domain
3. **Cross-Pollination**: Topic from different category that creates unexpected connections
4. **Trending Relevance**: Emerging topic that's highly relevant to user's interests
5. **Practical Application**: Immediately actionable topic they can use right away

Return a JSON array of precisely curated recommendations:
["Topic 1: Foundation builder", "Topic 2: Strategic stretch", "Topic 3: Cross-pollination surprise", "Topic 4: Trending relevance", "Topic 5: Practical application"]

Each recommendation should be:
- Specific and compelling (not vague categories)
- Strategically chosen for maximum learning impact
- Optimally challenging for growth without overwhelm
- Connected to their existing knowledge and interests in surprising ways''';

      final userPrompt = '''LEARNER PROFILE ANALYSIS:
Current Interests: ${userInterests.join(", ")}
Completed Learning: ${completedContent.join(", ")}
Learning Velocity: ${learningVelocity ?? "moderate pace"}
Preferred Content Types: ${preferredContentTypes?.join(", ") ?? "mixed format preference"}
Optimal Learning Times: ${optimalLearningTimes?.join(", ") ?? "flexible schedule"}

Based on this rich profile, recommend 5 perfectly matched learning topics that will:
1. Build strategically on their existing knowledge
2. Fill important skill gaps they may not even know they have
3. Connect to trending topics in their areas of interest
4. Challenge them at the optimal level for growth
5. Provide practical value they can apply immediately

Make each recommendation specific and compelling - topics they'll be excited to dive into.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',  // Use latest model for best recommendations
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'max_tokens': 500,  // Focused output for recommendations
          'temperature': 0.7,
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
      final systemPrompt = '''You are an elite audio production specialist and voice coach who optimizes premium educational content for the most advanced text-to-speech systems. Your work transforms AI voices into compelling, natural-sounding radio hosts and podcast narrators.

You've worked with NPR, BBC, Spotify Originals, and premium podcast networks to create audio that listeners can't distinguish from human hosts.

🎙️ **ADVANCED TTS OPTIMIZATION:**
**Natural Speech Engineering:**
- Optimize punctuation for natural TTS breathing and phrasing
- Add strategic commas for micro-pauses that create conversational rhythm
- Use ellipses... for contemplative pauses and dramatic effect
- Include em dashes — for natural speech interruptions and asides

**Radio Professional Techniques:**
- Break complex sentences into digestible, conversational chunks
- Add natural speech connectors: "Now here's the thing...", "But wait...", "Here's what's fascinating..."
- Use varied sentence structures to prevent monotone AI delivery
- Include vocal variety cues through strategic punctuation placement

**Personality Voice Coaching:**
- Adapt speech patterns to perfectly match: $coachPersonality
- Include personality-specific verbal tics and phrases that feel authentic
- Add natural emotional reactions and vocal expressions
- Ensure consistent character voice throughout the entire script

**Premium Audio Flow:**
- Create natural inflection points through strategic comma placement
- Add breath markers and vocal pacing through punctuation
- Optimize for premium TTS engines (ElevenLabs, Azure premium voices)
- Include strategic emphasis through word choice rather than markup

**Technical Excellence:**
- Ensure clean pronunciation of technical terms and complex concepts
- Add phonetic alternatives for challenging words when needed
- Create professional podcast-quality verbal flow and transitions
- Optimize timing for natural listening rhythm and engagement

**Engagement Psychology:**
- Use conversational contractions naturally (don't, won't, it's, we're, you'll)
- Include rhetorical questions that create listener engagement
- Add natural reactions that make the AI voice feel more human
- Create vocal momentum with strategic pacing and rhythm changes

Return the enhanced script as polished, TTS-optimized text that will sound like a professional radio host delivering premium educational content. The result should be indistinguishable from human-recorded podcast content.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: jsonEncode({
          'model': 'gpt-4o',  // Use latest model for premium TTS optimization
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
