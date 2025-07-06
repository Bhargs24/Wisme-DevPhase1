import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../core/offline/offline_service.dart';
// TODO: Replace with AnalyticsManager import
// TODO: Replace with new lesson models

/// Production-ready Downloads Screen
/// Shows offline content and download management
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model> _downloadedContent = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedContent();
  }

  Future<void> _loadDownloadedContent() async {
    try {
      // Get offline content using production service
      final offlineContent = await OfflineService.getOfflineContent();
      
      setState(() {
        _downloadedContent = offlineContent.cast<Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model>();
        _isLoading = false;
      });

      // Track analytics
      AnalyticsService.trackEvent('downloads_viewed', {
        'downloaded_count': _downloadedContent.length,
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load downloads: $e'),
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
        title: const Text('Downloaded Lessons'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: _showStorageInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDownloadedContent,
              child: _downloadedContent.isEmpty
                  ? _buildEmptyState()
                  : _buildDownloadsList(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Downloaded Lessons',
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Download lessons to access them offline',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Lessons'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloadedContent.length,
      itemBuilder: (context, index) {
        final content = _downloadedContent[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              content.title,
              style: AppTextStyles.textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.topic,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.offline_pin,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Offline available',
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'play',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow),
                      SizedBox(width: 8),
                      Text('Play'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'play') {
                  _playContent(content);
                } else if (value == 'delete') {
                  _deleteContent(content);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _playContent(Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model content) {
    // Navigate to lesson player
    Navigator.pushNamed(
      context,
      '/lesson',
      arguments: {
        'lesson': content,
        'isOffline': true,
      },
    );
  }

  void _deleteContent(Map<String, dynamic> // TODO: Replace with Map<String, dynamic> // TODO: Replace with ContentBlock model model content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Remove "${content.title}" from downloads?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await OfflineService.removeOfflineContent(content.id);
                Navigator.pop(context);
                _loadDownloadedContent();
                
                AnalyticsService.trackEvent('content_deleted', {
                  'content_id': content.id,
                  'content_title': content.title,
                });
                
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Downloaded Content: Loading...'),
            Text('Available Space: Loading...'),
            Text('Cache Size: Loading...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}


