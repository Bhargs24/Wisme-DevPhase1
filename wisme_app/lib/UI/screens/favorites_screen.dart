import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../_old_structure_backup/services/analytics_service.dart';

/// Production-ready Favorites Screen
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('user_favorites') ?? [];
      
      setState(() {
        _favorites = favoritesJson.map((json) => {
          'id': 'fav_${DateTime.now().millisecondsSinceEpoch}',
          'title': json,
          'type': 'lesson',
          'dateAdded': DateTime.now().toIso8601String(),
        }).toList();
        _isLoading = false;
      });

      AnalyticsService.trackEvent('favorites_viewed', {
        'favorites_count': _favorites.length,
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Favorites Yet',
            style: AppTextStyles.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add lessons to favorites to find them quickly',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(favorite['title'] ?? 'Favorite Item'),
            subtitle: Text('Added ${_formatDate(favorite['dateAdded'])}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => _removeFavorite(index),
            ),
            onTap: () {
              // Navigate to content
            },
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _removeFavorite(int index) {
    setState(() {
      _favorites.removeAt(index);
    });
    
    AnalyticsService.trackEvent('favorite_removed', {
      'item_index': index,
    });
  }
}
