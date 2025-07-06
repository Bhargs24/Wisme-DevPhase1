import '../../core/exports.dart';

/// Premium dashboard with comprehensive learning analytics and personalized recommendations
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildLearningStreakCard(),
                  _buildQuickActions(),
                  _buildLearningProgress(),
                  _buildPersonalizedRecommendations(),
                  _buildRecentActivity(),
                  _buildUpcomingGoals(),
                  _buildAchievementHighlights(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Good ${_getTimeOfDay()}, ${userProvider.currentUser?.displayName ?? 'Learner'}!',
                          style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ready to expand your mind today?',
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      userProvider.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? '😊',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          icon: const Icon(Icons.search, color: Colors.white),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, 'advanced-settings'),
          icon: const Icon(Icons.settings, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLearningStreakCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: ModernCard(
          backgroundColor: AppColors.primary,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔥 Learning Streak',
                        style: AppTextStyles.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '7 days strong! Keep going!',
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '7',
                    style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.play_circle_filled,
                title: 'Continue Learning',
                subtitle: 'AI Fundamentals',
                color: AppColors.accent,
                onTap: () {
                  // Navigate to last lesson
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.auto_awesome,
                title: 'New Topic',
                subtitle: 'Discover something',
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.topicSelection),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ModernCard(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningProgress() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Learning Progress',
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildProgressItem('Current Week', 0.75, '6/8 sessions'),
                const SizedBox(height: 16),
                _buildProgressItem('This Month', 0.60, '18/30 days'),
                const SizedBox(height: 16),
                _buildProgressItem('AI Fundamentals', 0.85, '17/20 lessons'),
                const SizedBox(height: 20),
                ModernButton(
                  text: 'View Detailed Analytics',
                  width: double.infinity,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.learningStats),
                  icon: Icons.analytics,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalizedRecommendations() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.recommend, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended for You',
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRecommendationItem(
                  'Machine Learning Basics',
                  'Perfect next step after AI Fundamentals',
                  Icons.psychology,
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildRecommendationItem(
                  'Data Science Ethics',
                  'Hot topic in your field',
                  Icons.gavel,
                  AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _buildRecommendationItem(
                  'Python for Beginners',
                  'Trending in AI & Tech',
                  Icons.code,
                  AppColors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String reason, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.topicSelection, arguments: {'searchQuery': title});
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    reason,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildActivityItem(
                  'Completed: Neural Networks Intro',
                  '2 hours ago',
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildActivityItem(
                  'Started: Deep Learning Concepts',
                  'Yesterday',
                  Icons.play_circle,
                  AppColors.primary,
                ),
                _buildActivityItem(
                  'Achievement: Week Warrior',
                  '3 days ago',
                  Icons.emoji_events,
                  AppColors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textTheme.bodyMedium,
            ),
          ),
          Text(
            time,
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingGoals() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: ModernCard(
          backgroundColor: AppColors.accent.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Upcoming Goals',
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGoalItem('Complete AI Fundamentals', '3 lessons left'),
                _buildGoalItem('30-day learning streak', '23 days to go'),
                _buildGoalItem('Earn "Data Scientist" badge', '5 topics remaining'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, String progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.radio_button_unchecked, color: AppColors.accent, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              goal,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            progress,
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementHighlights() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(24),
        child: ModernCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Achievements',
                      style: AppTextStyles.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAchievementBadge('🔥', 'Week Warrior'),
                    _buildAchievementBadge('🧠', 'Quick Learner'),
                    _buildAchievementBadge('⭐', 'Rising Star'),
                  ],
                ),
                const SizedBox(height: 16),
                ModernButton(
                  text: 'View All Achievements',
                  width: double.infinity,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.achievementsGallery),
                  icon: Icons.emoji_events,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String title) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
