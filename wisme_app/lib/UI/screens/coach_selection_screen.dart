import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
// TODO: Replace with CoachManager
import '../../app/navigation/app_router.dart';
import '../widgets/modern_components.dart';

class CoachSelectionScreen extends StatefulWidget {
  final String topic;
  final String category;
  final String knowledgeLevel;

  const CoachSelectionScreen({
    super.key,
    required this.topic,
    required this.category,
    required this.knowledgeLevel,
  });

  @override
  State<CoachSelectionScreen> createState() => _CoachSelectionScreenState();
}

class _CoachSelectionScreenState extends State<CoachSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedCoachId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> coaches = [
    {
      'id': 'kai',
      'name': 'Kai',
      'personality': 'The Wise Mentor',
      'description': 'Calm, thoughtful, and encouraging. Perfect for deep learning.',
      'voice': 'Professional male voice with warm undertones',
      'strengths': ['Complex concepts', 'Patient explanations', 'Motivational'],
      'avatar': '👨‍🏫',
      'color': Colors.blue,
      'specialties': ['Technology', 'Business', 'Science'],
    },
    {
      'id': 'vee',
      'name': 'Vee',
      'personality': 'The Energetic Guide',
      'description': 'Upbeat, engaging, and fun. Makes learning feel like play.',
      'voice': 'Energetic female voice with enthusiasm',
      'strengths': ['Creative topics', 'Engagement', 'Storytelling'],
      'avatar': '👩‍🎓',
      'color': Colors.pink,
      'specialties': ['Creativity', 'Self-Growth', 'Skills'],
    },
    {
      'id': 'alex',
      'name': 'Alex',
      'personality': 'The Strategic Thinker',
      'description': 'Analytical, precise, and goal-oriented. Great for structured learning.',
      'voice': 'Clear, authoritative voice with confidence',
      'strengths': ['Business strategy', 'Analytics', 'Problem-solving'],
      'avatar': '👨‍💼',
      'color': Colors.green,
      'specialties': ['Business', 'Career', 'Strategy'],
    },
    {
      'id': 'nova',
      'name': 'Nova',
      'personality': 'The Innovation Catalyst',
      'description': 'Curious, inspiring, and forward-thinking. Pushes boundaries.',
      'voice': 'Dynamic voice with inspirational energy',
      'strengths': ['Innovation', 'Future trends', 'Creative thinking'],
      'avatar': '🚀',
      'color': Colors.purple,
      'specialties': ['Technology', 'Creativity', 'Future Skills'],
    },
  ];

  @override
  void initState() {
    super.initState();
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
                      _buildLearningPathInfo(),
                      const SizedBox(height: 32),
                      _buildCoachGrid(),
                      const SizedBox(height: 32),
                      _buildSelectedCoachPreview(),
                      const SizedBox(height: 24),
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
                  'Choose Your AI Coach',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Your personal learning companion',
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

  Widget _buildLearningPathInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ModernCard(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Learning Path',
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.topic} • ${widget.category} • ${widget.knowledgeLevel.toUpperCase()}',
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Each coach has a unique personality and teaching style. Choose the one that resonates with you!',
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
      ),
    );
  }

  Widget _buildCoachGrid() {
    return Column(
      children: coaches.asMap().entries.map((entry) {
        final index = entry.key;
        final coach = entry.value;
        
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
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildCoachCard(coach),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCoachCard(Map<String, dynamic> coach) {
    final isSelected = selectedCoachId == coach['id'];
    final isRecommended = (coach['specialties'] as List<String>)
        .contains(widget.category);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCoachId = coach['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? coach['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? coach['color'].withValues(alpha: 0.05) : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: coach['color'].withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: coach['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            coach['avatar'],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  coach['name'],
                                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? coach['color'] : Colors.black87,
                                  ),
                                ),
                                if (isRecommended) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 12,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'RECOMMENDED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              coach['personality'],
                              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                color: coach['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: coach['color'],
                          size: 28,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    coach['description'],
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          coach['voice'],
                          style: AppTextStyles.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: (coach['strengths'] as List<String>).map((strength) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: coach['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          strength,
                          style: AppTextStyles.textTheme.bodySmall?.copyWith(
                            color: coach['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCoachPreview() {
    if (selectedCoachId == null) return const SizedBox.shrink();
    
    final selectedCoach = coaches.firstWhere((coach) => coach['id'] == selectedCoachId);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: ModernCard(
        backgroundColor: selectedCoach['color'].withValues(alpha: 0.05),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: selectedCoach['color'],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Coach Preview',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: selectedCoach['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedCoach['color'].withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        selectedCoach['avatar'],
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hi! I\'m ${selectedCoach['name']}, and I\'m excited to help you learn ${widget.topic}! Let\'s make this journey amazing together.',
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: selectedCoach['color'],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to hear voice preview',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: selectedCoach['color'],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return AnimatedOpacity(
      opacity: selectedCoachId != null ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: ModernButton(
        text: 'Continue with ${selectedCoachId != null ? coaches.firstWhere((c) => c['id'] == selectedCoachId)['name'] : 'Coach'}',
        width: double.infinity,
        onPressed: selectedCoachId != null ? _handleContinue : null,
        icon: Icons.arrow_forward,
      ),
    );
  }

  void _handleContinue() {
    if (selectedCoachId == null) return;

    final selectedCoach = coaches.firstWhere((coach) => coach['id'] == selectedCoachId);

    // Save the selected coach
    context.read<CoachProvider>().setSelectedCoach(selectedCoach);

    // Navigate to coach naming screen
    Navigator.pushNamed(
      context,
      AppRoutes.coachNaming,
      arguments: {
        'topic': widget.topic,
        'category': widget.category,
        'knowledgeLevel': widget.knowledgeLevel,
        'coachId': selectedCoachId,
        'coachData': selectedCoach,
      },
    );
  }
}

