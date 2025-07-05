import '../../shared/models/base_model.dart';

/// User interaction types for analytics tracking
enum UserInteractionType { 
  play, 
  pause, 
  skip, 
  rate, 
  bookmark, 
  share, 
  complete,
  replay,
  download,
  search,
  like,
  comment
}

/// Represents a content recommendation with scoring
class ContentRecommendation extends BaseModel {
  final String contentId;
  final double score;
  final String reason;
  final String algorithm;
  final Map<String, dynamic> features;

  const ContentRecommendation({
    required super.id,
    required this.contentId,
    required this.score,
    required this.reason,
    this.algorithm = 'default',
    this.features = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'contentId': contentId,
        'score': score,
        'reason': reason,
        'algorithm': algorithm,
        'features': features,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory ContentRecommendation.fromJson(Map<String, dynamic> json) => ContentRecommendation(
        id: json['id'] as String?,
        contentId: json['contentId'] as String,
        score: (json['score'] as num).toDouble(),
        reason: json['reason'] as String,
        algorithm: json['algorithm'] as String? ?? 'default',
        features: json['features'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  ContentRecommendation copyWith({
    String? id,
    String? contentId,
    double? score,
    String? reason,
    String? algorithm,
    Map<String, dynamic>? features,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ContentRecommendation(
        id: id ?? this.id,
        contentId: contentId ?? this.contentId,
        score: score ?? this.score,
        reason: reason ?? this.reason,
        algorithm: algorithm ?? this.algorithm,
        features: features ?? this.features,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// Cost optimization statistics
class CostOptimizationStats extends BaseModel {
  final int totalApiCalls;
  final double totalCost;
  final double costSavings;
  final double reuseRate;
  final Map<String, dynamic> breakdown;

  const CostOptimizationStats({
    required super.id,
    required this.totalApiCalls,
    required this.totalCost,
    required this.costSavings,
    required this.reuseRate,
    this.breakdown = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'totalApiCalls': totalApiCalls,
        'totalCost': totalCost,
        'costSavings': costSavings,
        'reuseRate': reuseRate,
        'breakdown': breakdown,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory CostOptimizationStats.fromJson(Map<String, dynamic> json) => CostOptimizationStats(
        id: json['id'] as String?,
        totalApiCalls: json['totalApiCalls'] as int,
        totalCost: (json['totalCost'] as num).toDouble(),
        costSavings: (json['costSavings'] as num).toDouble(),
        reuseRate: (json['reuseRate'] as num).toDouble(),
        breakdown: json['breakdown'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  CostOptimizationStats copyWith({
    String? id,
    int? totalApiCalls,
    double? totalCost,
    double? costSavings,
    double? reuseRate,
    Map<String, dynamic>? breakdown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      CostOptimizationStats(
        id: id ?? this.id,
        totalApiCalls: totalApiCalls ?? this.totalApiCalls,
        totalCost: totalCost ?? this.totalCost,
        costSavings: costSavings ?? this.costSavings,
        reuseRate: reuseRate ?? this.reuseRate,
        breakdown: breakdown ?? this.breakdown,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// Business analytics data structure
class BusinessAnalytics extends BaseModel {
  final Map<String, dynamic> userEngagement;
  final Map<String, dynamic> contentPerformance;
  final Map<String, dynamic> revenueMetrics;
  final Map<String, dynamic> operationalMetrics;

  const BusinessAnalytics({
    required super.id,
    required this.userEngagement,
    required this.contentPerformance,
    required this.revenueMetrics,
    this.operationalMetrics = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'userEngagement': userEngagement,
        'contentPerformance': contentPerformance,
        'revenueMetrics': revenueMetrics,
        'operationalMetrics': operationalMetrics,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory BusinessAnalytics.fromJson(Map<String, dynamic> json) => BusinessAnalytics(
        id: json['id'] as String?,
        userEngagement: json['userEngagement'] as Map<String, dynamic>,
        contentPerformance: json['contentPerformance'] as Map<String, dynamic>,
        revenueMetrics: json['revenueMetrics'] as Map<String, dynamic>,
        operationalMetrics: json['operationalMetrics'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  BusinessAnalytics copyWith({
    String? id,
    Map<String, dynamic>? userEngagement,
    Map<String, dynamic>? contentPerformance,
    Map<String, dynamic>? revenueMetrics,
    Map<String, dynamic>? operationalMetrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      BusinessAnalytics(
        id: id ?? this.id,
        userEngagement: userEngagement ?? this.userEngagement,
        contentPerformance: contentPerformance ?? this.contentPerformance,
        revenueMetrics: revenueMetrics ?? this.revenueMetrics,
        operationalMetrics: operationalMetrics ?? this.operationalMetrics,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

/// System health monitoring report
class SystemHealthReport extends BaseModel {
  final String overallHealth;
  final Map<String, String> componentStatus;
  final List<String> alerts;
  final Map<String, dynamic> metrics;

  const SystemHealthReport({
    required super.id,
    required this.overallHealth,
    required this.componentStatus,
    required this.alerts,
    this.metrics = const {},
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'overallHealth': overallHealth,
        'componentStatus': componentStatus,
        'alerts': alerts,
        'metrics': metrics,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory SystemHealthReport.fromJson(Map<String, dynamic> json) => SystemHealthReport(
        id: json['id'] as String?,
        overallHealth: json['overallHealth'] as String,
        componentStatus: Map<String, String>.from(json['componentStatus'] as Map),
        alerts: (json['alerts'] as List<dynamic>).cast<String>(),
        metrics: json['metrics'] as Map<String, dynamic>? ?? {},
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      );

  SystemHealthReport copyWith({
    String? id,
    String? overallHealth,
    Map<String, String>? componentStatus,
    List<String>? alerts,
    Map<String, dynamic>? metrics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      SystemHealthReport(
        id: id ?? this.id,
        overallHealth: overallHealth ?? this.overallHealth,
        componentStatus: componentStatus ?? this.componentStatus,
        alerts: alerts ?? this.alerts,
        metrics: metrics ?? this.metrics,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
