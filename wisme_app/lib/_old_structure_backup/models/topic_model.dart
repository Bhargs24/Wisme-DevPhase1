class TopicAnalysis {
  final String originalTopic;
  final String category;
  final String intent;
  final String difficulty;
  final List<String> keywords;
  final List<String> clarificationQuestions;
  final Map<String, dynamic> metadata;
  
  // Enhanced fields for better analysis
  final String interpretation;
  final String suggestedCategory;
  final String reasoning;
  final double confidence;
  final List<String>? alternativeCategories;

  TopicAnalysis({
    required this.originalTopic,
    required this.category,
    required this.intent,
    required this.difficulty,
    required this.keywords,
    this.clarificationQuestions = const [],
    this.metadata = const {},
    // Enhanced parameters with defaults
    String? interpretation,
    String? suggestedCategory,
    String? reasoning,
    this.confidence = 1.0,
    this.alternativeCategories,
  }) : interpretation = interpretation ?? 'You want to learn about $originalTopic',
       suggestedCategory = suggestedCategory ?? category,
       reasoning = reasoning ?? 'This fits best in the $category category';

  factory TopicAnalysis.fromGPTResponse(Map<String, dynamic> response) {
    return TopicAnalysis(
      originalTopic: response['original_topic'] ?? '',
      category: response['category'] ?? '',
      intent: response['intent'] ?? '',
      difficulty: response['difficulty'] ?? 'beginner',
      keywords: List<String>.from(response['keywords'] ?? []),
      clarificationQuestions: List<String>.from(response['clarification'] ?? []),
      metadata: Map<String, dynamic>.from(response['metadata'] ?? {}),
      interpretation: response['interpretation'] ?? 'You want to learn about ${response['original_topic'] ?? 'this topic'}',
      suggestedCategory: response['suggested_category'] ?? response['category'] ?? '',
      reasoning: response['reasoning'] ?? 'This fits best in the ${response['category'] ?? 'selected'} category',
      confidence: (response['confidence'] ?? 1.0).toDouble(),
      alternativeCategories: response['alternatives'] != null 
          ? List<String>.from(response['alternatives']) 
          : null,
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
      'interpretation': interpretation,
      'suggested_category': suggestedCategory,
      'reasoning': reasoning,
      'confidence': confidence,
      'alternatives': alternativeCategories,
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
      description: 'Programming, AI, gadgets, and digital innovation',
      icon: '🌐',
      levels: ['🔹 Core Concepts', '💼 Case Studies', '🛠 Tools & Trends', '🎛 Bit of Everything'],
      levelDescriptions: {
        '🔹 Core Concepts': 'Fundamental principles and how technology works',
        '💼 Case Studies': 'Real-world implementations and tech success stories',
        '🛠 Tools & Trends': 'Latest tools, frameworks, and emerging innovations',
        '🎛 Bit of Everything': 'Mixed approach with concepts, stories, and tools',
      },
      examples: ['Programming', 'Artificial Intelligence', 'Blockchain', 'Cybersecurity'],
    ),
    LearningCategory(
      id: 'business',
      name: 'Business & Finance',
      description: 'Entrepreneurship, finance, marketing, and business strategy',
      icon: '📊',
      levels: ['💡 Fundamentals', '💼 Case Studies', '📈 Growth Strategy', '🎛 Balanced Mix'],
      levelDescriptions: {
        '💡 Fundamentals': 'Essential business concepts and financial principles',
        '💼 Case Studies': 'Real company stories and business decisions',
        '📈 Growth Strategy': 'Advanced tactics for scaling and strategic growth',
        '🎛 Balanced Mix': 'Combination of theory, cases, and strategies',
      },
      examples: ['Startup Funding', 'Marketing', 'Leadership', 'Investing'],
    ),
    LearningCategory(
      id: 'psychology',
      name: 'Psychology & Mind',
      description: 'Human behavior, mental models, and cognitive science',
      icon: '🧠',
      levels: ['🧠 Theories & Experiments', '💬 Real-Life Application', '🧘 Mindfulness & Behavior', '🎛 Mixed Approach'],
      levelDescriptions: {
        '🧠 Theories & Experiments': 'Scientific studies and psychological theories',
        '💬 Real-Life Application': 'Practical psychology for everyday life',
        '🧘 Mindfulness & Behavior': 'Mental health, habits, and personal development',
        '🎛 Mixed Approach': 'Blend of theory, application, and mindfulness',
      },
      examples: ['Cognitive Biases', 'Habit Formation', 'Emotional Intelligence', 'Memory'],
    ),
    LearningCategory(
      id: 'science',
      name: 'Science & Nature',
      description: 'Physics, biology, chemistry, and natural phenomena',
      icon: '�',
      levels: ['🔬 Scientific Concepts', '🧬 Discoveries', '🌱 Ethics & Controversies', '🎛 Narrative Mix'],
      levelDescriptions: {
        '🔬 Scientific Concepts': 'Core scientific principles and theories',
        '🧬 Discoveries': 'Breakthrough discoveries and their impact',
        '🌱 Ethics & Controversies': 'Ethical implications and scientific debates',
        '🎛 Narrative Mix': 'Story-driven approach to scientific learning',
      },
      examples: ['Quantum Physics', 'Evolution', 'Climate Change', 'Space Exploration'],
    ),
    LearningCategory(
      id: 'creativity',
      name: 'Creativity & Design',
      description: 'Art, design, innovation, and creative thinking',
      icon: '💡',
      levels: ['🎨 Design Fundamentals', '📚 Iconic Examples', '🛠 Frameworks & Tools', '🎛 Creative Blend'],
      levelDescriptions: {
        '🎨 Design Fundamentals': 'Basic principles of design and creativity',
        '📚 Iconic Examples': 'Masterpieces and creative breakthroughs',
        '🛠 Frameworks & Tools': 'Methods and tools for creative work',
        '🎛 Creative Blend': 'Mixed approach to creative learning',
      },
      examples: ['Design Thinking', 'Photography', 'Writing', 'Innovation'],
    ),
    LearningCategory(
      id: 'self-growth',
      name: 'Self-Growth',
      description: 'Personal development, productivity, and life skills',
      icon: '🌱',
      levels: ['📖 Philosophy & Mental Models', '🎯 Self-Development', '💬 Habits & Mindset', '🎛 Reflective Mix'],
      levelDescriptions: {
        '📖 Philosophy & Mental Models': 'Deep thinking frameworks and philosophies',
        '🎯 Self-Development': 'Practical personal improvement strategies',
        '💬 Habits & Mindset': 'Building better habits and mindset shifts',
        '🎛 Reflective Mix': 'Thoughtful approach to personal growth',
      },
      examples: ['Productivity', 'Meditation', 'Goal Setting', 'Time Management'],
    ),
    LearningCategory(
      id: 'history',
      name: 'History & Culture',
      description: 'Historical events, cultures, and human stories',
      icon: '📚',
      levels: ['🗺️ Timelines', '🌍 Cultural Impact', '🎶 Media & Storytelling', '🎛 Blended Approach'],
      levelDescriptions: {
        '🗺️ Timelines': 'Chronological events and historical progression',
        '🌍 Cultural Impact': 'How events shaped culture and society',
        '🎶 Media & Storytelling': 'Stories, documentaries, and narrative history',
        '🎛 Blended Approach': 'Mix of facts, culture, and storytelling',
      },
      examples: ['World Wars', 'Ancient Civilizations', 'Cultural Movements', 'Biographies'],
    ),
    LearningCategory(
      id: 'skills',
      name: 'Skills & Tools',
      description: 'Practical skills, tools, and how-to knowledge',
      icon: '🛠',
      levels: ['🧰 Getting Started', '🔧 Pro Tools & Hacks', '📈 Workflows & Systems', '🎛 Practical Guide'],
      levelDescriptions: {
        '🧰 Getting Started': 'Beginner-friendly introductions and basics',
        '🔧 Pro Tools & Hacks': 'Advanced tools and professional techniques',
        '📈 Workflows & Systems': 'Efficient processes and systematic approaches',
        '🎛 Practical Guide': 'Hands-on, actionable learning',
      },
      examples: ['Excel', 'Public Speaking', 'Negotiation', 'Cooking'],
    ),
    LearningCategory(
      id: 'career',
      name: 'Career & Strategy',
      description: 'Professional development and career advancement',
      icon: '🎯',
      levels: ['🪞 Identity & Purpose', '📄 Career Assets', '🧭 Strategic Moves', '🎛 Holistic Journey'],
      levelDescriptions: {
        '🪞 Identity & Purpose': 'Finding your career direction and purpose',
        '📄 Career Assets': 'Building skills, network, and reputation',
        '🧭 Strategic Moves': 'Advanced career strategies and transitions',
        '🎛 Holistic Journey': 'Complete career development approach',
      },
      examples: ['Job Interviews', 'Networking', 'Career Change', 'Professional Branding'],
    ),
    LearningCategory(
      id: 'law',
      name: 'Law & Governance',
      description: 'Legal systems, governance, and civic structures',
      icon: '🏛',
      levels: ['📜 Legal Foundations', '🧭 Governance & Policy', '⚖️ Case Law & Precedents', '🎛 Civic Systems Mix'],
      levelDescriptions: {
        '📜 Legal Foundations': 'Basic legal principles and constitutional concepts',
        '🧭 Governance & Policy': 'How governments work and policy development',
        '⚖️ Case Law & Precedents': 'Important legal cases and their impact',
        '🎛 Civic Systems Mix': 'Comprehensive understanding of legal and civic systems',
      },
      examples: ['Constitutional Law', 'Civil Rights', 'Corporate Governance', 'Policy Analysis'],
    ),
    LearningCategory(
      id: 'geopolitics',
      name: 'Geopolitics & Global Affairs',
      description: 'International relations, diplomacy, and global events',
      icon: '🗺',
      levels: ['🌐 Power Dynamics', '🤝 Diplomacy & Alliances', '💣 Conflicts & Security', '🎛 Global Narrative Mix'],
      levelDescriptions: {
        '🌐 Power Dynamics': 'How nations and global powers interact',
        '🤝 Diplomacy & Alliances': 'International cooperation and strategic partnerships',
        '💣 Conflicts & Security': 'Global conflicts, security issues, and peace efforts',
        '🎛 Global Narrative Mix': 'Comprehensive view of world affairs and trends',
      },
      examples: ['International Trade', 'Diplomatic History', 'Global Security', 'Regional Politics'],
    ),
    LearningCategory(
      id: 'environment',
      name: 'Environment & Sustainability',
      description: 'Climate science, ecology, and sustainable systems',
      icon: '🌿',
      levels: ['🌱 Climate & Ecology', '🔋 Sustainable Systems', '🧪 Environmental Tech', '🎛 Eco-Strategy Blend'],
      levelDescriptions: {
        '🌱 Climate & Ecology': 'Climate science and ecological relationships',
        '🔋 Sustainable Systems': 'Sustainable practices and circular economy',
        '🧪 Environmental Tech': 'Green technology and environmental solutions',
        '🎛 Eco-Strategy Blend': 'Holistic approach to environmental challenges',
      },
      examples: ['Climate Change', 'Renewable Energy', 'Conservation', 'Green Technology'],
    ),
    LearningCategory(
      id: 'mathematics',
      name: 'Mathematics & Logic',
      description: 'Mathematical concepts, logic systems, and formal reasoning',
      icon: '📐',
      levels: ['🧮 Foundational Concepts', '🔢 Applied Techniques', '🧠 Logic & Formal Systems', '🎛 Mathematical Narrative'],
      levelDescriptions: {
        '🧮 Foundational Concepts': 'Core mathematical principles and theories',
        '🔢 Applied Techniques': 'Practical mathematical applications and problem-solving',
        '🧠 Logic & Formal Systems': 'Logical reasoning and formal mathematical systems',
        '🎛 Mathematical Narrative': 'Story-driven approach to mathematical learning',
      },
      examples: ['Calculus', 'Statistics', 'Game Theory', 'Cryptography'],
    ),
    LearningCategory(
      id: 'gaming',
      name: 'Gaming & Interactive Media',
      description: 'Game design, player experience, and interactive storytelling',
      icon: '🎮',
      levels: ['🎮 Game Design Principles', '🧠 Player Experience', '📚 Iconic Games & Genres', '🎛 Gaming Culture Mix'],
      levelDescriptions: {
        '🎮 Game Design Principles': 'Fundamentals of game mechanics and design',
        '🧠 Player Experience': 'Psychology of gaming and player engagement',
        '📚 Iconic Games & Genres': 'Influential games and genre evolution',
        '🎛 Gaming Culture Mix': 'Gaming industry, culture, and community aspects',
      },
      examples: ['Game Mechanics', 'Virtual Reality', 'Esports', 'Interactive Storytelling'],
    ),
    LearningCategory(
      id: 'society',
      name: 'Society & Ethics',
      description: 'Social structures, moral frameworks, and ethical dilemmas',
      icon: '🌍',
      levels: ['🧭 Social Structures', '🧬 Moral Frameworks', '💬 Real-World Ethics', '🎛 Reflective Society Blend'],
      levelDescriptions: {
        '🧭 Social Structures': 'How societies organize and function',
        '🧬 Moral Frameworks': 'Ethical theories and moral reasoning',
        '💬 Real-World Ethics': 'Practical ethical dilemmas and applications',
        '🎛 Reflective Society Blend': 'Comprehensive view of society and ethics',
      },
      examples: ['Social Justice', 'Medical Ethics', 'AI Ethics', 'Cultural Anthropology'],
    ),
    LearningCategory(
      id: 'futurism',
      name: 'Futurism & Exploration',
      description: 'Space exploration, emerging technologies, and future scenarios',
      icon: '🚀',
      levels: ['🌌 Space & Cosmos', '🤖 Emerging Futures', '🔭 Exploration Scenarios', '🎛 Futuristic Outlooks'],
      levelDescriptions: {
        '🌌 Space & Cosmos': 'Space exploration and cosmic phenomena',
        '🤖 Emerging Futures': 'Future technologies and societal changes',
        '🔭 Exploration Scenarios': 'Hypothetical futures and exploration possibilities',
        '🎛 Futuristic Outlooks': 'Comprehensive view of potential futures',
      },
      examples: ['Space Travel', 'Future Tech', 'Colonization', 'Transhumanism'],
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
