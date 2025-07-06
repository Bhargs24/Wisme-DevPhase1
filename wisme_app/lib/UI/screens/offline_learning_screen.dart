import '../../core/exports.dart';

class OfflineLearningScreen extends StatefulWidget {
  const OfflineLearningScreen({super.key});

  @override
  State<OfflineLearningScreen> createState() => _OfflineLearningScreenState();
}

class _OfflineLearningScreenState extends State<OfflineLearningScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final double _storageUsed = 2.3; // GB
  final double _storageLimit = 5.0; // GB

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: AppBar(
        title: const Text('Offline Learning'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showStorageSettings,
            icon: const Icon(Icons.storage),
          ),
          IconButton(
            onPressed: _showDownloadSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStorageOverview(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDownloadedTab(),
                  _buildDownloadQueueTab(),
                  _buildRecommendationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageOverview() {
    final storagePercentage = _storageUsed / _storageLimit;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Usage',
                      style: AppTextStyles.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_storageUsed.toStringAsFixed(1)} GB of ${_storageLimit.toStringAsFixed(1)} GB used',
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(storagePercentage * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: storagePercentage,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                storagePercentage > 0.8 ? Colors.orange : Colors.white,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getDownloadedLessonsCount()} lessons downloaded',
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              GestureDetector(
                onTap: _optimizeStorage,
                child: Row(
                  children: [
                    Icon(Icons.auto_fix_high, color: Colors.white.withOpacity(0.8), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Optimize',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          Tab(text: 'Downloaded', icon: Icon(Icons.download_done, size: 18)),
          Tab(text: 'Queue', icon: Icon(Icons.queue, size: 18)),
          Tab(text: 'Suggestions', icon: Icon(Icons.recommend, size: 18)),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDownloadedTab() {
    return RefreshIndicator(
      onRefresh: _refreshDownloaded,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDownloadedStats(),
          const SizedBox(height: 20),
          _buildSectionHeader('Recently Downloaded'),
          const SizedBox(height: 12),
          ..._getDownloadedLessons().map((lesson) => _buildDownloadedItem(lesson)),
          const SizedBox(height: 20),
          _buildSectionHeader('Collections'),
          const SizedBox(height: 12),
          ..._getDownloadedCollections().map((collection) => _buildCollectionItem(collection)),
        ],
      ),
    );
  }

  Widget _buildDownloadedStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.download_done,
            title: 'Downloaded',
            value: '${_getDownloadedLessonsCount()}',
            subtitle: 'lessons',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.offline_bolt,
            title: 'Offline Time',
            value: '${_getOfflineTime()}h',
            subtitle: 'available',
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildDownloadedItem(Map<String, dynamic> lesson) {
    return ModernCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: lesson['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.download_done,
            color: lesson['color'],
            size: 24,
          ),
        ),
        title: Text(
          lesson['title'],
          style: AppTextStyles.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(lesson['duration']),
                const SizedBox(width: 16),
                Icon(Icons.storage, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(lesson['size']),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Downloaded ${lesson['downloadDate']}',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('Play Offline'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: AppColors.accent),
                  const SizedBox(width: 8),
                  const Text('Share'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleLessonAction(value, lesson),
        ),
      ),
    );
  }

  Widget _buildCollectionItem(Map<String, dynamic> collection) {
    final progress = collection['downloadedLessons'] / collection['totalLessons'];
    
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: collection['gradient'],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    collection['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collection['title'],
                        style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${collection['downloadedLessons']}/${collection['totalLessons']} lessons',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _manageCollection(collection['id']),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% downloaded',
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadQueueTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildQueueControls(),
        const SizedBox(height: 20),
        _buildSectionHeader('Download Queue'),
        const SizedBox(height: 12),
        ..._getDownloadQueue().map((item) => _buildQueueItem(item)),
        const SizedBox(height: 20),
        _buildQuickDownloads(),
      ],
    );
  }

  Widget _buildQueueControls() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.queue, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Download Queue',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_getQueueCount()} items',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Pause All',
                    onPressed: _pauseAllDownloads,
                    icon: Icons.pause,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: 'Resume All',
                    onPressed: _resumeAllDownloads,
                    icon: Icons.play_arrow,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> item) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getStatusIcon(item['status']),
                    color: item['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${item['size']} • ${item['quality']} quality',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleDownload(item['id']),
                  icon: Icon(
                    item['status'] == 'downloading' ? Icons.pause : Icons.play_arrow,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeFromQueue(item['id']),
                  icon: Icon(Icons.close, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (item['status'] == 'downloading' || item['status'] == 'paused') ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: item['progress'],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(item['color']),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(item['progress'] * 100).toInt()}% complete',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: item['color'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item['status'] == 'downloading')
                    Text(
                      '${item['speed']} MB/s',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDownloads() {
    return ModernCard(
      backgroundColor: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Quick Downloads',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickDownloadChip('Today\'s Recommendations', Icons.today),
                _buildQuickDownloadChip('Trending Topics', Icons.trending_up),
                _buildQuickDownloadChip('Your Favorites', Icons.favorite),
                _buildQuickDownloadChip('Continue Learning', Icons.play_circle),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDownloadChip(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _downloadCategory(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSmartRecommendations(),
        const SizedBox(height: 20),
        _buildOfflineOptimization(),
        const SizedBox(height: 20),
        _buildDownloadScheduler(),
      ],
    );
  }

  Widget _buildSmartRecommendations() {
    return ModernCard(
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
                  'Smart Download Suggestions',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Based on your learning pattern and upcoming travel',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ..._getSmartRecommendations().map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> rec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rec['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rec['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(rec['icon'], color: rec['color'], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec['title'],
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  rec['reason'],
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ModernButton(
            text: 'Download',
            onPressed: () => _downloadRecommendation(rec['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineOptimization() {
    return ModernCard(
      backgroundColor: AppColors.success.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Storage Optimization',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOptimizationTip(
              'Auto-delete watched content after 30 days',
              'Save 1.2 GB',
              true,
            ),
            _buildOptimizationTip(
              'Lower quality for background listening',
              'Save 40% space',
              false,
            ),
            _buildOptimizationTip(
              'Priority download for favorites',
              'Better experience',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationTip(String title, String benefit, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Switch(
            value: enabled,
            onChanged: (value) => _toggleOptimization(title, value),
            activeColor: AppColors.success,
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
                  benefit,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadScheduler() {
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
                  'Download Scheduler',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Automatically download new content during off-peak hours',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildScheduleOption('Daily at 2:00 AM', 'WiFi only', true),
            _buildScheduleOption('When charging', 'Any connection', false),
            _buildScheduleOption('Manual only', 'User controlled', false),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(String title, String subtitle, bool selected) {
    return GestureDetector(
      onTap: () => _selectScheduleOption(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : Colors.grey,
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
                      color: selected ? AppColors.primary : null,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Data methods
  int _getDownloadedLessonsCount() => 23;
  int _getOfflineTime() => 15;
  int _getQueueCount() => 5;

  List<Map<String, dynamic>> _getDownloadedLessons() {
    return [
      {
        'id': '1',
        'title': 'Introduction to Machine Learning',
        'duration': '45 min',
        'size': '120 MB',
        'downloadDate': '2 days ago',
        'color': AppColors.primary,
      },
      {
        'id': '2',
        'title': 'Sustainable Business Practices',
        'duration': '30 min',
        'size': '85 MB',
        'downloadDate': '1 week ago',
        'color': AppColors.success,
      },
      {
        'id': '3',
        'title': 'Creative Problem Solving',
        'duration': '25 min',
        'size': '95 MB',
        'downloadDate': '3 days ago',
        'color': Colors.purple,
      },
    ];
  }

  List<Map<String, dynamic>> _getDownloadedCollections() {
    return [
      {
        'id': 'ai-basics',
        'title': 'AI Fundamentals',
        'downloadedLessons': 8,
        'totalLessons': 12,
        'gradient': [AppColors.primary, AppColors.accent],
        'icon': Icons.psychology,
      },
      {
        'id': 'business-skills',
        'title': 'Business Skills',
        'downloadedLessons': 5,
        'totalLessons': 8,
        'gradient': [Colors.orange, Colors.deepOrange],
        'icon': Icons.business,
      },
    ];
  }

  List<Map<String, dynamic>> _getDownloadQueue() {
    return [
      {
        'id': '1',
        'title': 'Advanced Neural Networks',
        'size': '150 MB',
        'quality': 'High',
        'status': 'downloading',
        'progress': 0.65,
        'speed': 2.3,
        'color': AppColors.primary,
      },
      {
        'id': '2',
        'title': 'Data Visualization Techniques',
        'size': '95 MB',
        'quality': 'Medium',
        'status': 'paused',
        'progress': 0.25,
        'speed': 0.0,
        'color': AppColors.accent,
      },
      {
        'id': '3',
        'title': 'Leadership in Remote Teams',
        'size': '110 MB',
        'quality': 'High',
        'status': 'queued',
        'progress': 0.0,
        'speed': 0.0,
        'color': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _getSmartRecommendations() {
    return [
      {
        'id': 'flight-rec',
        'title': 'Perfect for your upcoming flight',
        'reason': '3-hour journey next Tuesday',
        'icon': Icons.flight,
        'color': AppColors.primary,
      },
      {
        'id': 'commute-rec',
        'title': 'Commute-friendly episodes',
        'reason': 'Short lessons for daily travel',
        'icon': Icons.train,
        'color': AppColors.accent,
      },
      {
        'id': 'weekend-rec',
        'title': 'Weekend deep dive',
        'reason': 'Extended content for free time',
        'icon': Icons.weekend,
        'color': AppColors.success,
      },
    ];
  }

  // Action methods
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'downloading':
        return Icons.download;
      case 'paused':
        return Icons.pause;
      case 'queued':
        return Icons.queue;
      case 'completed':
        return Icons.download_done;
      default:
        return Icons.help;
    }
  }

  Future<void> _refreshDownloaded() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh downloaded content
    });
  }

  void _optimizeStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Optimize Storage'),
        content: const Text('This will remove old downloads and optimize storage usage. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Optimize',
            onPressed: () {
              Navigator.pop(context);
              _performOptimization();
            },
          ),
        ],
      ),
    );
  }

  void _performOptimization() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage optimized! Freed up 800 MB')),
    );
  }

  void _showStorageSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Storage Settings',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Add storage settings here
            ModernButton(
              text: 'Save Settings',
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download Settings',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Add download settings here
            ModernButton(
              text: 'Save Settings',
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLessonAction(String action, Map<String, dynamic> lesson) {
    switch (action) {
      case 'play':
        // Navigate to lesson player
        break;
      case 'share':
        // Share lesson
        break;
      case 'delete':
        _deleteLessonDownload(lesson['id']);
        break;
    }
  }

  void _deleteLessonDownload(String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download removed!')),
    );
  }

  void _manageCollection(String collectionId) {
    // Navigate to collection management
  }

  void _pauseAllDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All downloads paused')),
    );
  }

  void _resumeAllDownloads() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloads resumed')),
    );
  }

  void _toggleDownload(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download status toggled')),
    );
  }

  void _removeFromQueue(String itemId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from queue')),
    );
  }

  void _downloadCategory(String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading $category...')),
    );
  }

  void _downloadRecommendation(String recId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to download queue!')),
    );
  }

  void _toggleOptimization(String option, bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${value ? 'Enabled' : 'Disabled'} $option')),
    );
  }

  void _selectScheduleOption(String option) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $option')),
    );
  }
}

