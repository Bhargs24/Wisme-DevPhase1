import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/user_provider.dart';
import '../../routes.dart';
import '../widgets/modern_components.dart';

class KnowledgeLevelScreen extends StatefulWidget {
  final String topic;
  final String category;

  const KnowledgeLevelScreen({
    super.key,
    required this.topic,
    required this.category,
  });

  @override
  State<KnowledgeLevelScreen> createState() => _KnowledgeLevelScreenState();
}

class _KnowledgeLevelScreenState extends State<KnowledgeLevelScreen>
    with TickerProviderStateMixin {
  String? selectedLevel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> knowledgeLevels = [
    {
      'level': 'beginner',
      'title': '🌱 Complete Beginner',
      'subtitle': 'I\'m new to this topic',
      'description': 'Start from the basics with simple explanations',
      'icon': Icons.school,
      'color': Colors.green,
      'estimatedTime': '15-20 min per lesson',
    },
    {
      'level': 'intermediate',
      'title': '🎯 Some Experience',
      'subtitle': 'I know the basics',
      'description': 'Build on existing knowledge with deeper insights',
      'icon': Icons.trending_up,
      'color': Colors.blue,
      'estimatedTime': '12-15 min per lesson',
    },
    {
      'level': 'advanced',
      'title': '🚀 Advanced Learner',
      'subtitle': 'I want expert-level content',
      'description': 'Dive deep into complex concepts and applications',
      'icon': Icons.rocket_launch,
      'color': Colors.purple,
      'estimatedTime': '10-12 min per lesson',
    },
    {
      'level': 'expert',
      'title': '💎 Industry Expert',
      'subtitle': 'I want cutting-edge insights',
      'description': 'Latest trends, research, and advanced techniques',
      'icon': Icons.diamond,
      'color': Colors.amber,
      'estimatedTime': '8-10 min per lesson',
    },
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
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
                      _buildTopicInfo(),
                      const SizedBox(height: 32),
                      _buildKnowledgeLevels(),
                      const SizedBox(height: 32),
                      _buildContinueButton(),
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
                  'Choose Your Level',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'We\'ll personalize your learning experience',
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

  Widget _buildTopicInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ModernCard(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.topic,
                            style: AppTextStyles.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Category: ${widget.category}',
                            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeLevels() {
    return Column(
      children: knowledgeLevels.asMap().entries.map((entry) {
        final index = entry.key;
        final level = entry.value;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(delay, 1.0, curve: Curves.easeOut),
              ),
            );
            
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildKnowledgeLevelCard(level),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildKnowledgeLevelCard(Map<String, dynamic> level) {
    final isSelected = selectedLevel == level['level'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLevel = level['level'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? level['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? level['color'].withOpacity(0.05) : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: level['color'].withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: level['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  level['icon'],
                  color: level['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['title'],
                      style: AppTextStyles.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? level['color'] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level['subtitle'],
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      level['description'],
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          level['estimatedTime'],
                          style: AppTextStyles.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: level['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return AnimatedOpacity(
      opacity: selectedLevel != null ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: ModernButton(
        text: 'Continue to Coach Selection',
        width: double.infinity,
        onPressed: selectedLevel != null ? _handleContinue : null,
        icon: Icons.arrow_forward,
      ),
    );
  }

  void _handleContinue() {
    if (selectedLevel == null) return;

    // Save the selected knowledge level
    context.read<UserProvider>().updateKnowledgeLevel(selectedLevel!);

    // Navigate to coach selection
    Navigator.pushNamed(
      context,
      AppRoutes.coachSelection,
      arguments: {
        'topic': widget.topic,
        'category': widget.category,
        'knowledgeLevel': selectedLevel,
      },
    );
  }
}
