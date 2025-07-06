import '../../core/exports.dart';

class SocialLeaderboardScreen extends StatefulWidget {
  const SocialLeaderboardScreen({super.key});

  @override
  State<SocialLeaderboardScreen> createState() => _SocialLeaderboardScreenState();
}

class _SocialLeaderboardScreenState extends State<SocialLeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> weeklyLeaders = [
    {
      'rank': 1,
      'name': 'Alex Chen',
      'avatar': '👨‍💻',
      'score': 2450,
      'streak': 15,
      'badge': '🏆',
      'color': Colors.amber,
    },
    {
      'rank': 2,
      'name': 'Sarah Johnson',
      'avatar': '👩‍🎨',
      'score': 2380,
      'streak': 12,
      'badge': '🥈',
      'color': Colors.grey,
    },
    {
      'rank': 3,
      'name': 'Mike Rodriguez',
      'avatar': '👨‍🚀',
      'score': 2310,
      'streak': 10,
      'badge': '🥉',
      'color': Colors.brown,
    },
    {
      'rank': 4,
      'name': 'Emma Davis',
      'avatar': '👩‍💼',
      'score': 2180,
      'streak': 8,
      'badge': '⭐',
      'color': AppColors.primary,
    },
    {
      'rank': 5,
      'name': 'You',
      'avatar': '😊',
      'score': 2150,
      'streak': 7,
      'badge': '🔥',
      'color': AppColors.accent,
      'isCurrentUser': true,
    },
  ];

  final List<Map<String, dynamic>> globalLeaders = [
    {
      'rank': 1,
      'name': 'Jennifer Liu',
      'avatar': '👩‍🔬',
      'score': 15420,
      'streak': 45,
      'badge': '🌟',
      'color': Colors.purple,
      'level': 'AI Master',
    },
    {
      'rank': 2,
      'name': 'David Thompson',
      'avatar': '👨‍🎓',
      'score': 14850,
      'streak': 38,
      'badge': '💎',
      'color': Colors.blue,
      'level': 'Tech Guru',
    },
    {
      'rank': 3,
      'name': 'Lisa Park',
      'avatar': '👩‍💻',
      'score': 14200,
      'streak': 32,
      'badge': '🚀',
      'color': Colors.green,
      'level': 'Innovation Leader',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
              _buildUserStats(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWeeklyLeaderboard(),
                    _buildGlobalLeaderboard(),
                    _buildFriendsLeaderboard(),
                  ],
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
                  'Leaderboard',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Compete with learners worldwide',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showLeaderboardInfo(),
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ModernCard(
          backgroundColor: AppColors.primary.withValues(alpha:0.1),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha:0.2),
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const Center(
                      child: Text('😊', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Ranking',
                          style: AppTextStyles.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Weekly: #5 • Global: #127',
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '2,150 XP',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('🔥', '7 days', 'Current Streak'),
                  _buildStatItem('📚', '23', 'Lessons Done'),
                  _buildStatItem('⏱️', '4.2h', 'This Week'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.textTheme.titleSmall?.copyWith(
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Weekly'),
          Tab(text: 'Global'),
          Tab(text: 'Friends'),
        ],
      ),
    );
  }

  Widget _buildWeeklyLeaderboard() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: weeklyLeaders.length,
      itemBuilder: (context, index) {
        final leader = weeklyLeaders[index];
        return _buildLeaderboardItem(leader, index);
      },
    );
  }

  Widget _buildGlobalLeaderboard() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: globalLeaders.length,
      itemBuilder: (context, index) {
        final leader = globalLeaders[index];
        return _buildLeaderboardItem(leader, index, isGlobal: true);
      },
    );
  }

  Widget _buildFriendsLeaderboard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Connect with Friends',
            style: AppTextStyles.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite friends to compete and learn together!',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ModernButton(
            text: 'Invite Friends',
            onPressed: () => _inviteFriends(),
            icon: Icons.share,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> leader, int index, {bool isGlobal = false}) {
    final isCurrentUser = leader['isCurrentUser'] ?? false;
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
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColors.accent.withValues(alpha:0.1) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isCurrentUser 
                    ? Border.all(color: AppColors.accent, width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: leader['color'].withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: leader['rank'] <= 3 
                            ? Text(
                                leader['badge'],
                                style: const TextStyle(fontSize: 20),
                              )
                            : Text(
                                '#${leader['rank']}',
                                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: leader['color'],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: leader['color'].withValues(alpha:0.1),
                        border: Border.all(color: leader['color'], width: 2),
                      ),
                      child: Center(
                        child: Text(
                          leader['avatar'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leader['name'],
                            style: AppTextStyles.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser ? AppColors.accent : Colors.black87,
                            ),
                          ),
                          if (isGlobal && leader['level'] != null)
                            Text(
                              leader['level'],
                              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                color: leader['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${leader['streak']} days',
                                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Score
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${leader['score']} XP',
                          style: AppTextStyles.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: leader['color'],
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'YOU',
                              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLeaderboardInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('How Leaderboards Work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('🏆', 'Weekly: Resets every Monday'),
            _buildInfoRow('🌍', 'Global: All-time rankings'),
            _buildInfoRow('⭐', 'XP earned from completing lessons'),
            _buildInfoRow('🔥', 'Streaks boost your score'),
            _buildInfoRow('👥', 'Friends: Connect to compete'),
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

  void _inviteFriends() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invite Friends to Wisme',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Learning is more fun with friends! Invite them to join and compete on the leaderboard.',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Share Link',
                    onPressed: () {},
                    icon: Icons.link,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Social Media',
                    onPressed: () {},
                    icon: Icons.share,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


