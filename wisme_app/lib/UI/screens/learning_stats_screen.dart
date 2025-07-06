import '../../core/exports.dart';

class LearningStatsScreen extends StatefulWidget {
  const LearningStatsScreen({super.key});

  @override
  State<LearningStatsScreen> createState() => _LearningStatsScreenState();
}

class _LearningStatsScreenState extends State<LearningStatsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = 'Week';
  final List<String> _timeRanges = ['Week', 'Month', 'Year', 'All Time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Analytics'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _shareStats,
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTimeRangeSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildProgressTab(),
                _buildHabitsTab(),
                _buildInsightsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Time Range: ',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeRanges.map((range) {
                  final isSelected = range == _selectedTimeRange;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeRange = range),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Overview', icon: Icon(Icons.dashboard, size: 20)),
          Tab(text: 'Progress', icon: Icon(Icons.trending_up, size: 20)),
          Tab(text: 'Habits', icon: Icon(Icons.schedule, size: 20)),
          Tab(text: 'Insights', icon: Icon(Icons.lightbulb, size: 20)),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsOverview(),
          const SizedBox(height: 20),
          _buildLearningTimeChart(),
          const SizedBox(height: 20),
          _buildTopicsBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Time',
            value: '47.5h',
            subtitle: '+5.2h this week',
            icon: Icons.access_time,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Lessons',
            value: '134',
            subtitle: '+12 this week',
            icon: Icons.school,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
    );
  }

  Widget _buildLearningTimeChart() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Time This $_selectedTimeRange',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildSimpleChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    final data = _generateSimpleChartData();
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final height = (value / maxValue) * 150;
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${value.toStringAsFixed(1)}h',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index % 7],
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<double> _generateSimpleChartData() {
    // Generate sample data based on selected time range
    switch (_selectedTimeRange) {
      case 'Week':
        return [1.5, 2.2, 1.8, 3.1, 2.5, 1.9, 2.8];
      case 'Month':
        return List.generate(7, (index) => (index % 3 + 1) * 1.2 + (index % 2) * 0.5);
      default:
        return [1.5, 2.2, 1.8, 3.1, 2.5, 1.9, 2.8];
    }
  }

  Widget _buildTopicsBreakdown() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Topics Breakdown',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTopicProgressItem('AI & Machine Learning', 0.75, AppColors.primary),
            _buildTopicProgressItem('Data Science', 0.60, AppColors.accent),
            _buildTopicProgressItem('Programming', 0.45, AppColors.secondary),
            _buildTopicProgressItem('Business Strategy', 0.30, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicProgressItem(String topic, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                topic,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
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
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStreakCard(),
          const SizedBox(height: 20),
          _buildGoalsProgress(),
          const SizedBox(height: 20),
          _buildMilestones(),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    return ModernCard(
      backgroundColor: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent,
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
                    'Learning Streak',
                    style: AppTextStyles.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '15 days in a row! 🎉',
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personal best: 21 days',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '15',
              style: AppTextStyles.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsProgress() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals Progress',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildGoalItem('Complete 20 lessons this month', 15, 20),
            _buildGoalItem('Study 30 minutes daily', 7, 7),
            _buildGoalItem('Master AI Fundamentals', 8, 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, int current, int target) {
    final progress = current / target;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$current/$target',
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Milestones',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildMilestoneItem('🎯', 'First 100 Lessons', 'Completed yesterday'),
            _buildMilestoneItem('⭐', 'Rising Star Badge', 'Earned 3 days ago'),
            _buildMilestoneItem('🔥', 'Week Warrior', 'Earned 1 week ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(String emoji, String title, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
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

  Widget _buildHabitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHabitTracker(),
          const SizedBox(height: 20),
          _buildBestTimes(),
          const SizedBox(height: 20),
          _buildWeeklyPattern(),
        ],
      ),
    );
  }

  Widget _buildHabitTracker() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Tracker',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Calendar view for the past month
            _buildHabitCalendar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Text(
                    day,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: daysInMonth,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isCompleted = day % 3 != 0; // Mock data
            final isToday = day == now.day;
            
            return Container(
              decoration: BoxDecoration(
                color: isCompleted 
                    ? AppColors.success.withOpacity(0.2)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: isToday 
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 16,
                      )
                    : Text(
                        '$day',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBestTimes() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Best Learning Times',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimeSlot('Morning (6-9 AM)', 0.85, '🌅'),
            _buildTimeSlot('Afternoon (12-3 PM)', 0.65, '☀️'),
            _buildTimeSlot('Evening (6-9 PM)', 0.75, '🌆'),
            _buildTimeSlot('Night (9-12 PM)', 0.45, '🌙'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time, double effectiveness, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: effectiveness,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      effectiveness > 0.7 ? AppColors.success : AppColors.accent,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(effectiveness * 100).toInt()}%',
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: effectiveness > 0.7 ? AppColors.success : AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPattern() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Learning Pattern',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: _buildSimpleBarChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    final data = [45.0, 60.0, 50.0, 70.0, 55.0, 30.0, 25.0];
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final height = (value / maxValue) * 120;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${value.toInt()}',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 25,
              height: height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAIInsights(),
          const SizedBox(height: 20),
          _buildPersonalizedTips(),
          const SizedBox(height: 20),
          _buildComparisons(),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return ModernCard(
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              '🎯',
              'Optimal Learning Window',
              'You learn best between 8-10 AM. Consider scheduling important topics during this time.',
            ),
            _buildInsightItem(
              '📈',
              'Progress Acceleration',
              'You\'re learning 23% faster than last month! Keep up the momentum.',
            ),
            _buildInsightItem(
              '💡',
              'Topic Recommendation',
              'Based on your interests, you might enjoy "Neural Networks" next.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Personalized Tips',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('Take breaks every 25 minutes for better retention'),
            _buildTipItem('Review lessons within 24 hours to improve memory'),
            _buildTipItem('Try speed learning during your peak hours'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisons() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How You Compare',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonItem('Learning Frequency', 'Top 25%', 0.75),
            _buildComparisonItem('Session Length', 'Top 40%', 0.60),
            _buildComparisonItem('Topic Diversity', 'Top 15%', 0.85),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String metric, String rank, double percentile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                rank,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentile,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _shareStats() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing your amazing progress! 📊✨')),
    );
  }

  void _exportData() {
    // Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting your learning data... 📁')),
    );
  }
}

