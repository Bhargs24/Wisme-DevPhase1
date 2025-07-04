class TopicAnalysis {
  final String originalTopic;
  final String category;
  final String intent;
  final String difficulty;
  final List<String> keywords;
  final List<String> clarificationQuestions;
  final Map<String, dynamic> metadata;

  TopicAnalysis({
    required this.originalTopic,
    required this.category,
    required this.intent,
    required this.difficulty,
    required this.keywords,
    this.clarificationQuestions = const [],
    this.metadata = const {},
  });

  factory TopicAnalysis.fromGPTResponse(Map<String, dynamic> response) {
    return TopicAnalysis(
      originalTopic: response['original_topic'] ?? '',
      category: response['category'] ?? '',
      intent: response['intent'] ?? '',
      difficulty: response['difficulty'] ?? 'beginner',
      keywords: List<String>.from(response['keywords'] ?? []),
      clarificationQuestions: List<String>.from(response['clarification'] ?? []),
      metadata: Map<String, dynamic>.from(response['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'original_topic': originalTopic,
      'category': category,
      'intent': intent,
      'difficulty': difficulty,
      'keywords': keywords,
      'clarification': clarificationQuestions,
      'metadata': metadata,
    };
  }

  bool get needsClarification => clarificationQuestions.isNotEmpty;

  @override
  String toString() {
    return 'TopicAnalysis(topic: $originalTopic, category: $category, intent: $intent)';
  }
}

class LearningCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> levels;
  final Map<String, String> levelDescriptions;
  final List<String> examples;

  LearningCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.levels,
    required this.levelDescriptions,
    required this.examples,
  });

  static final List<LearningCategory> categories = [
    LearningCategory(
      id: 'technology',
      name: 'Technology',
      description: 'Programming, AI, gadgets, and digital trends',
      icon: '💻',
      levels: ['Core Concepts', 'Case Studies', 'Tools & Trends', 'Bit of Everything'],
      levelDescriptions: {
        'Core Concepts': 'Fundamental principles and how things work',
        'Case Studies': 'Real-world implementations and success stories',
        'Tools & Trends': 'Latest tools, frameworks, and emerging trends',
        'Bit of Everything': 'Mixed approach with concepts, stories, and tools',
      },
      examples: ['Programming', 'Artificial Intelligence', 'Blockchain', 'Cybersecurity'],
    ),
    LearningCategory(
      id: 'business',
      name: 'Business & Finance',
      description: 'Entrepreneurship, finance, and business strategy',
      icon: '📊',
      levels: ['Fundamentals', 'Case Studies', 'Growth Strategy', 'Balanced Mix'],
      levelDescriptions: {
        'Fundamentals': 'Basic business concepts and principles',
        'Case Studies': 'Real company stories and business decisions',
        'Growth Strategy': 'Advanced tactics for scaling and growth',
        'Balanced Mix': 'Combination of theory, cases, and strategies',
      },
      examples: ['Startup Funding', 'Marketing', 'Leadership', 'Investing'],
    ),
    LearningCategory(
      id: 'psychology',
      name: 'Psychology & Mind',
      description: 'Human behavior, mental models, and cognitive science',
      icon: '🧠',
      levels: ['Theories & Experiments', 'Real-Life Application', 'Mindfulness & Behavior', 'Mixed Approach'],
      levelDescriptions: {
        'Theories & Experiments': 'Scientific studies and psychological theories',
        'Real-Life Application': 'Practical psychology for everyday life',
        'Mindfulness & Behavior': 'Mental health, habits, and personal development',
        'Mixed Approach': 'Blend of theory, application, and mindfulness',
      },
      examples: ['Cognitive Biases', 'Habit Formation', 'Emotional Intelligence', 'Memory'],
    ),
    LearningCategory(
      id: 'science',
      name: 'Science & Nature',
      description: 'Physics, biology, chemistry, and natural phenomena',
      icon: '🔬',
      levels: ['Scientific Concepts', 'Discoveries', 'Ethics & Controversies', 'Narrative Mix'],
      levelDescriptions: {
        'Scientific Concepts': 'Core scientific principles and theories',
        'Discoveries': 'Breakthrough discoveries and their impact',
        'Ethics & Controversies': 'Ethical implications and scientific debates',
        'Narrative Mix': 'Story-driven approach to scientific learning',
      },
      examples: ['Quantum Physics', 'Evolution', 'Climate Change', 'Space Exploration'],
    ),
    LearningCategory(
      id: 'creativity',
      name: 'Creativity & Design',
      description: 'Art, design, innovation, and creative thinking',
      icon: '🎨',
      levels: ['Design Fundamentals', 'Iconic Examples', 'Frameworks & Tools', 'Creative Blend'],
      levelDescriptions: {
        'Design Fundamentals': 'Basic principles of design and creativity',
        'Iconic Examples': 'Masterpieces and creative breakthroughs',
        'Frameworks & Tools': 'Methods and tools for creative work',
        'Creative Blend': 'Mixed approach to creative learning',
      },
      examples: ['Design Thinking', 'Photography', 'Writing', 'Innovation'],
    ),
    LearningCategory(
      id: 'self-growth',
      name: 'Self-Growth',
      description: 'Personal development, productivity, and life skills',
      icon: '🌱',
      levels: ['Philosophy & Mental Models', 'Self-Development', 'Habits & Mindset', 'Reflective Mix'],
      levelDescriptions: {
        'Philosophy & Mental Models': 'Deep thinking frameworks and philosophies',
        'Self-Development': 'Practical personal improvement strategies',
        'Habits & Mindset': 'Building better habits and mindset shifts',
        'Reflective Mix': 'Thoughtful approach to personal growth',
      },
      examples: ['Productivity', 'Meditation', 'Goal Setting', 'Time Management'],
    ),
    LearningCategory(
      id: 'history',
      name: 'History & Culture',
      description: 'Historical events, cultures, and human stories',
      icon: '📚',
      levels: ['Timelines', 'Cultural Impact', 'Media & Storytelling', 'Blended Approach'],
      levelDescriptions: {
        'Timelines': 'Chronological events and historical progression',
        'Cultural Impact': 'How events shaped culture and society',
        'Media & Storytelling': 'Stories, documentaries, and narrative history',
        'Blended Approach': 'Mix of facts, culture, and storytelling',
      },
      examples: ['World Wars', 'Ancient Civilizations', 'Cultural Movements', 'Biographies'],
    ),
    LearningCategory(
      id: 'skills',
      name: 'Skills & Tools',
      description: 'Practical skills, tools, and how-to knowledge',
      icon: '🛠️',
      levels: ['Getting Started', 'Pro Tools & Hacks', 'Workflows & Systems', 'Practical Guide'],
      levelDescriptions: {
        'Getting Started': 'Beginner-friendly introductions and basics',
        'Pro Tools & Hacks': 'Advanced tools and professional techniques',
        'Workflows & Systems': 'Efficient processes and systematic approaches',
        'Practical Guide': 'Hands-on, actionable learning',
      },
      examples: ['Excel', 'Public Speaking', 'Negotiation', 'Cooking'],
    ),
    LearningCategory(
      id: 'career',
      name: 'Career & Strategy',
      description: 'Professional development and career advancement',
      icon: '🎯',
      levels: ['Identity & Purpose', 'Career Assets', 'Strategic Moves', 'Holistic Journey'],
      levelDescriptions: {
        'Identity & Purpose': 'Finding your career direction and purpose',
        'Career Assets': 'Building skills, network, and reputation',
        'Strategic Moves': 'Advanced career strategies and transitions',
        'Holistic Journey': 'Complete career development approach',
      },
      examples: ['Job Interviews', 'Networking', 'Career Change', 'Professional Branding'],
    ),
  ];

  static LearningCategory? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static LearningCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'LearningCategory(id: $id, name: $name)';
  }
}
