import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../shared/models/base_model.dart';
import '../../../shared/models/result.dart';
import '../../../user/models/user_model.dart';
import '../../../content/models/content_episode_model.dart';
import '../../../analytics/models/learning_analytics_model.dart';
import '../../../core/utils/logger.dart';

/// Production-grade Firestore database service for the new architecture
class FirestoreDataService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  FirestoreDataService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseAvailable = true;
        AppLogger.info('✅ FirestoreDataService: Firebase is available');
      } else {
        AppLogger.warning('⚠️ FirestoreDataService: Firebase not initialized - Firestore features disabled');
        _isFirebaseAvailable = false;
      }
    } catch (e) {
      AppLogger.warning('⚠️ FirestoreDataService: Firebase initialization check failed: $e');
      _isFirebaseAvailable = false;
    }
  }

  void _checkFirebaseAvailability() {
    if (!_isFirebaseAvailable || _firestore == null) {
      throw Exception('Firestore is not available. Please configure Firebase to use this feature.');
    }
  }

  /// Generic method to create a document
  Future<Result<void>> createDocument<T extends BaseModel>({
    required String collection,
    required String documentId,
    required T model,
    bool merge = false,
  }) async {
    try {
      _checkFirebaseAvailability();
      
      await _firestore!
          .collection(collection)
          .doc(documentId)
          .set(model.toMap(), SetOptions(merge: merge));
      
      AppLogger.info('✅ Created document: $collection/$documentId');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to create document: $collection/$documentId - $e');
      return Result.failure('Failed to create document: $e');
    }
  }

  /// Generic method to get a document
  Future<Result<T?>> getDocument<T extends BaseModel>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      _checkFirebaseAvailability();
      
      final doc = await _firestore!.collection(collection).doc(documentId).get();
      
      if (doc.exists && doc.data() != null) {
        final model = fromMap(doc.data()!);
        return Result.success(model);
      }
      
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to get document: $collection/$documentId - $e');
      return Result.failure('Failed to get document: $e');
    }
  }

  /// Generic method to update a document
  Future<Result<void>> updateDocument<T extends BaseModel>({
    required String collection,
    required String documentId,
    required T model,
  }) async {
    try {
      _checkFirebaseAvailability();
      
      await _firestore!
          .collection(collection)
          .doc(documentId)
          .update(model.toMap());
      
      AppLogger.info('✅ Updated document: $collection/$documentId');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to update document: $collection/$documentId - $e');
      return Result.failure('Failed to update document: $e');
    }
  }

  /// Generic method to delete a document
  Future<Result<void>> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      _checkFirebaseAvailability();
      
      await _firestore!.collection(collection).doc(documentId).delete();
      
      AppLogger.info('✅ Deleted document: $collection/$documentId');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Failed to delete document: $collection/$documentId - $e');
      return Result.failure('Failed to delete document: $e');
    }
  }

  /// Query documents with filters
  Future<Result<List<T>>> queryDocuments<T extends BaseModel>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      _checkFirebaseAvailability();
      
      Query query = _firestore!.collection(collection);
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      final models = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) => fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      return Result.success(models);
    } catch (e) {
      AppLogger.error('❌ Failed to query documents: $collection - $e');
      return Result.failure('Failed to query documents: $e');
    }
  }

  /// Batch write operations for efficiency
  Future<Result<void>> batchWrite(List<BatchOperation> operations) async {
    try {
      _checkFirebaseAvailability();
      
      final batch = _firestore!.batch();
      
      for (final operation in operations) {
        final docRef = _firestore!
            .collection(operation.collection)
            .doc(operation.documentId);
        
        switch (operation.type) {
          case BatchOperationType.create:
            batch.set(docRef, operation.data!, SetOptions(merge: operation.merge));
            break;
          case BatchOperationType.update:
            batch.update(docRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }
      
      await batch.commit();
      AppLogger.info('✅ Batch write completed: ${operations.length} operations');
      return Result.success(null);
    } catch (e) {
      AppLogger.error('❌ Batch write failed: $e');
      return Result.failure('Batch write failed: $e');
    }
  }

  /// Real-time stream for document changes
  Stream<Result<T?>> streamDocument<T extends BaseModel>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromMap,
  }) {
    try {
      _checkFirebaseAvailability();
      
      return _firestore!
          .collection(collection)
          .doc(documentId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final model = fromMap(snapshot.data()!);
          return Result.success(model);
        }
        return Result.success<T?>(null);
      }).handleError((error) {
        AppLogger.error('❌ Stream error for $collection/$documentId: $error');
        return Result.failure<T?>('Stream error: $error');
      });
    } catch (e) {
      AppLogger.error('❌ Failed to create stream for $collection/$documentId: $e');
      return Stream.value(Result.failure('Failed to create stream: $e'));
    }
  }

  /// Real-time stream for collection changes
  Stream<Result<List<T>>> streamCollection<T extends BaseModel>({
    required String collection,
    required T Function(Map<String, dynamic>) fromMap,
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    try {
      _checkFirebaseAvailability();
      
      Query query = _firestore!.collection(collection);
      
      // Apply filters
      if (filters != null) {
        for (final filter in filters) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      
      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots().map((snapshot) {
        final models = snapshot.docs
            .where((doc) => doc.data() != null)
            .map((doc) => fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        return Result.success(models);
      }).handleError((error) {
        AppLogger.error('❌ Stream error for collection $collection: $error');
        return Result.failure<List<T>>('Stream error: $error');
      });
    } catch (e) {
      AppLogger.error('❌ Failed to create collection stream for $collection: $e');
      return Stream.value(Result.failure('Failed to create stream: $e'));
    }
  }

  /// Check if service is available
  bool get isAvailable => _isFirebaseAvailable;

  /// Get collection reference (for advanced operations)
  CollectionReference? getCollectionReference(String collection) {
    if (!_isFirebaseAvailable || _firestore == null) return null;
    return _firestore!.collection(collection);
  }
}

/// Query filter for Firestore queries
class QueryFilter {
  final String field;
  final dynamic value;

  const QueryFilter({
    required this.field,
    required this.value,
  });
}

/// Batch operation for Firestore batch writes
class BatchOperation {
  final String collection;
  final String documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;
  final bool merge;

  const BatchOperation({
    required this.collection,
    required this.documentId,
    required this.type,
    this.data,
    this.merge = false,
  });

  factory BatchOperation.create({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.create,
      data: data,
      merge: merge,
    );
  }

  factory BatchOperation.update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.update,
      data: data,
    );
  }

  factory BatchOperation.delete({
    required String collection,
    required String documentId,
  }) {
    return BatchOperation(
      collection: collection,
      documentId: documentId,
      type: BatchOperationType.delete,
    );
  }
}

enum BatchOperationType { create, update, delete }
