import '../../core/exports.dart';

class JourneyPlanningScreen extends StatefulWidget {
  final String topic;
  final String category;
  final String knowledgeLevel;
  final Map<String, dynamic> coachData;

  const JourneyPlanningScreen({
    super.key,
    required this.topic,
    required this.category,
    required this.knowledgeLevel,
    required this.coachData,
  });

  @override
  State<JourneyPlanningScreen> createState() => _JourneyPlanningScreenState();
}

class _JourneyPlanningScreenState extends State<JourneyPlanningScreen>
    with TickerProviderStateMixin {
  int selectedDuration = 7; // Default 7 days
  String selectedPace = 'balanced'; // relaxed, balanced, intensive
  List<String> selectedGoals = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> durationOptions = [
    {'days': 3, 'title': 'Quick Sprint', 'subtitle': '3 days', 'icon': Icons.flash_on},
    {'days': 7, 'title': 'Weekly Journey', 'subtitle': '1 week', 'icon': Icons.calendar_view_week},
    {'days': 14, 'title': 'Deep Dive', 'subtitle': '2 weeks', 'icon': Icons.timeline},
    {'days': 30, 'title': 'Master Course', 'subtitle': '1 month', 'icon': Icons.school},
  ];

  final List<Map<String, dynamic>> paceOptions = [
    {
      'id': 'relaxed',
      'title': '🌱 Relaxed',
      'subtitle': '10-15 min/day',
      'description': 'Perfect for busy schedules',
      'color': Colors.green,
    },
    {
      'id': 'balanced',
      'title': '⚖️ Balanced',
      'subtitle': '15-20 min/day',
      'description': 'Steady progress with flexibility',
      'color': Colors.blue,
    },
    {
      'id': 'intensive',
      'title': '🚀 Intensive',
      'subtitle': '20-30 min/day',
      'description': 'Fast-track learning',
      'color': Colors.orange,
    },
  ];

  final List<Map<String, String>> learningGoals = [
    {'id': 'practical', 'title': 'Practical Skills', 'icon': '🛠️'},
    {'id': 'concepts', 'title': 'Core Concepts', 'icon': '🧠'},
    {'id': 'examples', 'title': 'Real Examples', 'icon': '📊'},
    {'id': 'stories', 'title': 'Success Stories', 'icon': '📖'},
    {'id': 'trends', 'title': 'Latest Trends', 'icon': '📈'},
    {'id': 'tools', 'title': 'Tools & Resources', 'icon': '⚒️'},
  ];

  @override
  void initState() {
    super.initState();
    selectedGoals = ['practical', 'concepts']; // Default goals
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildLearningPathSummary(),
                      const SizedBox(height: 32),
                      _buildDurationSelection(),
                      const SizedBox(height: 32),
                      _buildPaceSelection(),
                      const SizedBox(height: 32),
                      _buildGoalsSelection(),
                      const SizedBox(height: 32),
                      _buildJourneyPreview(),
                      const SizedBox(height: 32),
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Journey',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Customize your learning experience',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPathSummary() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ModernCard(
        backgroundColor: widget.coachData['color'].withOpacity(0.05),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.coachData['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      widget.coachData['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.coachData['name']} will guide you through',
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        widget.topic,
                        style: AppTextStyles.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.coachData['color'],
                        ),
                      ),
                      Text(
                        '${widget.category} • ${widget.knowledgeLevel.toUpperCase()} Level',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Journey Duration', Icons.schedule),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: durationOptions.length,
          itemBuilder: (context, index) {
            final option = durationOptions[index];
            final isSelected = selectedDuration == option['days'];
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDuration = option['days'];
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        option['icon'],
                        size: 32,
                        color: isSelected ? AppColors.primary : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option['title'],
                        style: AppTextStyles.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        option['subtitle'],
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Learning Pace', Icons.speed),
        const SizedBox(height: 16),
        Column(
          children: paceOptions.map((option) {
            final isSelected = selectedPace == option['id'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPace = option['id'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? option['color'].withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? option['color'] : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: option['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: option['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'],
                              style: AppTextStyles.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? option['color'] : Colors.black87,
                              ),
                            ),
                            Text(
                              option['subtitle'],
                              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                color: option['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              option['description'],
                              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: option['color'],
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalsSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Learning Goals', Icons.flag),
        const SizedBox(height: 8),
        Text(
          'What do you want to focus on? (Select multiple)',
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: learningGoals.map((goal) {
            final isSelected = selectedGoals.contains(goal['id']);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedGoals.remove(goal['id']);
                  } else {
                    selectedGoals.add(goal['id']!);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.accent : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      goal['icon']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal['title']!,
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? AppColors.accent : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildJourneyPreview() {
    final selectedDurationData = durationOptions.firstWhere((d) => d['days'] == selectedDuration);
    final selectedPaceData = paceOptions.firstWhere((p) => p['id'] == selectedPace);
    
    return ModernCard(
      backgroundColor: Colors.green[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Your Journey Preview',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPreviewItem(
            icon: Icons.schedule,
            title: 'Duration',
            value: selectedDurationData['title'],
          ),
          _buildPreviewItem(
            icon: Icons.speed,
            title: 'Daily Commitment',
            value: selectedPaceData['subtitle'],
          ),
          _buildPreviewItem(
            icon: Icons.flag,
            title: 'Focus Areas',
            value: '${selectedGoals.length} selected goals',
          ),
          _buildPreviewItem(
            icon: Icons.person,
            title: 'Your Coach',
            value: widget.coachData['name'],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your personalized journey will be created based on these preferences. You can adjust them anytime!',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.green[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Column(
      children: [
        ModernButton(
          text: 'Start My Learning Journey',
          width: double.infinity,
          onPressed: _handleStartJourney,
          icon: Icons.play_arrow,
        ),
        const SizedBox(height: 16),
        Text(
          'Your first lesson will be ready immediately!',
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleStartJourney() {
    // Create journey data
    final journeyData = {
      'topic': widget.topic,
      'category': widget.category,
      'knowledgeLevel': widget.knowledgeLevel,
      'duration': selectedDuration,
      'pace': selectedPace,
      'goals': selectedGoals,
      'coachData': widget.coachData,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Save journey to provider
    context.read<LessonProvider>().createLearningJourney(
      userId: 'current_user', // Retrieved from authentication service
      topic: widget.topic,
      category: widget.category,
      level: widget.knowledgeLevel,
      specificInterests: selectedGoals,
    );

    // Navigate to home screen to start learning
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
      arguments: {
        'showWelcome': true,
        'journeyData': journeyData,
      },
    );
  }
}

