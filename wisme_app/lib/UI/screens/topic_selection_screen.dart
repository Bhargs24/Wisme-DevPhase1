import '../../core/exports.dart';
class TopicSelectionScreen extends StatefulWidget {
  final String searchQuery;
  
  const TopicSelectionScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedCategory = '';
  String _selectedLevel = '';
  bool _isAnalyzing = true;
  
  // Predefined categories and levels
  final List<String> _availableCategories = [
    'Technology',
    'Business & Finance',
    'Psychology & Mind',
    'Science & Nature',
    'Creativity & Design',
    'Self-Growth',
    'History & Culture',
    'Skills & Tools',
    'Career & Strategy',
    'Law & Governance',
    'Geopolitics & Global Affairs',
    'Environment & Sustainability',
    'Mathematics & Logic',
    'Gaming & Interactive Media',
    'Society & Ethics',
    'Futurism & Exploration',
  ];
  
  final List<String> _availableLevels = [
    '🔹 Core Concepts',
    '💼 Case Studies', 
    '🛠 Tools & Trends',
    '🎛 Bit of Everything',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _startTopicAnalysis();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTopicAnalysis() async {
    // Simulate AI analysis with loading animation
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isAnalyzing = false;
      // Topic analysis completed - ready for next step
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Learning about "${widget.searchQuery}"'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isAnalyzing 
            ? _buildAnalyzingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildTopicSelectionContent(),
                ),
              ),
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated analysis indicator
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 48,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'AI is analyzing your topic...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Finding the best learning path for "${widget.searchQuery}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Analysis steps
          _buildAnalysisStep('Understanding your topic', true),
          const SizedBox(height: 12),
          _buildAnalysisStep('Mapping to categories', true),
          const SizedBox(height: 12),
          _buildAnalysisStep('Personalizing content levels', false),
        ],
      ),
    );
  }

  Widget _buildAnalysisStep(String step, bool isComplete) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isComplete 
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Text(
          step,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isComplete 
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicSelectionContent() {
    return CustomScrollView(
      slivers: [
        // AI Analysis Results Header
        SliverToBoxAdapter(
          child: _buildAnalysisHeader(),
        ),
        
        // Category Selection
        SliverToBoxAdapter(
          child: _buildCategorySelection(),
        ),
        
        // Level Selection
        SliverToBoxAdapter(
          child: _buildLevelSelection(),
        ),
        
        // Learning Style Preferences
        SliverToBoxAdapter(
          child: _buildLearningStyleSection(),
        ),
        
        // Continue Button
        SliverToBoxAdapter(
          child: _buildContinueSection(),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildAnalysisHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                
                const SizedBox(width: 12),
                
                Text(
                  'AI Analysis Complete',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Based on your query "${widget.searchQuery}", I\'ve identified the best learning categories and suggested optimal content levels for you.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Learning Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Which aspect interests you most?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._availableCategories.map((category) {
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryCard(
                category: category,
                description: _getCategoryDescription(category),
                icon: _getCategoryIcon(category),
                isSelected: isSelected,
                onTap: () => setState(() => _selectedCategory = category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLevelSelection() {
    if (_selectedCategory.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Learning Level',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'How deep do you want to dive?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          
          ..._availableLevels.map((level) {
            final isSelected = level == _selectedLevel;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLevelCard(
                level: level,
                description: _getLevelDescription(level),
                duration: _getLevelDuration(level),
                isSelected: isSelected,
                onTap: () => setState(() => _selectedLevel = level),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLearningStyleSection() {
    if (_selectedLevel.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Style Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStyleToggle(
                  icon: Icons.book_outlined,
                  label: 'Theory',
                  isSelected: true,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildStyleToggle(
                  icon: Icons.lightbulb_outline,
                  label: 'Stories',
                  isSelected: true,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildStyleToggle(
                  icon: Icons.build_outlined,
                  label: 'Tools',
                  isSelected: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContinueSection() {
    if (_selectedCategory.isEmpty || _selectedLevel.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Learning Journey',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(
                      Icons.school,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Topic: ${widget.searchQuery}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Category: $_selectedCategory',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Level: $_selectedLevel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startLearningJourney(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Create My Learning Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard({
    required String category,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required String level,
    required String description,
    required String duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        level,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          duration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleToggle({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'Technology':
        return 'Learn about innovations, programming, AI, and digital trends';
      case 'Business & Finance':
        return 'Explore entrepreneurship, finance, marketing, and leadership strategies';
      case 'Psychology & Mind':
        return 'Understand human behavior, mental models, and cognitive science';
      case 'Science & Nature':
        return 'Discover scientific principles, discoveries, and natural phenomena';
      case 'Creativity & Design':
        return 'Master design thinking, art, innovation, and creative processes';
      case 'Self-Growth':
        return 'Personal development, productivity, habits, and mindset mastery';
      case 'History & Culture':
        return 'Explore historical events, cultural impact, and human stories';
      case 'Skills & Tools':
        return 'Learn practical skills, tools, workflows, and professional techniques';
      case 'Career & Strategy':
        return 'Advance your career, strategic thinking, and professional growth';
      case 'Law & Governance':
        return 'Understand legal systems, governance, policy, and civic structures';
      case 'Geopolitics & Global Affairs':
        return 'International relations, diplomacy, conflicts, and global dynamics';
      case 'Environment & Sustainability':
        return 'Climate science, ecology, green technology, and sustainable systems';
      case 'Mathematics & Logic':
        return 'Mathematical concepts, logic systems, and formal reasoning';
      case 'Gaming & Interactive Media':
        return 'Game design, player experience, and interactive storytelling';
      case 'Society & Ethics':
        return 'Social structures, moral frameworks, and ethical dilemmas';
      case 'Futurism & Exploration':
        return 'Space exploration, emerging technologies, and future scenarios';
      default:
        return 'Explore this fascinating area of knowledge';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Technology':
        return Icons.computer;
      case 'Business':
        return Icons.business;
      case 'Psychology':
        return Icons.psychology;
      case 'Science':
        return Icons.science;
      default:
        return Icons.school;
    }
  }

  String _getLevelDescription(String level) {
    switch (level) {
      case '🔹 Core Concepts':
        return 'Fundamental principles and how things work';
      case '💼 Case Studies':
        return 'Real-world examples and success stories';
      case '🛠 Tools & Trends':
        return 'Latest tools, techniques, and emerging trends';
      case '🎛 Bit of Everything':
        return 'Mixed approach with concepts, stories, and tools';
      case '💡 Fundamentals':
        return 'Essential concepts and foundational knowledge';
      case '📈 Growth Strategy':
        return 'Advanced tactics for scaling and strategic growth';
      case '🎛 Balanced Mix':
        return 'Combination of theory, cases, and strategies';
      case '🧠 Theories & Experiments':
        return 'Scientific studies and theoretical frameworks';
      case '💬 Real-Life Application':
        return 'Practical applications for everyday life';
      case '🧘 Mindfulness & Behavior':
        return 'Mental health, habits, and personal development';
      case '🎛 Mixed Approach':
        return 'Blend of theory, application, and mindfulness';
      case '🔬 Scientific Concepts':
        return 'Core scientific principles and theories';
      case '🧬 Discoveries':
        return 'Breakthrough discoveries and their impact';
      case '🌱 Ethics & Controversies':
        return 'Ethical implications and scientific debates';
      case '🎛 Narrative Mix':
        return 'Story-driven approach to learning';
      case '🎨 Design Fundamentals':
        return 'Basic principles of design and creativity';
      case '📚 Iconic Examples':
        return 'Masterpieces and creative breakthroughs';
      case '🛠 Frameworks & Tools':
        return 'Methods and tools for creative work';
      case '🎛 Creative Blend':
        return 'Mixed approach to creative learning';
      case '📖 Philosophy & Mental Models':
        return 'Deep thinking frameworks and philosophies';
      case '🎯 Self-Development':
        return 'Practical personal improvement strategies';
      case '🗺️ Timelines':
        return 'Chronological events and historical progression';
      case '🌍 Cultural Impact':
        return 'How events shaped culture and society';
      case '🎶 Media & Storytelling':
        return 'Stories, documentaries, and narrative history';
      case '🎛 Blended Approach':
        return 'Mix of facts, culture, and storytelling';
      case '🧰 Getting Started':
        return 'Beginner-friendly introductions and basics';
      case '🔧 Pro Tools & Hacks':
        return 'Advanced tools and professional techniques';
      case '📈 Workflows & Systems':
        return 'Efficient processes and systematic approaches';
      case '🎛 Practical Guide':
        return 'Hands-on, actionable learning';
      case '🪞 Identity & Purpose':
        return 'Finding your career direction and purpose';
      case '📄 Career Assets':
        return 'Building skills, network, and reputation';
      case '🧭 Strategic Moves':
        return 'Advanced career strategies and transitions';
      case '🎛 Holistic Journey':
        return 'Complete career development approach';
      case '📜 Legal Foundations':
        return 'Basic legal principles and constitutional concepts';
      case '🧭 Governance & Policy':
        return 'How governments work and policy development';
      case '⚖️ Case Law & Precedents':
        return 'Important legal cases and their impact';
      case '🎛 Civic Systems Mix':
        return 'Comprehensive understanding of legal systems';
      case '🌐 Power Dynamics':
        return 'How nations and global powers interact';
      case '🤝 Diplomacy & Alliances':
        return 'International cooperation and partnerships';
      case '💣 Conflicts & Security':
        return 'Global conflicts, security issues, and peace';
      case '🎛 Global Narrative Mix':
        return 'Comprehensive view of world affairs';
      case '🌱 Climate & Ecology':
        return 'Climate science and ecological relationships';
      case '🔋 Sustainable Systems':
        return 'Sustainable practices and circular economy';
      case '🧪 Environmental Tech':
        return 'Green technology and environmental solutions';
      case '🎛 Eco-Strategy Blend':
        return 'Holistic approach to environmental challenges';
      case '🧮 Foundational Concepts':
        return 'Core mathematical principles and theories';
      case '🔢 Applied Techniques':
        return 'Practical mathematical applications';
      case '🧠 Logic & Formal Systems':
        return 'Logical reasoning and formal systems';
      case '🎛 Mathematical Narrative':
        return 'Story-driven approach to mathematics';
      case '🎮 Game Design Principles':
        return 'Fundamentals of game mechanics and design';
      case '🧠 Player Experience':
        return 'Psychology of gaming and player engagement';
      case '📚 Iconic Games & Genres':
        return 'Influential games and genre evolution';
      case '🎛 Gaming Culture Mix':
        return 'Gaming industry, culture, and community';
      case '🧭 Social Structures':
        return 'How societies organize and function';
      case '🧬 Moral Frameworks':
        return 'Ethical theories and moral reasoning';
      case '💬 Real-World Ethics':
        return 'Practical ethical dilemmas and applications';
      case '🎛 Reflective Society Blend':
        return 'Comprehensive view of society and ethics';
      case '🌌 Space & Cosmos':
        return 'Space exploration and cosmic phenomena';
      case '🤖 Emerging Futures':
        return 'Future technologies and societal changes';
      case '🔭 Exploration Scenarios':
        return 'Hypothetical futures and exploration possibilities';
      case '🎛 Futuristic Outlooks':
        return 'Comprehensive view of potential futures';
      default:
        return 'Comprehensive learning approach';
    }
  }

  String _getLevelDuration(String level) {
    switch (level) {
      case '🔹 Core Concepts':
      case '💡 Fundamentals':
      case '📖 Philosophy & Mental Models':
      case '🔬 Scientific Concepts':
      case '🎨 Design Fundamentals':
      case '📜 Legal Foundations':
      case '🧮 Foundational Concepts':
      case '🎮 Game Design Principles':
        return '5-7 days';
      case '💼 Case Studies':
      case '📚 Iconic Examples':
      case '🧬 Discoveries':
      case '⚖️ Case Law & Precedents':
      case '📚 Iconic Games & Genres':
        return '3-5 days';
      case '🛠 Tools & Trends':
      case '🔧 Pro Tools & Hacks':
      case '🧪 Environmental Tech':
      case '🔢 Applied Techniques':
      case '🤖 Emerging Futures':
        return '4-6 days';
      case '🎛 Bit of Everything':
      case '🎛 Balanced Mix':
      case '🎛 Mixed Approach':
      case '🎛 Narrative Mix':
      case '🎛 Creative Blend':
      case '🎛 Reflective Mix':
      case '🎛 Blended Approach':
      case '🎛 Practical Guide':
      case '🎛 Holistic Journey':
      case '🎛 Civic Systems Mix':
      case '🎛 Global Narrative Mix':
      case '🎛 Eco-Strategy Blend':
      case '🎛 Mathematical Narrative':
      case '🎛 Gaming Culture Mix':
      case '🎛 Reflective Society Blend':
      case '🎛 Futuristic Outlooks':
        return '6-8 days';
      case '📈 Growth Strategy':
      case '🧭 Strategic Moves':
      case '🌐 Power Dynamics':
      case '💣 Conflicts & Security':
        return '7-10 days';
      case '💬 Real-Life Application':
      case '🧘 Mindfulness & Behavior':
      case '🎯 Self-Development':
      case '💬 Habits & Mindset':
      case '🧰 Getting Started':
      case '💬 Real-World Ethics':
        return '4-6 days';
      case '🌱 Ethics & Controversies':
      case '🗺️ Timelines':
      case '🌍 Cultural Impact':
      case '🎶 Media & Storytelling':
      case '📈 Workflows & Systems':
      case '🪞 Identity & Purpose':
      case '📄 Career Assets':
      case '🧭 Governance & Policy':
      case '🤝 Diplomacy & Alliances':
      case '🌱 Climate & Ecology':
      case '🔋 Sustainable Systems':
      case '🧠 Logic & Formal Systems':
      case '🧠 Player Experience':
      case '🧭 Social Structures':
      case '🧬 Moral Frameworks':
      case '🌌 Space & Cosmos':
      case '🔭 Exploration Scenarios':
        return '5-7 days';
      default:
        return '5-7 days';
    }
  }

  void _startLearningJourney() {
    Navigator.pushNamed(
      context, 
      AppRoutes.lesson,
      arguments: {
        'topic': widget.searchQuery,
        'category': _selectedCategory,
        'level': _selectedLevel,
      },
    );
  }
}


