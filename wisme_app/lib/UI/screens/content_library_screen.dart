import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
// TODO: Replace with AppRouter import
import '../widgets/modern_components.dart';

/// Premium content library with curated collections, trending topics, and AI recommendations
class ContentLibraryScreen extends StatefulWidget {
  const ContentLibraryScreen({super.key});

  @override
  State<ContentLibraryScreen> createState() => _ContentLibraryScreenState();
}

class _ContentLibraryScreenState extends State<ContentLibraryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All', 'AI & Tech', 'Business', 'Science', 'Personal Growth', 'Creative', 'Health'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Library'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterOptions,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _showBookmarks,
            icon: const Icon(Icons.bookmark),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchSection(),
            _buildCategoryFilter(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeaturedTab(),
                  _buildTrendingTab(),
                  _buildCollectionsTab(),
                  _buildBrowseTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics, courses, or creators...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.clear, color: Colors.grey),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: _performSearch,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.8), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI-powered recommendations based on your learning pattern',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Featured', icon: Icon(Icons.star, size: 18)),
          Tab(text: 'Trending', icon: Icon(Icons.trending_up, size: 18)),
          Tab(text: 'Collections', icon: Icon(Icons.collections, size: 18)),
          Tab(text: 'Browse', icon: Icon(Icons.explore, size: 18)),
        ],
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroContent(),
          const SizedBox(height: 24),
          _buildSectionHeader('Editor\'s Picks', 'Handpicked by our learning experts'),
          const SizedBox(height: 16),
          _buildContentGrid(_getFeaturedContent()),
          const SizedBox(height: 24),
          _buildSectionHeader('New & Noteworthy', 'Fresh content just added'),
          const SizedBox(height: 16),
          _buildHorizontalContentList(_getNewContent()),
        ],
      ),
    );
  }

  Widget _buildHeroContent() {
    return ModernCard(
      backgroundColor: AppColors.accent.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'FEATURED',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.auto_awesome, color: AppColors.accent),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'The Future of AI: What You Need to Know',
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A comprehensive guide to understanding artificial intelligence and its impact on society, business, and daily life.',
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildContentMetric(Icons.access_time, '45 min'),
                const SizedBox(width: 16),
                _buildContentMetric(Icons.star, '4.9'),
                const SizedBox(width: 16),
                _buildContentMetric(Icons.people, '12.5K learners'),
              ],
            ),
            const SizedBox(height: 20),
            ModernButton(
              text: 'Start Learning',
              onPressed: () => _startContent('ai-future-guide'),
              icon: Icons.play_arrow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTrendingHeatmap(),
          const SizedBox(height: 24),
          _buildSectionHeader('🔥 Hot Topics', 'Most popular this week'),
          const SizedBox(height: 16),
          _buildTrendingList(),
        ],
      ),
    );
  }

  Widget _buildTrendingHeatmap() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Now',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _getTrendingTopics().map((topic) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: topic['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: topic['color'].withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        topic['name'],
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: topic['color'],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${topic['growth']}%',
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: topic['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.trending_up, size: 16, color: topic['color']),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList() {
    return Column(
      children: _getTrendingContent().map((content) {
        return _buildTrendingItem(content);
      }).toList(),
    );
  }

  Widget _buildTrendingItem(Map<String, dynamic> content) {
    return ModernCard(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [content['color'], content['color'].withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(content['icon'], color: Colors.white, size: 24),
        ),
        title: Text(
          content['title'],
          style: AppTextStyles.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(content['description']),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text(
                        '+${content['growth']}%',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${content['learners']} learners',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _startContent(content['id']),
          icon: Icon(Icons.play_circle_filled, color: AppColors.primary, size: 32),
        ),
      ),
    );
  }

  Widget _buildCollectionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionHeader('Curated Collections', 'Expert-designed learning paths'),
          const SizedBox(height: 16),
          _buildCollectionsList(),
        ],
      ),
    );
  }

  Widget _buildCollectionsList() {
    return Column(
      children: _getCollections().map((collection) {
        return _buildCollectionCard(collection);
      }).toList(),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: collection['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${collection['lessons']} lessons',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Icon(
                      collection['icon'],
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection['title'],
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    collection['description'],
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        collection['duration'],
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        collection['rating'].toString(),
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
                          text: 'Start Collection',
                          onPressed: () => _startCollection(collection['id']),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _bookmarkCollection(collection['id']),
                        icon: Icon(
                          collection['bookmarked'] ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.accent,
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

  Widget _buildBrowseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTopicDirectory(),
          const SizedBox(height: 24),
          _buildRandomDiscovery(),
        ],
      ),
    );
  }

  Widget _buildTopicDirectory() {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by Topic',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _getTopicCategories().map((topic) {
                return _buildTopicCard(topic);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    return GestureDetector(
      onTap: () => _exploreCategory(topic['id']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [topic['color'], topic['color'].withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Icon(topic['icon'], color: Colors.white, size: 24),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${topic['count']} lessons',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
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

  Widget _buildRandomDiscovery() {
    return ModernCard(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.explore, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Feeling Adventurous?',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let AI surprise you with a random lesson tailored to your interests',
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ModernButton(
              text: 'Surprise Me!',
              onPressed: _discoverRandomContent,
              icon: Icons.shuffle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentGrid(List<Map<String, dynamic>> content) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) => _buildContentCard(content[index]),
    );
  }

  Widget _buildHorizontalContentList(List<Map<String, dynamic>> content) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: content.length,
        itemBuilder: (context, index) => Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: _buildContentCard(content[index]),
        ),
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [content['color'], content['color'].withValues(alpha: 0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(content['icon'], color: Colors.white, size: 32),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content['title'],
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content['duration'],
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  ModernButton(
                    text: 'Start',
                    onPressed: () => _startContent(content['id']),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Data methods
  List<Map<String, dynamic>> _getFeaturedContent() {
    return [
      {
        'id': 'ai-ethics',
        'title': 'AI Ethics Fundamentals',
        'duration': '25 min',
        'icon': Icons.gavel,
        'color': AppColors.primary,
      },
      {
        'id': 'quantum-computing',
        'title': 'Quantum Computing 101',
        'duration': '35 min',
        'icon': Icons.memory,
        'color': AppColors.accent,
      },
      {
        'id': 'climate-science',
        'title': 'Climate Science Basics',
        'duration': '20 min',
        'icon': Icons.eco,
        'color': AppColors.success,
      },
      {
        'id': 'design-thinking',
        'title': 'Design Thinking Process',
        'duration': '30 min',
        'icon': Icons.lightbulb,
        'color': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _getNewContent() {
    return [
      {
        'id': 'blockchain-basics',
        'title': 'Blockchain Explained',
        'duration': '15 min',
        'icon': Icons.link,
        'color': AppColors.secondary,
      },
      {
        'id': 'mindfulness',
        'title': 'Mindfulness Meditation',
        'duration': '10 min',
        'icon': Icons.self_improvement,
        'color': Colors.purple,
      },
      {
        'id': 'data-visualization',
        'title': 'Data Visualization',
        'duration': '40 min',
        'icon': Icons.bar_chart,
        'color': Colors.teal,
      },
    ];
  }

  List<Map<String, dynamic>> _getTrendingTopics() {
    return [
      {'name': 'AI Safety', 'growth': 156, 'color': AppColors.primary},
      {'name': 'Remote Work', 'growth': 89, 'color': AppColors.accent},
      {'name': 'Sustainability', 'growth': 67, 'color': AppColors.success},
      {'name': 'Mental Health', 'growth': 45, 'color': Colors.purple},
      {'name': 'Web3', 'growth': 134, 'color': Colors.orange},
    ];
  }

  List<Map<String, dynamic>> _getTrendingContent() {
    return [
      {
        'id': 'chatgpt-guide',
        'title': 'ChatGPT for Professionals',
        'description': 'Master AI tools for productivity',
        'growth': 234,
        'learners': '45.2K',
        'icon': Icons.chat,
        'color': AppColors.primary,
      },
      {
        'id': 'crypto-investing',
        'title': 'Cryptocurrency Basics',
        'description': 'Understanding digital currencies',
        'growth': 189,
        'learners': '32.1K',
        'icon': Icons.currency_bitcoin,
        'color': Colors.orange,
      },
      {
        'id': 'sustainable-living',
        'title': 'Sustainable Living Guide',
        'description': 'Eco-friendly lifestyle choices',
        'growth': 156,
        'learners': '28.7K',
        'icon': Icons.eco,
        'color': AppColors.success,
      },
    ];
  }

  List<Map<String, dynamic>> _getCollections() {
    return [
      {
        'id': 'ai-mastery',
        'title': 'AI Mastery Path',
        'description': 'Complete journey from AI basics to advanced applications',
        'lessons': 24,
        'duration': '12 hours',
        'rating': 4.9,
        'bookmarked': false,
        'gradient': [AppColors.primary, AppColors.accent],
        'icon': Icons.psychology,
      },
      {
        'id': 'entrepreneur-toolkit',
        'title': 'Entrepreneur\'s Toolkit',
        'description': 'Essential skills for starting and growing a business',
        'lessons': 18,
        'duration': '8 hours',
        'rating': 4.8,
        'bookmarked': true,
        'gradient': [Colors.orange, Colors.deepOrange],
        'icon': Icons.business,
      },
      {
        'id': 'creative-thinking',
        'title': 'Creative Thinking Lab',
        'description': 'Unlock your creative potential with proven techniques',
        'lessons': 15,
        'duration': '6 hours',
        'rating': 4.7,
        'bookmarked': false,
        'gradient': [Colors.purple, Colors.pink],
        'icon': Icons.palette,
      },
    ];
  }

  List<Map<String, dynamic>> _getTopicCategories() {
    return [
      {
        'id': 'technology',
        'name': 'Technology',
        'count': 156,
        'icon': Icons.computer,
        'color': AppColors.primary,
      },
      {
        'id': 'business',
        'name': 'Business',
        'count': 134,
        'icon': Icons.business_center,
        'color': Colors.orange,
      },
      {
        'id': 'science',
        'name': 'Science',
        'count': 98,
        'icon': Icons.science,
        'color': AppColors.success,
      },
      {
        'id': 'health',
        'name': 'Health',
        'count': 87,
        'icon': Icons.local_hospital,
        'color': Colors.red,
      },
      {
        'id': 'arts',
        'name': 'Arts',
        'count': 76,
        'icon': Icons.brush,
        'color': Colors.purple,
      },
      {
        'id': 'language',
        'name': 'Languages',
        'count': 65,
        'icon': Icons.translate,
        'color': Colors.teal,
      },
    ];
  }

  // Action methods
  void _performSearch(String query) {
    // Implement search functionality
    if (query.isNotEmpty) {
      // Trigger search
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Add filter options here
            ModernButton(
              text: 'Apply Filters',
              width: double.infinity,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarks() {
    Navigator.pushNamed(context, '/bookmarks');
  }

  void _startContent(String contentId) {
    Navigator.pushNamed(context, AppRoutes.topicAnalysis, arguments: {
      'searchQuery': contentId,
    });
  }

  void _startCollection(String collectionId) {
    Navigator.pushNamed(context, '/collection/$collectionId');
  }

  void _bookmarkCollection(String collectionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Collection bookmarked!')),
    );
  }

  void _exploreCategory(String categoryId) {
    Navigator.pushNamed(context, '/category/$categoryId');
  }

  void _discoverRandomContent() {
    final randomTopics = ['Quantum Physics', 'Behavioral Psychology', 'Renewable Energy', 'Digital Art'];
    final randomTopic = (randomTopics..shuffle()).first;
    
    Navigator.pushNamed(context, AppRoutes.topicAnalysis, arguments: {
      'searchQuery': randomTopic,
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Discovering: $randomTopic! 🎲')),
    );
  }
}
