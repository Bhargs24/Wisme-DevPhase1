import '../../core/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [];
  final List<TopicAnalysis> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      setState(() {
        _searchHistory.clear();
        _searchHistory.addAll(history);
      });
    } catch (e) {
      // Ignore errors loading search history
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('search_history', _searchHistory);
    } catch (e) {
      // Ignore errors saving search history
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Add to search history
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
        _saveSearchHistory();
      }

      // Track search analytics
      AnalyticsService.trackEvent('search_performed', {
        'query': query,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Use content matching service to find relevant topics
      final lessonProvider = context.read<LessonProvider>();
      final results = await lessonProvider.analyzeTopicIntent(query);
      
      setState(() {
        _searchResults.clear();
        _searchResults.add(results);
        _isSearching = false;
      });

    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
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
        title: const Text('Search'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics, lessons, or content...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                if (value.length > 2) {
                  _performSearch(value);
                } else if (value.isEmpty) {
                  setState(() {
                    _searchResults.clear();
                  });
                }
              },
              onSubmitted: (value) {
                _performSearch(value);
              },
            ),
          ),

          // Search results or history
          Expanded(
            child: _searchResults.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Recent Searches',
          style: AppTextStyles.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (_searchHistory.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Start searching to find topics and lessons',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        else
          ...(_searchHistory.map((query) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(query),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _searchHistory.remove(query);
                    });
                  },
                ),
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              ))),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(result.originalQuery),
            subtitle: Text(
              '${result.detectedCategory} • ${(result.confidenceScore * 100).toInt()}% match',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to topic analysis
              Navigator.pushNamed(
                context,
                '/topic-analysis',
                arguments: {
                  'searchQuery': result.originalQuery,
                  'topic': result.originalQuery,
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}


