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
        backgroundColor: AppColors.primary.withOpacity(0.1),
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
                onPressed: lessonProvider.isGenerating ? null : () => _generateContent(lessonProvider),
                icon: lessonProvider.isGenerating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(lessonProvider.isGenerating 
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
    if (lessonProvider.lastMatches.isEmpty) {
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
                  'Content Matching Results',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            ...lessonProvider.lastMatches.take(3).map((match) => _buildMatchCard(match)),
            
            if (lessonProvider.currentAssembly != null) ...[
              const SizedBox(height: 16),
              _buildAssemblyCard(lessonProvider.currentAssembly!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMatchCard(ContentMatch match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: match.isExactMatch ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Content ID: ${match.contentId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (match.isExactMatch)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EXACT MATCH',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Score indicators
          Row(
            children: [
              _buildScoreChip('Similarity', match.similarityScore, Colors.blue),
              const SizedBox(width: 8),
              _buildScoreChip('Semantic', match.semanticScore, Colors.purple),
              const SizedBox(width: 8),
              _buildScoreChip('Total', match.totalScore, Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          
          // Matching tags
          if (match.matchingTags.isNotEmpty) ...[
            const Text('Matching Tags:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: match.matchingTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(fontSize: 10, color: AppColors.primary),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${(score * 100).toInt()}%',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAssemblyCard(ContentAssembly assembly) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_circle, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(
                'Content Assembly',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Type: ${assembly.assemblyType.toUpperCase()}'),
          Text('Content IDs: ${assembly.contentIds.join(", ")}'),
          Text('Duration: ${assembly.estimatedDuration.inMinutes} minutes'),
          Text('Confidence: ${(assembly.confidenceScore * 100).toInt()}%'),
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
      await lessonProvider.generateSmartContentBlock(
        userId: 'demo_user_123', // In real app, get from auth
        topic: _topicController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel.toLowerCase(),
        contentType: 'concept',
        forceGeneration: _forceGeneration,
      );

      if (lessonProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Smart content generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _getRecommendations(LessonProvider lessonProvider) async {
    try {
      await lessonProvider.getSmartRecommendations(
        userId: 'demo_user_123',
        maxResults: 5,
        preferredCategories: [_selectedCategory],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📊 Recommendations updated!'),
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

