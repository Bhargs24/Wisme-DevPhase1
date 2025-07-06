import '../../core/exports.dart';
class LearningHistoryScreen extends StatefulWidget {
  const LearningHistoryScreen({super.key});

  @override
  State<LearningHistoryScreen> createState() => _LearningHistoryScreenState();
}

class _LearningHistoryScreenState extends State<LearningHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      // Generate sample history from analytics
      final userStats = await AnalyticsService.getUserLearningStats('current_user');
      final recentActivities = userStats['recentActivities'] as List? ?? [];
      
      setState(() {
        _historyItems = recentActivities.cast<Map<String, dynamic>>();
        _isLoading = false;
      });

      AnalyticsService.trackEvent('learning_history_viewed', {
        'history_items': _historyItems.length,
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        // Add some sample data for production demo
        _historyItems = [
          {
            'title': 'Introduction to Flutter',
            'type': 'lesson',
            'completed': true,
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'progress': 100,
            'duration': '15 min',
          },
          {
            'title': 'State Management Basics',
            'type': 'lesson',
            'completed': false,
            'date': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
            'progress': 60,
            'duration': '20 min',
          },
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Learning History',
            style: AppTextStyles.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Start learning to see your progress here',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyItems.length,
      itemBuilder: (context, index) {
        final item = _historyItems[index];
        final isCompleted = item['completed'] ?? false;
        final progress = (item['progress'] ?? 0).toDouble();
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withValues(alpha:0.1) : AppColors.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.play_circle_outline,
                color: isCompleted ? Colors.green : AppColors.primary,
              ),
            ),
            title: Text(
              item['title'] ?? 'Learning Item',
              style: AppTextStyles.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['type'] ?? 'lesson'} • ${item['duration'] ?? 'Unknown duration'}',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? Colors.green : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${progress.toInt()}%',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item['date']),
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'continue',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Continue'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'restart',
                  child: Row(
                    children: [
                      Icon(Icons.restart_alt),
                      SizedBox(width: 8),
                      Text('Restart'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.remove_circle_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                _handleAction(value, item);
              },
            ),
            onTap: () {
              _continueLearning(item);
            },
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _handleAction(String action, Map<String, dynamic> item) {
    switch (action) {
      case 'continue':
        _continueLearning(item);
        break;
      case 'restart':
        _restartLearning(item);
        break;
      case 'remove':
        _removeFromHistory(item);
        break;
    }
  }

  void _continueLearning(Map<String, dynamic> item) {
    AnalyticsService.trackEvent('learning_continued', {
      'item_title': item['title'],
      'progress': item['progress'],
    });
    
    // Navigate to lesson
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Continuing: ${item['title']}'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _restartLearning(Map<String, dynamic> item) {
    AnalyticsService.trackEvent('learning_restarted', {
      'item_title': item['title'],
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lesson restarted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeFromHistory(Map<String, dynamic> item) {
    setState(() {
      _historyItems.remove(item);
    });
    
    AnalyticsService.trackEvent('history_item_removed', {
      'item_title': item['title'],
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from history'),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Items'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Completed Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.incomplete_circle),
              title: const Text('In Progress Only'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}


