import '../../core/exports.dart';
class LearningDataScreen extends StatefulWidget {
  const LearningDataScreen({super.key});

  @override
  State<LearningDataScreen> createState() => _LearningDataScreenState();
}

class _LearningDataScreenState extends State<LearningDataScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _learningStats = {};

  @override
  void initState() {
    super.initState();
    _loadLearningData();
  }

  Future<void> _loadLearningData() async {
    try {
      final userProvider = context.read<UserProvider>();
      
      // Get comprehensive learning statistics
      final stats = await AnalyticsService.getUserLearningStats(
        userProvider.currentUser?.id ?? 'anonymous'
      );
      
      setState(() {
        _learningStats = stats;
        _isLoading = false;
      });
      
      // Track analytics
      AnalyticsService.trackEvent('learning_data_viewed', {
        'user_id': userProvider.currentUser?.id ?? 'anonymous',
        'total_lessons': stats['totalLessons'] ?? 0,
        'total_time': stats['totalTimeMinutes'] ?? 0,
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load learning data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Data'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLearningData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(),
                    const SizedBox(height: 24),
                    _buildProgressChart(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    _buildTopics(),
                    const SizedBox(height: 24),
                    _buildAchievements(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Overview',
          style: AppTextStyles.textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Lessons',
                '${_learningStats['totalLessons'] ?? 0}',
                Icons.book,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Learning Time',
                '${_learningStats['totalTimeMinutes'] ?? 0}m',
                Icons.timer,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Streak Days',
                '${_learningStats['streakDays'] ?? 0}',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Completion Rate',
                '${_learningStats['completionRate'] ?? 0}%',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: const Center(
              child: Text(
                'Progress chart will be implemented with charts_flutter package',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentActivities = _learningStats['recentActivities'] as List? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (recentActivities.isEmpty)
            const Center(
              child: Text(
                'No recent activity',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...recentActivities.take(5).map<Widget>((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:                      Text(
                        activity['description'] ?? 'Unknown activity',
                        style: AppTextStyles.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      activity['time'] ?? '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopics() {
    final topics = _learningStats['topicProgress'] as Map? ?? {};
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Topic Progress',
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (topics.isEmpty)
            const Center(
              child: Text(
                'No topic progress yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...topics.entries.map<Widget>((entry) {
              final progress = (entry.value as num?)?.toDouble() ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: AppTextStyles.textTheme.bodyMedium,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _learningStats['achievements'] as List? ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (achievements.isEmpty)
            const Center(
              child: Text(
                'No achievements yet - keep learning!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements.map<Widget>((achievement) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha:0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        achievement['name'] ?? 'Achievement',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}


