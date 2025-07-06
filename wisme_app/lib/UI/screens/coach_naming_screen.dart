import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // TODO: Remove when provider migration complete
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
// TODO: Replace with CoachManager import
// TODO: Replace with AppRouter import
import '../widgets/modern_components.dart';

class CoachNamingScreen extends StatefulWidget {
  final String topic;
  final String category;
  final String knowledgeLevel;
  final String coachId;
  final Map<String, dynamic> coachData;

  const CoachNamingScreen({
    super.key,
    required this.topic,
    required this.category,
    required this.knowledgeLevel,
    required this.coachId,
    required this.coachData,
  });

  @override
  State<CoachNamingScreen> createState() => _CoachNamingScreenState();
}

class _CoachNamingScreenState extends State<CoachNamingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> suggestedNames = [
    'Alex', 'Jamie', 'Sam', 'Chris', 'Taylor', 'Jordan',
    'Casey', 'Morgan', 'Riley', 'Blake', 'Sage', 'Quinn'
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.coachData['name'] ?? '';
    
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
    _nameController.dispose();
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
                      _buildCoachPreview(),
                      const SizedBox(height: 32),
                      _buildNameInput(),
                      const SizedBox(height: 24),
                      _buildSuggestedNames(),
                      const SizedBox(height: 32),
                      _buildPersonalizationOptions(),
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
                  'Name Your Coach',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Make this learning journey personal',
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

  Widget _buildCoachPreview() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ModernCard(
          backgroundColor: widget.coachData['color'].withValues(alpha: 0.05),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: widget.coachData['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: widget.coachData['color'].withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.coachData['avatar'],
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.coachData['personality'],
                style: AppTextStyles.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.coachData['color'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.coachData['description'],
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.coachData['avatar'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hi there! I\'m excited to be your learning companion. What would you like to call me?',
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
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

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coach Name',
          style: AppTextStyles.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField( // TODO: Replace with ModernTextField
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Enter a name for your coach',
            prefixIcon: Icon(Icons.person),
            hintText: 'e.g., Alex, Chris, Sam...',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose something that feels personal and comfortable to you',
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedNames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.amber[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Suggestions',
              style: AppTextStyles.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: suggestedNames.map((name) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _nameController.text = name;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _nameController.text == name
                      ? widget.coachData['color'].withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _nameController.text == name
                        ? widget.coachData['color']
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  name,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: _nameController.text == name
                        ? widget.coachData['color']
                        : Colors.grey[700],
                    fontWeight: _nameController.text == name
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalizationOptions() {
    return ModernCard(
      backgroundColor: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Personalization Preview',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPersonalizationItem(
            icon: Icons.school,
            title: 'Topic',
            value: widget.topic,
          ),
          _buildPersonalizationItem(
            icon: Icons.category,
            title: 'Category',
            value: widget.category,
          ),
          _buildPersonalizationItem(
            icon: Icons.trending_up,
            title: 'Level',
            value: widget.knowledgeLevel.toUpperCase(),
          ),
          _buildPersonalizationItem(
            icon: Icons.person,
            title: 'Coach Style',
            value: widget.coachData['personality'],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizationItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 12),
          Text(
            '$title:',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Column(
      children: [
        AnimatedOpacity(
          opacity: _nameController.text.isNotEmpty ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: ModernButton(
            text: 'Start Learning Journey',
            width: double.infinity,
            onPressed: _nameController.text.isNotEmpty ? _handleContinue : null,
            icon: Icons.rocket_launch,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You can always change the name later in settings',
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleContinue() {
    if (_nameController.text.isEmpty) return;

    // Update coach with custom name
    final updatedCoachData = Map<String, dynamic>.from(widget.coachData);
    updatedCoachData['name'] = _nameController.text;
    updatedCoachData['isCustomNamed'] = true;

    // Save the coach with custom name
    // TODO: Replace with CoachManager.instance
    // context.read<CoachProvider>().setSelectedCoach(updatedCoachData);

    // Navigate to journey planning
    Navigator.pushNamed(
      context,
      '/journey-planning', // TODO: Replace AppRoutes.journeyPlanning
      arguments: {
        'topic': widget.topic,
        'category': widget.category,
        'knowledgeLevel': widget.knowledgeLevel,
        'coachData': updatedCoachData,
      },
    );
  }
}
