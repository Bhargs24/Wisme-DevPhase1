import '../../core/exports.dart';

class AchievementsGalleryScreen extends StatefulWidget {
  const AchievementsGalleryScreen({super.key});

  @override
  State<AchievementsGalleryScreen> createState() => _AchievementsGalleryScreenState();
}

class _AchievementsGalleryScreenState extends State<AchievementsGalleryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String selectedCategory = 'all';

  final List<String> categories = ['all', 'learning', 'streaks', 'social', 'milestones'];

  final List<Map<String, dynamic>> achievements = [
    // Learning Achievements
    {
      'id': 'first_lesson',
      'title': 'First Steps',
      'description': 'Complete your first lesson',
      'icon': '🎯',
      'category': 'learning',
      'unlocked': true,
      'unlockedAt': '2024-01-15',
      'rarity': 'common',
      'xp': 50,
    },
    {
      'id': 'speed_learner',
      'title': 'Speed Learner',
      'description': 'Complete 5 lessons in one day',
      'icon': '⚡',
      'category': 'learning',
      'unlocked': true,
      'unlockedAt': '2024-01-20',
      'rarity': 'rare',
      'xp': 200,
    },
    {
      'id': 'knowledge_seeker',
      'title': 'Knowledge Seeker',
      'description': 'Complete lessons in 3 different categories',
      'icon': '🔍',
      'category': 'learning',
      'unlocked': false,
      'progress': 2,
      'total': 3,
      'rarity': 'uncommon',
      'xp': 150,
    },
    // Streak Achievements
    {
      'id': 'on_fire',
      'title': 'On Fire!',
      'description': 'Maintain a 7-day learning streak',
      'icon': '🔥',
      'category': 'streaks',
      'unlocked': true,
      'unlockedAt': '2024-01-22',
      'rarity': 'uncommon',
      'xp': 300,
    },
    {
      'id': 'unstoppable',
      'title': 'Unstoppable',
      'description': 'Maintain a 30-day learning streak',
      'icon': '🚀',
      'category': 'streaks',
      'unlocked': false,
      'progress': 7,
      'total': 30,
      'rarity': 'epic',
      'xp': 1000,
    },
    // Social Achievements
    {
      'id': 'social_butterfly',
      'title': 'Social Butterfly',
      'description': 'Connect with 10 friends',
      'icon': '🦋',
      'category': 'social',
      'unlocked': false,
      'progress': 2,
      'total': 10,
      'rarity': 'rare',
      'xp': 250,
    },
    {
      'id': 'top_ten',
      'title': 'Top Ten',
      'description': 'Reach top 10 on weekly leaderboard',
      'icon': '🏆',
      'category': 'social',
      'unlocked': true,
      'unlockedAt': '2024-01-25',
      'rarity': 'epic',
      'xp': 500,
    },
    // Milestone Achievements
    {
      'id': 'hundred_club',
      'title': 'Hundred Club',
      'description': 'Complete 100 lessons',
      'icon': '💯',
      'category': 'milestones',
      'unlocked': false,
      'progress': 23,
      'total': 100,
      'rarity': 'legendary',
      'xp': 2000,
    },
    {
      'id': 'time_master',
      'title': 'Time Master',
      'description': 'Spend 50 hours learning',
      'icon': '⏰',
      'category': 'milestones',
      'unlocked': false,
      'progress': 12.5,
      'total': 50,
      'rarity': 'epic',
      'xp': 1500,
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
              _buildStats(),
              _buildCategoryFilter(),
              Expanded(
                child: _buildAchievementGrid(),
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
                  'Achievements',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Your learning milestones',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showAchievementInfo(),
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final unlockedCount = achievements.where((a) => a['unlocked'] == true).length;
    final totalXP = achievements
        .where((a) => a['unlocked'] == true)
        .fold<int>(0, (sum, a) => sum + (a['xp'] as int));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ModernCard(
          backgroundColor: AppColors.primary.withValues(alpha:0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🏆', '$unlockedCount/${achievements.length}', 'Unlocked'),
              _buildStatItem('⭐', '$totalXP XP', 'From Achievements'),
              _buildStatItem('🎯', '${(unlockedCount / achievements.length * 100).toInt()}%', 'Completion'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            final displayName = category == 'all' ? 'All' : 
                               category[0].toUpperCase() + category.substring(1);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  displayName,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementGrid() {
    final filteredAchievements = selectedCategory == 'all' 
        ? achievements 
        : achievements.where((a) => a['category'] == selectedCategory).toList();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = filteredAchievements[index];
        return _buildAchievementCard(achievement, index);
      },
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, int index) {
    final isUnlocked = achievement['unlocked'] ?? false;
    final rarity = achievement['rarity'] as String;
    final rarityColor = _getRarityColor(rarity);
    final delay = index * 0.1;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
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
            child: GestureDetector(
              onTap: () => _showAchievementDetail(achievement),
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnlocked ? rarityColor : Colors.grey[300]!,
                    width: isUnlocked ? 2 : 1,
                  ),
                  boxShadow: isUnlocked ? [
                    BoxShadow(
                      color: rarityColor.withValues(alpha:0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : [],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Rarity indicator
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            rarity.toUpperCase(),
                            style: AppTextStyles.textTheme.bodySmall?.copyWith(
                              color: rarityColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnlocked 
                              ? rarityColor.withValues(alpha:0.1) 
                              : Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            achievement['icon'],
                            style: TextStyle(
                              fontSize: 32,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        achievement['title'],
                        style: AppTextStyles.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        achievement['description'],
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Progress or XP
                      if (!isUnlocked && achievement['progress'] != null)
                        _buildProgressBar(achievement)
                      else if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${achievement['xp']} XP',
                            style: AppTextStyles.textTheme.bodySmall?.copyWith(
                              color: rarityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> achievement) {
    final progress = achievement['progress'] as num;
    final total = achievement['total'] as num;
    final percentage = progress / total;

    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getRarityColor(achievement['rarity'])),
        ),
        const SizedBox(height: 4),
        Text(
          '$progress / $total',
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey[600]!;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey[600]!;
    }
  }

  void _showAchievementDetail(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] ?? false;
    final rarity = achievement['rarity'] as String;
    final rarityColor = _getRarityColor(rarity);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: rarityColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rarityColor.withValues(alpha:0.1),
                  border: Border.all(color: rarityColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    achievement['icon'],
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                achievement['title'],
                style: AppTextStyles.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rarityColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Rarity
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rarityColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${rarity.toUpperCase()} ACHIEVEMENT',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: rarityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                achievement['description'],
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Status
              if (isUnlocked) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Unlocked on ${achievement['unlockedAt']}',
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Earned ${achievement['xp']} XP',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: rarityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else if (achievement['progress'] != null) ...[
                _buildProgressBar(achievement),
                const SizedBox(height: 8),
                Text(
                  'Keep going to unlock this achievement!',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ModernButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Achievement System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('🎯', 'Complete challenges to unlock achievements'),
            _buildInfoRow('⭐', 'Earn XP for each achievement unlocked'),
            _buildInfoRow('🏆', 'Rarity determines XP value'),
            _buildInfoRow('📈', 'Track your progress in real-time'),
            _buildInfoRow('🎉', 'Share your accomplishments with friends'),
          ],
        ),
        actions: [
          ModernButton(
            text: 'Got it!',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}


