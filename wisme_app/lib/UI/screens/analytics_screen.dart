import '../../core/exports.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _tabController.dispose();
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
              _buildTabBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLearningAnalytics(),
                      _buildProgressInsights(),
                      _buildTimeAnalytics(),
                      _buildGoalsAndMilestones(),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics & Insights',
                  style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Track your learning journey with precision',
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.white.withValues(alpha:0.7),
        labelStyle: AppTextStyles.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Learning'),
          Tab(text: 'Progress'),
          Tab(text: 'Time'),
          Tab(text: 'Goals'),
        ],
      ),
    );
  }

  Widget _buildLearningAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatsOverview(),
          const SizedBox(height: 20),
          _buildLearningHeatmap(),
          const SizedBox(height: 20),
          _buildTopicPerformance(),
          const SizedBox(height: 20),
          _buildLearningVelocity(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Learning Overview',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.school,
                    label: 'Lessons Completed',
                    value: '147',
                    change: '+12 this week',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    label: 'Learning Time',
                    value: '24.5h',
                    change: '+3.2h this week',
                    isPositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.psychology,
                    label: 'Knowledge Score',
                    value: '87%',
                    change: '+5% this month',
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '12 days',
                    change: 'Best: 23 days',
                    isPositive: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String change,
    bool? isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha:0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha:0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child:              Text(
                label,
                style: AppTextStyles.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isPositive != null)
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              if (isPositive != null) const SizedBox(width: 4),
              Expanded(
                child:                Text(
                  change,
                  style: AppTextStyles.textTheme.labelSmall?.copyWith(
                    color: isPositive == null
                        ? Colors.grey[600]
                        : isPositive
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearningHeatmap() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_month, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Learning Activity Heatmap',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Simplified heatmap representation
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Learning Activity Heatmap\n(Visual representation of daily learning)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicPerformance() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.topic, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Topic Performance',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...['Technology', 'Business', 'Science', 'History', 'Arts'].map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTopicProgress(topic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicProgress(String topic) {
    final progress = [0.85, 0.72, 0.91, 0.68, 0.79];
    final index = ['Technology', 'Business', 'Science', 'History', 'Arts'].indexOf(topic);
    final value = progress[index];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              topic,
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildLearningVelocity() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Learning Velocity',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Learning Velocity Chart\n(Speed of knowledge acquisition over time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInsights() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProgressOverview(),
          const SizedBox(height: 20),
          _buildSkillProgression(),
          const SizedBox(height: 20),
          _buildDifficultyAnalysis(),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Progress Insights',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Progress Visualization\n(Journey progression graph)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillProgression() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Skill Progression',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Skill Development Timeline\n(Track skill improvement over time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyAnalysis() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Difficulty Analysis',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Learning Difficulty Distribution\n(Areas that need more focus)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalytics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTimeDistribution(),
          const SizedBox(height: 20),
          _buildOptimalLearningTimes(),
          const SizedBox(height: 20),
          _buildProductivityMetrics(),
        ],
      ),
    );
  }

  Widget _buildTimeDistribution() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Time Distribution',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Time Allocation Pie Chart\n(How you spend your learning time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimalLearningTimes() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Optimal Learning Times',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Peak Learning Hours\n(When you learn most effectively)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityMetrics() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Productivity Metrics',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Learning Efficiency Trends\n(Productivity over time)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsAndMilestones() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildCurrentGoals(),
          const SizedBox(height: 20),
          _buildMilestoneProgress(),
          const SizedBox(height: 20),
          _buildFutureTargets(),
        ],
      ),
    );
  }

  Widget _buildCurrentGoals() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Goals',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGoalItem('Complete 5 lessons this week', 0.6),
            const SizedBox(height: 16),
            _buildGoalItem('Maintain 7-day streak', 0.85),
            const SizedBox(height: 16),
            _buildGoalItem('Master JavaScript basics', 0.4),
            const SizedBox(height: 16),
            _buildGoalItem('Study for 30 minutes daily', 0.9),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child:              Text(
                goal,
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildMilestoneProgress() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Milestone Progress',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Learning Milestones Timeline\n(Major achievements and progress)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureTargets() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Future Targets',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Upcoming Goals & Objectives\n(Your learning roadmap)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


