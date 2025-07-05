import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import '../models/curriculum.dart';
import '../../core/error/app_exceptions.dart';
import '../../core/utils/logger.dart';

/// Data service for content and curriculum operations with Firestore
class ContentDataService {
  static const String _contentCollection = 'content_items';
  static const String _curriculumCollection = 'curricula';

  final FirebaseFirestore _firestore;

  ContentDataService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // === INITIALIZATION AND LIFECYCLE ===

  /// Initialize the data service
  Future<void> initialize() async {
    try {
      AppLogger.info('ContentDataService initialized');
    } catch (e, stack) {
      AppLogger.error('Failed to initialize ContentDataService: $e', e, stack);
      throw ContentException('Failed to initialize content data service: $e');
    }
  }

  /// Get the status of the data service
  String getStatus() {
    return 'active';
  }

  /// Dispose of resources
  Future<void> dispose() async {
    try {
      AppLogger.info('ContentDataService disposed');
    } catch (e, stack) {
      AppLogger.error('Failed to dispose ContentDataService: $e', e, stack);
    }
  }

  // === CONTENT ITEM OPERATIONS ===

  /// Get content item by ID
  Future<ContentItem?> getContentItem(String contentId) async {
    try {
      final doc = await _firestore
          .collection(_contentCollection)
          .doc(contentId)
          .get();

      if (!doc.exists) return null;

      return ContentItem.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      AppLogger.error('Failed to get content item: $contentId: $e', e, stack);
      throw ContentException('Failed to fetch content item: $e');
    }
  }

  /// Get multiple content items by IDs
  Future<List<ContentItem>> getContentItems(List<String> contentIds) async {
    if (contentIds.isEmpty) return [];

    try {
      final items = <ContentItem>[];
      
      // Firestore 'in' queries are limited to 10 items
      final chunks = _chunkList(contentIds, 10);
      
      for (final chunk in chunks) {
        final query = await _firestore
            .collection(_contentCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        items.addAll(
          query.docs.map((doc) => ContentItem.fromJson({
            'id': doc.id,
            ...doc.data(),
          }))
        );
      }

      return items;
    } catch (e, stack) {
      AppLogger.error('Failed to get content items: $e', e, stack);
      throw ContentException('Failed to fetch content items: $e');
    }
  }

  /// Get published content items by type
  Future<List<ContentItem>> getContentByType(ContentType type) async {
    try {
      final query = await _firestore
          .collection(_contentCollection)
          .where('type', isEqualTo: type.name)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => ContentItem.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get content by type: $e', e, stack);
      throw ContentException('Failed to fetch content by type: $e');
    }
  }

  /// Get content items by difficulty level
  Future<List<ContentItem>> getContentByDifficulty(DifficultyLevel difficulty) async {
    try {
      final query = await _firestore
          .collection(_contentCollection)
          .where('difficulty', isEqualTo: difficulty.name)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => ContentItem.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get content by difficulty: $e', e, stack);
      throw ContentException('Failed to fetch content by difficulty: $e');
    }
  }

  /// Get content items by tags
  Future<List<ContentItem>> getContentByTags(List<String> tags) async {
    try {
      final query = await _firestore
          .collection(_contentCollection)
          .where('tags', arrayContainsAny: tags)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => ContentItem.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get content by tags: $e', e, stack);
      throw ContentException('Failed to fetch content by tags: $e');
    }
  }

  /// Search content items
  Future<List<ContentItem>> searchContent({
    String? query,
    ContentType? type,
    DifficultyLevel? difficulty,
    List<String>? tags,
    int limit = 50,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection(_contentCollection)
          .where('isPublished', isEqualTo: true);

      // Apply filters
      if (type != null) {
        firestoreQuery = firestoreQuery.where('type', isEqualTo: type.name);
      }

      if (difficulty != null) {
        firestoreQuery = firestoreQuery.where('difficulty', isEqualTo: difficulty.name);
      }

      if (tags != null && tags.isNotEmpty) {
        firestoreQuery = firestoreQuery.where('tags', arrayContainsAny: tags);
      }

      firestoreQuery = firestoreQuery
          .orderBy('createdAt', descending: true)
          .limit(limit);

      final querySnapshot = await firestoreQuery.get();

      List<ContentItem> results = querySnapshot.docs.map((doc) => ContentItem.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })).toList();

      // Client-side filtering for text search if query provided
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        results = results.where((item) =>
            item.title.toLowerCase().contains(queryLower) ||
            item.description.toLowerCase().contains(queryLower) ||
            item.content.toLowerCase().contains(queryLower) ||
            item.tags.any((tag) => tag.toLowerCase().contains(queryLower))
        ).toList();
      }

      return results;
    } catch (e, stack) {
      AppLogger.error('Failed to search content: $e', e, stack);
      throw ContentException('Failed to search content: $e');
    }
  }

  /// Save content item
  Future<void> saveContentItem(ContentItem contentItem) async {
    try {
      final data = contentItem.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_contentCollection)
          .doc(contentItem.id)
          .set(data, SetOptions(merge: true));

      AppLogger.info('Content item saved: ${contentItem.id}');
    } catch (e, stack) {
      AppLogger.error('Failed to save content item: $e', e, stack);
      throw ContentException('Failed to save content item: $e');
    }
  }

  // === CURRICULUM OPERATIONS ===

  /// Get curriculum by ID
  Future<Curriculum?> getCurriculum(String curriculumId) async {
    try {
      final doc = await _firestore
          .collection(_curriculumCollection)
          .doc(curriculumId)
          .get();

      if (!doc.exists) return null;

      return Curriculum.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e, stack) {
      AppLogger.error('Failed to get curriculum: $curriculumId: $e', e, stack);
      throw ContentException('Failed to fetch curriculum: $e');
    }
  }

  /// Get published curricula
  Future<List<Curriculum>> getPublishedCurricula() async {
    try {
      final query = await _firestore
          .collection(_curriculumCollection)
          .where('status', isEqualTo: CurriculumStatus.published.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => Curriculum.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get published curricula: $e', e, stack);
      throw ContentException('Failed to fetch published curricula: $e');
    }
  }

  /// Get curricula by level
  Future<List<Curriculum>> getCurriculaByLevel(CurriculumLevel level) async {
    try {
      final query = await _firestore
          .collection(_curriculumCollection)
          .where('level', isEqualTo: level.name)
          .where('status', isEqualTo: CurriculumStatus.published.name)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => Curriculum.fromJson({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get curricula by level: $e', e, stack);
      throw ContentException('Failed to fetch curricula by level: $e');
    }
  }

  /// Save curriculum
  Future<void> saveCurriculum(Curriculum curriculum) async {
    try {
      final data = curriculum.toJson();
      data.remove('id'); // Remove ID from data

      await _firestore
          .collection(_curriculumCollection)
          .doc(curriculum.id)
          .set(data, SetOptions(merge: true));

      AppLogger.info('Curriculum saved: ${curriculum.id}');
    } catch (e, stack) {
      AppLogger.error('Failed to save curriculum: $e', e, stack);
      throw ContentException('Failed to save curriculum: $e');
    }
  }

  /// Get content items for curriculum
  Future<List<ContentItem>> getContentForCurriculum(String curriculumId) async {
    try {
      final curriculum = await getCurriculum(curriculumId);
      if (curriculum == null) {
        throw ContentException('Curriculum not found: $curriculumId');
      }

      // Collect all content IDs from all modules
      final contentIds = <String>[];
      for (final module in curriculum.modules) {
        contentIds.addAll(module.contentItems);
      }

      if (contentIds.isEmpty) return [];

      return await getContentItems(contentIds);
    } catch (e, stack) {
      AppLogger.error('Failed to get content for curriculum: $e', e, stack);
      throw ContentException('Failed to fetch content for curriculum: $e');
    }
  }

  /// Get content statistics
  Future<Map<String, dynamic>> getContentStatistics() async {
    try {
      // Get total published content count
      final totalQuery = await _firestore
          .collection(_contentCollection)
          .where('isPublished', isEqualTo: true)
          .count()
          .get();

      final totalContent = totalQuery.count;

      // Get count by type
      final typeCounts = <String, int>{};
      for (final type in ContentType.values) {
        final typeQuery = await _firestore
            .collection(_contentCollection)
            .where('type', isEqualTo: type.name)
            .where('isPublished', isEqualTo: true)
            .count()
            .get();
        typeCounts[type.name] = typeQuery.count ?? 0;
      }

      // Get count by difficulty
      final difficultyCounts = <String, int>{};
      for (final difficulty in DifficultyLevel.values) {
        final difficultyQuery = await _firestore
            .collection(_contentCollection)
            .where('difficulty', isEqualTo: difficulty.name)
            .where('isPublished', isEqualTo: true)
            .count()
            .get();
        difficultyCounts[difficulty.name] = difficultyQuery.count ?? 0;
      }

      return {
        'totalContent': totalContent,
        'byType': typeCounts,
        'byDifficulty': difficultyCounts,
      };
    } catch (e, stack) {
      AppLogger.error('Failed to get content statistics: $e', e, stack);
      throw ContentException('Failed to fetch content statistics: $e');
    }
  }

  // === CRUD OPERATIONS ===

  /// Create a new content item
  Future<ContentItem> createContentItem(ContentItem item) async {
    try {
      final docRef = _firestore.collection(_contentCollection).doc();
      
      // Create a new ContentItem with the generated ID
      final itemWithId = ContentItem(
        id: docRef.id,
        title: item.title,
        description: item.description,
        type: item.type,
        content: item.content,
        format: item.format,
        tags: item.tags,
        difficulty: item.difficulty,
        estimatedDuration: item.estimatedDuration,
        resources: item.resources,
        metadata: item.metadata,
        isPublished: item.isPublished,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        creatorId: item.creatorId,
        configuration: item.configuration,
      );
      
      await docRef.set(itemWithId.toJson());
      return itemWithId;
    } catch (e, stack) {
      AppLogger.error('Failed to create content item: $e', e, stack);
      throw ContentException('Failed to create content item: $e');
    }
  }

  /// Update an existing content item
  Future<ContentItem> updateContentItem(ContentItem item) async {
    try {
      await _firestore
          .collection(_contentCollection)
          .doc(item.id)
          .update(item.toJson());
      return item;
    } catch (e, stack) {
      AppLogger.error('Failed to update content item: $e', e, stack);
      throw ContentException('Failed to update content item: $e');
    }
  }

  /// Delete a content item
  Future<void> deleteContentItem(String contentId) async {
    try {
      await _firestore
          .collection(_contentCollection)
          .doc(contentId)
          .delete();
    } catch (e, stack) {
      AppLogger.error('Failed to delete content item: $e', e, stack);
      throw ContentException('Failed to delete content item: $e');
    }
  }

  /// Get content by category (alias for getContentByType)
  Future<List<ContentItem>> getContentByCategory(String category) async {
    try {
      // Convert string to ContentType enum if possible
      final contentType = ContentType.values
          .cast<ContentType?>()
          .firstWhere((type) => type?.name == category, orElse: () => null);
      
      if (contentType != null) {
        return await getContentByType(contentType);
      } else {
        // Fallback: search by tags or custom field
        return await getContentByTags([category]);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to get content by category: $e', e, stack);
      throw ContentException('Failed to get content by category: $e');
    }
  }

  /// Get recommendations for a user
  Future<List<ContentItem>> getRecommendations(String userId) async {
    try {
      // Simple recommendation: get most recent content
      // This could be enhanced with AI-based recommendations later
      final query = await _firestore
          .collection(_contentCollection)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return query.docs
          .map((doc) => ContentItem.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e, stack) {
      AppLogger.error('Failed to get recommendations: $e', e, stack);
      throw ContentException('Failed to get recommendations: $e');
    }
  }

  /// Helper method to chunk lists for Firestore 'in' queries
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, 
          i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}

