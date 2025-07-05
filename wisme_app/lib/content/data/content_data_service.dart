import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_item.dart';
import '../models/curriculum.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';

/// Data service for content and curriculum operations with Firestore
class ContentDataService {
  static const String _contentCollection = 'content_items';
  static const String _curriculumCollection = 'curricula';

  final FirebaseFirestore _firestore;
  final AppLogger _logger;

  ContentDataService({
    FirebaseFirestore? firestore,
    AppLogger? logger,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _logger = logger ?? AppLogger();

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
      _logger.error('Failed to get content item: $contentId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content item: $e');
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
      _logger.error('Failed to get content items', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content items: $e');
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
      _logger.error('Failed to get content by type', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content by type: $e');
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
      _logger.error('Failed to get content by difficulty', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content by difficulty: $e');
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
      _logger.error('Failed to get content by tags', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content by tags: $e');
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
      _logger.error('Failed to search content', error: e, stackTrace: stack);
      throw DataException('Failed to search content: $e');
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

      _logger.info('Content item saved: ${contentItem.id}');
    } catch (e, stack) {
      _logger.error('Failed to save content item', error: e, stackTrace: stack);
      throw DataException('Failed to save content item: $e');
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
      _logger.error('Failed to get curriculum: $curriculumId', error: e, stackTrace: stack);
      throw DataException('Failed to fetch curriculum: $e');
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
      _logger.error('Failed to get published curricula', error: e, stackTrace: stack);
      throw DataException('Failed to fetch published curricula: $e');
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
      _logger.error('Failed to get curricula by level', error: e, stackTrace: stack);
      throw DataException('Failed to fetch curricula by level: $e');
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

      _logger.info('Curriculum saved: ${curriculum.id}');
    } catch (e, stack) {
      _logger.error('Failed to save curriculum', error: e, stackTrace: stack);
      throw DataException('Failed to save curriculum: $e');
    }
  }

  /// Get content items for curriculum
  Future<List<ContentItem>> getContentForCurriculum(String curriculumId) async {
    try {
      final curriculum = await getCurriculum(curriculumId);
      if (curriculum == null) {
        throw DataException('Curriculum not found: $curriculumId');
      }

      // Collect all content IDs from all modules
      final contentIds = <String>[];
      for (final module in curriculum.modules) {
        contentIds.addAll(module.contentItems);
      }

      if (contentIds.isEmpty) return [];

      return await getContentItems(contentIds);
    } catch (e, stack) {
      _logger.error('Failed to get content for curriculum', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content for curriculum: $e');
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
        typeCounts[type.name] = typeQuery.count;
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
        difficultyCounts[difficulty.name] = difficultyQuery.count;
      }

      return {
        'totalContent': totalContent,
        'byType': typeCounts,
        'byDifficulty': difficultyCounts,
      };
    } catch (e, stack) {
      _logger.error('Failed to get content statistics', error: e, stackTrace: stack);
      throw DataException('Failed to fetch content statistics: $e');
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
