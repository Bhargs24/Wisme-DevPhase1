/// Base model interface for all domain models
abstract class BaseModel {
  /// Unique identifier
  String get id;
  
  /// Creation timestamp
  DateTime get createdAt;
  
  /// Last update timestamp
  DateTime get updatedAt;
  
  /// Convert model to JSON
  Map<String, dynamic> toJson();
  
  /// Create copy with updated fields
  BaseModel copyWith();
}

/// Base entity for all business entities
abstract class BaseEntity extends BaseModel {
  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Check if entity is new (not persisted)
  bool get isNew => id.isEmpty;
  
  /// Check if entity was recently created (within last hour)
  bool get isRecentlyCreated {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return createdAt.isAfter(oneHourAgo);
  }
  
  /// Check if entity was recently updated (within last 5 minutes)
  bool get isRecentlyUpdated {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return updatedAt.isAfter(fiveMinutesAgo);
  }
  
  /// Get age of entity
  Duration get age => DateTime.now().difference(createdAt);
}

/// Result wrapper for operations that can succeed or fail
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  const Result.success(this.data) : error = null, isSuccess = true;
  const Result.failure(this.error) : data = null, isSuccess = false;
  
  /// Check if operation failed
  bool get isFailure => !isSuccess;
  
  /// Get data or throw error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'Operation failed');
  }
  
  /// Get data or return default value
  T dataOr(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }
  
  /// Transform success data
  Result<U> map<U>(U Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data!));
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(error);
  }
  
  /// Chain operations
  Result<U> flatMap<U>(Result<U> Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return transform(data!);
      } catch (e) {
        return Result.failure(e.toString());
      }
    }
    return Result.failure(error);
  }
  
  /// Execute function on success
  Result<T> onSuccess(void Function(T) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
    return this;
  }
  
  /// Execute function on failure
  Result<T> onFailure(void Function(String) action) {
    if (isFailure && error != null) {
      action(error!);
    }
    return this;
  }
}

/// Optional value wrapper
class Optional<T> {
  final T? _value;
  
  const Optional._(this._value);
  
  factory Optional.of(T value) => Optional._(value);
  factory Optional.empty() => const Optional._(null);
  factory Optional.fromNullable(T? value) => 
      value != null ? Optional.of(value) : Optional.empty();
  
  /// Check if value is present
  bool get isPresent => _value != null;
  
  /// Check if value is absent
  bool get isEmpty => _value == null;
  
  /// Get value or throw
  T get value {
    if (_value == null) {
      throw StateError('No value present');
    }
    return _value!;
  }
  
  /// Get value or return default
  T orElse(T defaultValue) => _value ?? defaultValue;
  
  /// Get value or compute default
  T orElseGet(T Function() supplier) => _value ?? supplier();
  
  /// Transform value if present
  Optional<U> map<U>(U Function(T) transform) {
    return _value != null 
        ? Optional.of(transform(_value!)) 
        : Optional.empty();
  }
  
  /// Filter value
  Optional<T> filter(bool Function(T) predicate) {
    return _value != null && predicate(_value!) 
        ? this 
        : Optional.empty();
  }
  
  /// Execute action if value is present
  Optional<T> ifPresent(void Function(T) action) {
    if (_value != null) {
      action(_value!);
    }
    return this;
  }
  
  /// Execute action if value is absent
  Optional<T> ifEmpty(void Function() action) {
    if (_value == null) {
      action();
    }
    return this;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Optional<T> && other._value == _value;
  }
  
  @override
  int get hashCode => _value.hashCode;
  
  @override
  String toString() => _value != null ? 'Optional[$_value]' : 'Optional.empty';
}

/// Pagination information
class Pagination {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  
  const Pagination({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });
  
  factory Pagination.fromData({
    required int page,
    required int pageSize,
    required int totalItems,
  }) {
    final totalPages = (totalItems / pageSize).ceil();
    return Pagination(
      page: page,
      pageSize: pageSize,
      totalItems: totalItems,
      totalPages: totalPages,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    );
  }
  
  /// Get offset for database queries
  int get offset => (page - 1) * pageSize;
  
  /// Get start item number (1-based)
  int get startItem => offset + 1;
  
  /// Get end item number (1-based)
  int get endItem => (page * pageSize).clamp(1, totalItems);
  
  /// Check if this is the first page
  bool get isFirstPage => page == 1;
  
  /// Check if this is the last page
  bool get isLastPage => page == totalPages;
  
  /// Get next page number
  int? get nextPage => hasNext ? page + 1 : null;
  
  /// Get previous page number
  int? get previousPage => hasPrevious ? page - 1 : null;
  
  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'totalItems': totalItems,
    'totalPages': totalPages,
    'hasNext': hasNext,
    'hasPrevious': hasPrevious,
  };
  
  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
    totalItems: json['totalItems'] as int,
    totalPages: json['totalPages'] as int,
    hasNext: json['hasNext'] as bool,
    hasPrevious: json['hasPrevious'] as bool,
  );
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final Pagination pagination;
  
  const PaginatedResult({
    required this.items,
    required this.pagination,
  });
  
  /// Check if there are any items
  bool get hasItems => items.isNotEmpty;
  
  /// Check if this is an empty result
  bool get isEmpty => items.isEmpty;
  
  /// Get total number of items across all pages
  int get totalItems => pagination.totalItems;
  
  /// Check if there are more pages
  bool get hasMorePages => pagination.hasNext;
  
  /// Map items to different type
  PaginatedResult<U> map<U>(U Function(T) transform) {
    return PaginatedResult(
      items: items.map(transform).toList(),
      pagination: pagination,
    );
  }
  
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) => {
    'items': items.map(itemToJson).toList(),
    'pagination': pagination.toJson(),
  };
  
  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return PaginatedResult(
      items: (json['items'] as List)
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

/// Sort direction
enum SortDirection {
  ascending,
  descending,
}

/// Sort criteria
class SortCriteria {
  final String field;
  final SortDirection direction;
  
  const SortCriteria({
    required this.field,
    required this.direction,
  });
  
  /// Create ascending sort
  factory SortCriteria.ascending(String field) => 
      SortCriteria(field: field, direction: SortDirection.ascending);
  
  /// Create descending sort
  factory SortCriteria.descending(String field) => 
      SortCriteria(field: field, direction: SortDirection.descending);
  
  /// Check if sorting ascending
  bool get isAscending => direction == SortDirection.ascending;
  
  /// Check if sorting descending
  bool get isDescending => direction == SortDirection.descending;
  
  Map<String, dynamic> toJson() => {
    'field': field,
    'direction': direction.name,
  };
  
  factory SortCriteria.fromJson(Map<String, dynamic> json) => SortCriteria(
    field: json['field'] as String,
    direction: SortDirection.values.byName(json['direction'] as String),
  );
}

/// Filter criteria
class FilterCriteria {
  final String field;
  final dynamic value;
  final FilterOperator operator;
  
  const FilterCriteria({
    required this.field,
    required this.value,
    required this.operator,
  });
  
  Map<String, dynamic> toJson() => {
    'field': field,
    'value': value,
    'operator': operator.name,
  };
  
  factory FilterCriteria.fromJson(Map<String, dynamic> json) => FilterCriteria(
    field: json['field'] as String,
    value: json['value'],
    operator: FilterOperator.values.byName(json['operator'] as String),
  );
}

/// Filter operators
enum FilterOperator {
  equals,
  notEquals,
  contains,
  startsWith,
  endsWith,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  isNull,
  isNotNull,
  isIn,
  isNotIn,
}

/// Query parameters for data operations
class QueryParams {
  final int page;
  final int pageSize;
  final List<SortCriteria> sortBy;
  final List<FilterCriteria> filters;
  final String? searchQuery;
  
  const QueryParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = const [],
    this.filters = const [],
    this.searchQuery,
  });
  
  /// Create default query params
  factory QueryParams.defaultParams() => const QueryParams();
  
  /// Create query params with search
  factory QueryParams.search(String query) => QueryParams(searchQuery: query);
  
  /// Create query params with sort
  factory QueryParams.sort(SortCriteria sortCriteria) => 
      QueryParams(sortBy: [sortCriteria]);
  
  /// Create query params with filter
  factory QueryParams.filter(FilterCriteria filterCriteria) => 
      QueryParams(filters: [filterCriteria]);
  
  /// Add sort criteria
  QueryParams addSort(SortCriteria sortCriteria) => QueryParams(
    page: page,
    pageSize: pageSize,
    sortBy: [...sortBy, sortCriteria],
    filters: filters,
    searchQuery: searchQuery,
  );
  
  /// Add filter criteria
  QueryParams addFilter(FilterCriteria filterCriteria) => QueryParams(
    page: page,
    pageSize: pageSize,
    sortBy: sortBy,
    filters: [...filters, filterCriteria],
    searchQuery: searchQuery,
  );
  
  /// Change page
  QueryParams withPage(int newPage) => QueryParams(
    page: newPage,
    pageSize: pageSize,
    sortBy: sortBy,
    filters: filters,
    searchQuery: searchQuery,
  );
  
  /// Change page size
  QueryParams withPageSize(int newPageSize) => QueryParams(
    page: page,
    pageSize: newPageSize,
    sortBy: sortBy,
    filters: filters,
    searchQuery: searchQuery,
  );
  
  /// Change search query
  QueryParams withSearch(String? newSearchQuery) => QueryParams(
    page: page,
    pageSize: pageSize,
    sortBy: sortBy,
    filters: filters,
    searchQuery: newSearchQuery,
  );
  
  Map<String, dynamic> toJson() => {
    'page': page,
    'pageSize': pageSize,
    'sortBy': sortBy.map((s) => s.toJson()).toList(),
    'filters': filters.map((f) => f.toJson()).toList(),
    'searchQuery': searchQuery,
  };
  
  factory QueryParams.fromJson(Map<String, dynamic> json) => QueryParams(
    page: json['page'] as int? ?? 1,
    pageSize: json['pageSize'] as int? ?? 20,
    sortBy: (json['sortBy'] as List? ?? [])
        .map((s) => SortCriteria.fromJson(s as Map<String, dynamic>))
        .toList(),
    filters: (json['filters'] as List? ?? [])
        .map((f) => FilterCriteria.fromJson(f as Map<String, dynamic>))
        .toList(),
    searchQuery: json['searchQuery'] as String?,
  );
}

/// Loading state for UI components
enum LoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Extension on LoadingState for convenience
extension LoadingStateExtension on LoadingState {
  bool get isInitial => this == LoadingState.initial;
  bool get isLoading => this == LoadingState.loading;
  bool get isLoaded => this == LoadingState.loaded;
  bool get isError => this == LoadingState.error;
  bool get isEmpty => this == LoadingState.empty;
  bool get hasData => isLoaded || isEmpty;
}

/// State wrapper for UI components
class UIState<T> {
  final LoadingState state;
  final T? data;
  final String? error;
  
  const UIState.initial() : state = LoadingState.initial, data = null, error = null;
  const UIState.loading() : state = LoadingState.loading, data = null, error = null;
  const UIState.loaded(this.data) : state = LoadingState.loaded, error = null;
  const UIState.error(this.error) : state = LoadingState.error, data = null;
  const UIState.empty() : state = LoadingState.empty, data = null, error = null;
  
  /// Convenience getters
  bool get isInitial => state.isInitial;
  bool get isLoading => state.isLoading;
  bool get isLoaded => state.isLoaded;
  bool get isError => state.isError;
  bool get isEmpty => state.isEmpty;
  bool get hasData => data != null;
  
  /// Transform data
  UIState<U> map<U>(U Function(T) transform) {
    if (isLoaded && data != null) {
      try {
        return UIState.loaded(transform(data!));
      } catch (e) {
        return UIState.error(e.toString());
      }
    }
    
    switch (state) {
      case LoadingState.initial:
        return const UIState.initial();
      case LoadingState.loading:
        return const UIState.loading();
      case LoadingState.error:
        return UIState.error(error);
      case LoadingState.empty:
        return const UIState.empty();
      case LoadingState.loaded:
        return const UIState.empty();
    }
  }
}
