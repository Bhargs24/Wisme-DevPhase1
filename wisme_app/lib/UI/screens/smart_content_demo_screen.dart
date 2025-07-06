import '../../core/exports.dart';
class SmartContentDemoScreen extends StatefulWidget {
  const SmartContentDemoScreen({super.key});

  @override
  State<SmartContentDemoScreen> createState() => _SmartContentDemoScreenState();
}

class _SmartContentDemoScreenState extends State<SmartContentDemoScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedCategory = 'Technology';
  String _selectedLevel = 'Intermediate';
  bool _forceGeneration = false;
  
  final List<String> _categories = [
    'Technology',
    'Business & Finance',
    'Psychology & Mind',
    'Science & Nature',
    'Creativity & Design',
    'Self-Growth',
  ];
  
  final List<String> _levels = [
    'Beginner',
    'Intermediate', 
    'Advanced',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🧠 Smart Content Engine'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<LessonProvider>(
        builder: (context, lessonProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 20),
                _buildInputSection(lessonProvider),
                const SizedBox(height: 20),
                _buildMatchingResultsSection(lessonProvider),
                const SizedBox(height: 20),
                _buildRecommendationsSection(lessonProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Intelligent Content Matching',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ).copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This demo shows how Wisme intelligently reuses existing content based on hashtags and user history, saving costs and improving personalization.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildFeatureChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChips() {
    final features = [
      '🏷️ Smart Hashtags',
      '🔍 Content Matching',
      '📊 User History',
      '🚫 No Repeats',
      '💰 Cost Optimization',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) => Chip(
        label: Text(feature, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.primary.withValues(alpha:0.1),
        labelStyle: TextStyle(color: AppColors.primary),
      )).toList(),
    );
  }

  Widget _buildInputSection(LessonProvider lessonProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Generate Smart Content',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Topic Input
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Learning Topic',
                hintText: 'e.g., "Cryptocurrency investing for beginners"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lightbulb_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Level Dropdown
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: InputDecoration(
                labelText: 'Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.trending_up),
              ),
              items: _levels.map((level) => DropdownMenuItem(
                value: level,
                child: Text(level),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Force Generation Toggle
            CheckboxListTile(
              title: const Text('Force New Generation'),
              subtitle: const Text('Skip content matching and generate new content'),
              value: _forceGeneration,
              onChanged: (value) {
                setState(() {
                  _forceGeneration = value ?? false;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: lessonProvider.isLoading ? null : () => _generateContent(lessonProvider),
                icon: lessonProvider.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(lessonProvider.isLoading 
                    ? 'Generating...' 
                    : 'Generate Smart Content'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingResultsSection(LessonProvider lessonProvider) {
    if (lessonProvider.contentBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Available Content',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...lessonProvider.contentBlocks.take(3).map((block) => _buildContentBlockCard(block)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBlockCard(ContentBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  block.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  block.knowledgeLevel.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Category: ${block.category}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${block.duration.inMinutes}min',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (block.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              children: block.tags.take(3).map((tag) => 
                Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 10)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(LessonProvider lessonProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.recommend, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Smart Recommendations',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => _getRecommendations(lessonProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Get Personalized Recommendations'),
            ),
            
            const SizedBox(height: 16),
            
            // Show recommendations if available
            // This would show actual recommendation results
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📊 Recommendations will appear here based on:\n'
                '• User listening history\n'
                '• Content ratings\n'
                '• Hashtag preferences\n'
                '• Learning patterns\n'
                '• Freshness optimization',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateContent(LessonProvider lessonProvider) async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a learning topic')),
      );
      return;
    }

    try {
      // Use the available method to analyze topic intent
      await lessonProvider.analyzeTopicIntent(_topicController.text.trim());
      
      // Load content blocks based on the topic
      await lessonProvider.loadContentBlocks();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Content loaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _getRecommendations(LessonProvider lessonProvider) async {
    try {
      // Use available methods to get content based on category
      if (_selectedCategory.isNotEmpty) {
        await lessonProvider.loadContentBlocksByCategory(_selectedCategory);
      } else {
        await lessonProvider.loadContentBlocks();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Content recommendations updated!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting recommendations: $e')),
      );
    }
  }
}


