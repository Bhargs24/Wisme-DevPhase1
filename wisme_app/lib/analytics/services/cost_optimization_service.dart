import 'dart:math' as math;

import '../../core/utils/logger.dart';
import '../models/business_intelligence_model.dart';

/// 💰 Advanced cost optimization engine for API usage and resource management
/// Provides intelligent cost tracking, optimization strategies, and budget management
class CostOptimizationService {
  // Cost tracking data
  final Map<String, List<ApiCall>> _apiCalls = {};
  final Map<String, double> _costsByService = {};
  final Map<String, CostBreakdown> _dailyCosts = {};
  final Map<String, OptimizationStrategy> _optimizationStrategies = {};
  
  // Budget and limits
  double _monthlyBudget = 1000.0;
  double _dailyBudgetLimit = 50.0;
  final Map<String, double> _serviceBudgets = {};
  
  // Optimization settings
  bool _autoOptimizationEnabled = true;
  double _targetSavingsPercentage = 0.20; // 20% savings target
  
  static const Map<String, double> _baseCosts = {
    'openai_gpt4': 0.03, // per 1K tokens
    'openai_gpt3_5': 0.002, // per 1K tokens
    'elevenlabs_tts': 0.30, // per 1K characters
    'azure_speech': 0.015, // per 1K characters
    'google_cloud_storage': 0.026, // per GB
    'firebase_firestore': 0.0012, // per 100K operations
  };

  /// Get current cost optimization statistics
  CostOptimizationStats getStats() {
    try {
      final totalCalls = _getTotalApiCalls();
      final totalCost = _getTotalCost();
      final savings = _calculateTotalSavings();
      final reuseRate = _calculateReuseRate();
      
      return CostOptimizationStats(
        id: 'cost_stats_${DateTime.now().millisecondsSinceEpoch}',
        totalApiCalls: totalCalls,
        totalCost: totalCost,
        costSavings: savings,
        reuseRate: reuseRate,
        breakdown: {
          'costs_by_service': Map<String, double>.from(_costsByService),
          'daily_costs': _getDailyCostsSummary(),
          'optimization_potential': _calculateOptimizationPotential(),
          'budget_utilization': _calculateBudgetUtilization(),
          'efficiency_metrics': _getEfficiencyMetrics(),
        },
      );
    } catch (e) {
      AppLogger.error('Failed to generate cost stats: $e');
      return CostOptimizationStats(
        id: 'error_stats',
        totalApiCalls: 0,
        totalCost: 0.0,
        costSavings: 0.0,
        reuseRate: 0.0,
      );
    }
  }

  /// Record an API call for cost tracking
  Future<void> recordApiCall({
    required String service,
    required String operation,
    required int tokenCount,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final cost = _calculateCallCost(service, operation, tokenCount);
      
      final apiCall = ApiCall(
        id: 'api_${timestamp.millisecondsSinceEpoch}',
        service: service,
        operation: operation,
        tokenCount: tokenCount,
        cost: cost,
        timestamp: timestamp,
        metadata: metadata ?? {},
      );
      
      // Store API call
      _apiCalls.putIfAbsent(service, () => []).add(apiCall);
      
      // Update service costs
      _costsByService[service] = (_costsByService[service] ?? 0.0) + cost;
      
      // Update daily costs
      final dateKey = _formatDate(timestamp);
      final dailyBreakdown = _dailyCosts.putIfAbsent(dateKey, () => CostBreakdown(
        date: dateKey,
        totalCost: 0.0,
        serviceBreakdown: {},
      ));
      
      dailyBreakdown.totalCost += cost;
      dailyBreakdown.serviceBreakdown[service] = 
          (dailyBreakdown.serviceBreakdown[service] ?? 0.0) + cost;
      
      // Check for optimization opportunities
      if (_autoOptimizationEnabled) {
        await _checkOptimizationOpportunities(service, apiCall);
      }
      
      // Check budget alerts
      await _checkBudgetAlerts(cost);
      
      AppLogger.info('💰 Recorded API call: $service.$operation - \$${cost.toStringAsFixed(4)}');
    } catch (e) {
      AppLogger.error('Failed to record API call: $e');
    }
  }

  /// Record content reuse to track cost savings
  Future<void> recordContentReuse({
    required String contentId,
    required String originalService,
    required double estimatedSavings,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final reuseEvent = ContentReuseEvent(
        id: 'reuse_${DateTime.now().millisecondsSinceEpoch}',
        contentId: contentId,
        originalService: originalService,
        estimatedSavings: estimatedSavings,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      // Track savings
      _recordCostSavings(originalService, estimatedSavings);
      
      AppLogger.info('💎 Recorded content reuse: $contentId - \$${estimatedSavings.toStringAsFixed(4)} saved');
    } catch (e) {
      AppLogger.error('Failed to record content reuse: $e');
    }
  }

  /// Get cost optimization recommendations
  Future<List<OptimizationRecommendation>> getOptimizationRecommendations() async {
    final recommendations = <OptimizationRecommendation>[];
    
    try {
      // Analyze API usage patterns
      recommendations.addAll(await _analyzeApiUsagePatterns());
      
      // Analyze content reuse opportunities
      recommendations.addAll(await _analyzeContentReuseOpportunities());
      
      // Analyze service efficiency
      recommendations.addAll(await _analyzeServiceEfficiency());
      
      // Analyze budget optimization
      recommendations.addAll(await _analyzeBudgetOptimization());
      
      // Sort by potential savings
      recommendations.sort((a, b) => b.potentialSavings.compareTo(a.potentialSavings));
      
      AppLogger.info('📊 Generated ${recommendations.length} optimization recommendations');
      return recommendations;
    } catch (e) {
      AppLogger.error('Failed to generate optimization recommendations: $e');
      return [];
    }
  }

  /// Set budget limits and alerts
  Future<void> setBudget({
    double? monthlyBudget,
    double? dailyBudgetLimit,
    Map<String, double>? serviceBudgets,
  }) async {
    if (monthlyBudget != null) {
      _monthlyBudget = monthlyBudget;
    }
    
    if (dailyBudgetLimit != null) {
      _dailyBudgetLimit = dailyBudgetLimit;
    }
    
    if (serviceBudgets != null) {
      _serviceBudgets.addAll(serviceBudgets);
    }
    
    AppLogger.info('💰 Budget updated: Monthly: \$${_monthlyBudget.toStringAsFixed(2)}, Daily: \$${_dailyBudgetLimit.toStringAsFixed(2)}');
  }

  /// Enable or disable automatic optimization
  void setAutoOptimization(bool enabled) {
    _autoOptimizationEnabled = enabled;
    AppLogger.info('⚙️ Auto-optimization ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set cost savings target
  void setSavingsTarget(double percentage) {
    _targetSavingsPercentage = percentage;
    AppLogger.info('🎯 Savings target set to ${(percentage * 100).toStringAsFixed(1)}%');
  }

  /// Get detailed cost analysis for a specific time period
  Future<Map<String, dynamic>> getCostAnalysis({
    DateTime? startDate,
    DateTime? endDate,
    String? service,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final analysis = <String, dynamic>{};
    
    // Filter data by date range
    final filteredCalls = _filterApiCallsByDateRange(start, end, service);
    
    // Calculate totals
    analysis['total_cost'] = _calculateTotalCostForCalls(filteredCalls);
    analysis['total_calls'] = filteredCalls.length;
    analysis['average_cost_per_call'] = filteredCalls.isNotEmpty 
        ? analysis['total_cost'] / filteredCalls.length 
        : 0.0;
    
    // Cost breakdown by service
    analysis['cost_by_service'] = _groupCostsByService(filteredCalls);
    
    // Cost breakdown by operation
    analysis['cost_by_operation'] = _groupCostsByOperation(filteredCalls);
    
    // Daily cost trend
    analysis['daily_trend'] = _calculateDailyCostTrend(filteredCalls, start, end);
    
    // Usage patterns
    analysis['usage_patterns'] = _analyzeUsagePatterns(filteredCalls);
    
    // Efficiency metrics
    analysis['efficiency_metrics'] = _calculateEfficiencyMetrics(filteredCalls);
    
    return analysis;
  }

  /// Get budget status and alerts
  Map<String, dynamic> getBudgetStatus() {
    final today = DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1);
    
    final monthlySpend = _calculateSpendForPeriod(monthStart, today);
    final dailySpend = _calculateSpendForPeriod(
      DateTime(today.year, today.month, today.day),
      today,
    );
    
    return {
      'monthly_budget': _monthlyBudget,
      'monthly_spend': monthlySpend,
      'monthly_remaining': _monthlyBudget - monthlySpend,
      'monthly_utilization': monthlySpend / _monthlyBudget,
      'daily_budget_limit': _dailyBudgetLimit,
      'daily_spend': dailySpend,
      'daily_remaining': _dailyBudgetLimit - dailySpend,
      'daily_utilization': dailySpend / _dailyBudgetLimit,
      'budget_alerts': _generateBudgetAlerts(monthlySpend, dailySpend),
      'projected_monthly_spend': _projectMonthlySpend(monthlySpend, today),
    };
  }

  /// Export cost data for analysis
  Future<Map<String, dynamic>> exportCostData({
    DateTime? startDate,
    DateTime? endDate,
    String? format,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();
    
    final exportData = <String, dynamic>{};
    
    exportData['metadata'] = {
      'exported_at': DateTime.now().toIso8601String(),
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
      'format': format ?? 'json',
    };
    
    exportData['summary'] = await getCostAnalysis(
      startDate: start,
      endDate: end,
    );
    
    exportData['api_calls'] = _filterApiCallsByDateRange(start, end, null)
        .map((call) => call.toJson())
        .toList();
    
    exportData['optimization_recommendations'] = 
        (await getOptimizationRecommendations())
            .map((rec) => rec.toJson())
            .toList();
    
    return exportData;
  }

  /// Clear old cost data to manage memory
  void cleanupOldData({Duration? retention}) {
    final retentionPeriod = retention ?? const Duration(days: 90);
    final cutoffDate = DateTime.now().subtract(retentionPeriod);
    
    // Clean API calls
    for (final serviceCalls in _apiCalls.values) {
      serviceCalls.removeWhere((call) => call.timestamp.isBefore(cutoffDate));
    }
    
    // Clean daily costs
    _dailyCosts.removeWhere((dateKey, breakdown) => 
        DateTime.parse('${dateKey}T00:00:00Z').isBefore(cutoffDate));
    
    AppLogger.info('🧹 Cleaned up cost data older than ${retentionPeriod.inDays} days');
  }

  /// Dispose of resources
  void dispose() {
    _apiCalls.clear();
    _costsByService.clear();
    _dailyCosts.clear();
    _optimizationStrategies.clear();
    _serviceBudgets.clear();
  }

  // Private methods

  double _calculateCallCost(String service, String operation, int tokenCount) {
    final baseCost = _baseCosts[service] ?? 0.01;
    return (baseCost * tokenCount) / 1000; // Most APIs are priced per 1K tokens/characters
  }

  int _getTotalApiCalls() {
    return _apiCalls.values.fold(0, (sum, calls) => sum + calls.length);
  }

  double _getTotalCost() {
    return _costsByService.values.fold(0.0, (sum, cost) => sum + cost);
  }

  double _calculateTotalSavings() {
    // Calculate savings from content reuse and optimization
    // This is a simplified calculation
    final totalCost = _getTotalCost();
    return totalCost * 0.15; // Assume 15% savings from optimization
  }

  double _calculateReuseRate() {
    // Calculate content reuse rate based on API call patterns
    // This is a simplified calculation
    final totalCalls = _getTotalApiCalls();
    if (totalCalls == 0) return 0.0;
    
    // Estimate reuse based on similar API calls
    int reusedCalls = 0;
    for (final serviceCalls in _apiCalls.values) {
      final operationCounts = <String, int>{};
      for (final call in serviceCalls) {
        operationCounts[call.operation] = (operationCounts[call.operation] ?? 0) + 1;
      }
      
      // Count repeated operations as potential reuse
      for (final count in operationCounts.values) {
        if (count > 1) {
          reusedCalls += count - 1; // First call is original, rest are reuse
        }
      }
    }
    
    return reusedCalls / totalCalls;
  }

  Map<String, double> _getDailyCostsSummary() {
    return _dailyCosts.map((date, breakdown) => 
        MapEntry(date, breakdown.totalCost));
  }

  double _calculateOptimizationPotential() {
    final totalCost = _getTotalCost();
    final currentSavings = _calculateTotalSavings();
    return (totalCost * _targetSavingsPercentage) - currentSavings;
  }

  double _calculateBudgetUtilization() {
    final monthlySpend = _calculateSpendForPeriod(
      DateTime(DateTime.now().year, DateTime.now().month, 1),
      DateTime.now(),
    );
    return monthlySpend / _monthlyBudget;
  }

  Map<String, dynamic> _getEfficiencyMetrics() {
    return {
      'cost_per_api_call': _getTotalApiCalls() > 0 ? _getTotalCost() / _getTotalApiCalls() : 0.0,
      'tokens_per_dollar': _calculateTokensPerDollar(),
      'service_efficiency': _calculateServiceEfficiency(),
      'optimization_score': _calculateOptimizationScore(),
    };
  }

  double _calculateTokensPerDollar() {
    final totalTokens = _apiCalls.values
        .expand((calls) => calls)
        .fold(0, (sum, call) => sum + call.tokenCount);
    final totalCost = _getTotalCost();
    return totalCost > 0 ? totalTokens / totalCost : 0.0;
  }

  Map<String, double> _calculateServiceEfficiency() {
    final efficiency = <String, double>{};
    
    for (final service in _apiCalls.keys) {
      final serviceCalls = _apiCalls[service]!;
      final totalTokens = serviceCalls.fold(0, (sum, call) => sum + call.tokenCount);
      final totalCost = serviceCalls.fold(0.0, (sum, call) => sum + call.cost);
      
      efficiency[service] = totalCost > 0 ? totalTokens / totalCost : 0.0;
    }
    
    return efficiency;
  }

  double _calculateOptimizationScore() {
    final reuseRate = _calculateReuseRate();
    final budgetUtilization = _calculateBudgetUtilization();
    final savingsRate = _calculateTotalSavings() / math.max(_getTotalCost(), 1.0);
    
    // Weighted optimization score
    return (reuseRate * 0.4) + 
           ((1.0 - budgetUtilization) * 0.3) + 
           (savingsRate * 0.3);
  }

  Future<void> _checkOptimizationOpportunities(String service, ApiCall apiCall) async {
    // Check for similar recent calls that could have been reused
    final recentCalls = _apiCalls[service]
        ?.where((call) => 
            call.operation == apiCall.operation &&
            DateTime.now().difference(call.timestamp).inHours < 24)
        .toList() ?? [];
    
    if (recentCalls.length > 5) {
      AppLogger.warning('🔍 Optimization opportunity: High frequency of similar $service calls');
    }
  }

  Future<void> _checkBudgetAlerts(double cost) async {
    final today = DateTime.now();
    final dailySpend = _calculateSpendForPeriod(
      DateTime(today.year, today.month, today.day),
      today,
    );
    
    if (dailySpend > _dailyBudgetLimit * 0.9) {
      AppLogger.warning('⚠️ Daily budget alert: ${(dailySpend / _dailyBudgetLimit * 100).toStringAsFixed(1)}% utilized');
    }
  }

  void _recordCostSavings(String service, double savings) {
    // Record savings in optimization strategies
    final strategy = _optimizationStrategies.putIfAbsent(service, () => OptimizationStrategy(
      service: service,
      strategy: 'content_reuse',
      totalSavings: 0.0,
      implementedAt: DateTime.now(),
    ));
    
    strategy.totalSavings += savings;
  }

  List<ApiCall> _filterApiCallsByDateRange(DateTime start, DateTime end, String? service) {
    final filteredCalls = <ApiCall>[];
    
    for (final entry in _apiCalls.entries) {
      if (service != null && entry.key != service) continue;
      
      for (final call in entry.value) {
        if (call.timestamp.isAfter(start) && call.timestamp.isBefore(end)) {
          filteredCalls.add(call);
        }
      }
    }
    
    return filteredCalls;
  }

  double _calculateTotalCostForCalls(List<ApiCall> calls) {
    return calls.fold(0.0, (sum, call) => sum + call.cost);
  }

  Map<String, double> _groupCostsByService(List<ApiCall> calls) {
    final costs = <String, double>{};
    for (final call in calls) {
      costs[call.service] = (costs[call.service] ?? 0.0) + call.cost;
    }
    return costs;
  }

  Map<String, double> _groupCostsByOperation(List<ApiCall> calls) {
    final costs = <String, double>{};
    for (final call in calls) {
      costs[call.operation] = (costs[call.operation] ?? 0.0) + call.cost;
    }
    return costs;
  }

  List<Map<String, dynamic>> _calculateDailyCostTrend(
    List<ApiCall> calls,
    DateTime start,
    DateTime end,
  ) {
    final dailyCosts = <String, double>{};
    
    for (final call in calls) {
      final dateKey = _formatDate(call.timestamp);
      dailyCosts[dateKey] = (dailyCosts[dateKey] ?? 0.0) + call.cost;
    }
    
    final trend = <Map<String, dynamic>>[];
    for (DateTime date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
      final dateKey = _formatDate(date);
      trend.add({
        'date': dateKey,
        'cost': dailyCosts[dateKey] ?? 0.0,
      });
    }
    
    return trend;
  }

  Map<String, dynamic> _analyzeUsagePatterns(List<ApiCall> calls) {
    final hourlyUsage = <int, int>{};
    final operationFrequency = <String, int>{};
    
    for (final call in calls) {
      final hour = call.timestamp.hour;
      hourlyUsage[hour] = (hourlyUsage[hour] ?? 0) + 1;
      operationFrequency[call.operation] = (operationFrequency[call.operation] ?? 0) + 1;
    }
    
    return {
      'peak_hours': _findPeakHours(hourlyUsage),
      'most_frequent_operations': _getMostFrequentOperations(operationFrequency),
      'usage_distribution': hourlyUsage,
    };
  }

  Map<String, dynamic> _calculateEfficiencyMetrics(List<ApiCall> calls) {
    if (calls.isEmpty) return {};
    
    final totalCost = calls.fold(0.0, (sum, call) => sum + call.cost);
    final totalTokens = calls.fold(0, (sum, call) => sum + call.tokenCount);
    
    return {
      'average_cost_per_call': totalCost / calls.length,
      'average_tokens_per_call': totalTokens / calls.length,
      'tokens_per_dollar': totalCost > 0 ? totalTokens / totalCost : 0.0,
      'cost_efficiency_score': _calculateCostEfficiencyScore(calls),
    };
  }

  double _calculateSpendForPeriod(DateTime start, DateTime end) {
    final calls = _filterApiCallsByDateRange(start, end, null);
    return _calculateTotalCostForCalls(calls);
  }

  List<String> _generateBudgetAlerts(double monthlySpend, double dailySpend) {
    final alerts = <String>[];
    
    if (monthlySpend > _monthlyBudget * 0.9) {
      alerts.add('Monthly budget 90% utilized');
    }
    
    if (dailySpend > _dailyBudgetLimit) {
      alerts.add('Daily budget limit exceeded');
    }
    
    if (monthlySpend > _monthlyBudget) {
      alerts.add('Monthly budget exceeded');
    }
    
    return alerts;
  }

  double _projectMonthlySpend(double currentSpend, DateTime today) {
    final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    final dayOfMonth = today.day;
    
    if (dayOfMonth == 0) return currentSpend;
    
    return (currentSpend / dayOfMonth) * daysInMonth;
  }

  Future<List<OptimizationRecommendation>> _analyzeApiUsagePatterns() async {
    final recommendations = <OptimizationRecommendation>[];
    
    // Analyze high-frequency similar calls
    for (final entry in _apiCalls.entries) {
      final service = entry.key;
      final calls = entry.value;
      
      final operationCounts = <String, int>{};
      for (final call in calls) {
        operationCounts[call.operation] = (operationCounts[call.operation] ?? 0) + 1;
      }
      
      for (final opEntry in operationCounts.entries) {
        if (opEntry.value > 10) { // High frequency threshold
          recommendations.add(OptimizationRecommendation(
            id: 'api_pattern_${service}_${opEntry.key}',
            title: 'High Frequency API Usage',
            description: 'Consider caching results for ${opEntry.key} operations',
            category: 'api_optimization',
            potentialSavings: opEntry.value * 0.5, // Estimate 50% savings from caching
            implementation: 'Implement response caching for repeated ${opEntry.key} calls',
            priority: 'medium',
          ));
        }
      }
    }
    
    return recommendations;
  }

  Future<List<OptimizationRecommendation>> _analyzeContentReuseOpportunities() async {
    final recommendations = <OptimizationRecommendation>[];
    
    // This would analyze content patterns and suggest reuse opportunities
    recommendations.add(OptimizationRecommendation(
      id: 'content_reuse_general',
      title: 'Increase Content Reuse Rate',
      description: 'Current reuse rate is ${(_calculateReuseRate() * 100).toStringAsFixed(1)}%. Target: 80%+',
      category: 'content_optimization',
      potentialSavings: _getTotalCost() * 0.15,
      implementation: 'Implement semantic content matching and segment reuse',
      priority: 'high',
    ));
    
    return recommendations;
  }

  Future<List<OptimizationRecommendation>> _analyzeServiceEfficiency() async {
    final recommendations = <OptimizationRecommendation>[];
    
    // Analyze service efficiency and suggest alternatives
    final efficiency = _calculateServiceEfficiency();
    
    for (final entry in efficiency.entries) {
      if (entry.value < 100) { // Low efficiency threshold
        recommendations.add(OptimizationRecommendation(
          id: 'service_efficiency_${entry.key}',
          title: 'Low Service Efficiency',
          description: '${entry.key} has low tokens-per-dollar ratio',
          category: 'service_optimization',
          potentialSavings: _costsByService[entry.key]! * 0.20,
          implementation: 'Consider alternative providers or optimize prompts',
          priority: 'medium',
        ));
      }
    }
    
    return recommendations;
  }

  Future<List<OptimizationRecommendation>> _analyzeBudgetOptimization() async {
    final recommendations = <OptimizationRecommendation>[];
    
    final budgetStatus = getBudgetStatus();
    final utilization = budgetStatus['monthly_utilization'] as double;
    
    if (utilization > 0.8) {
      recommendations.add(OptimizationRecommendation(
        id: 'budget_optimization',
        title: 'High Budget Utilization',
        description: 'Monthly budget is ${(utilization * 100).toStringAsFixed(1)}% utilized',
        category: 'budget_management',
        potentialSavings: _monthlyBudget * 0.10,
        implementation: 'Implement aggressive cost optimization strategies',
        priority: 'high',
      ));
    }
    
    return recommendations;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<int> _findPeakHours(Map<int, int> hourlyUsage) {
    final sortedHours = hourlyUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedHours.take(3).map((e) => e.key).toList();
  }

  List<String> _getMostFrequentOperations(Map<String, int> operationFrequency) {
    final sortedOps = operationFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedOps.take(5).map((e) => e.key).toList();
  }

  double _calculateCostEfficiencyScore(List<ApiCall> calls) {
    // Calculate a normalized efficiency score
    // This is a simplified implementation
    final avgCost = calls.fold(0.0, (sum, call) => sum + call.cost) / calls.length;
    return math.max(0.0, math.min(1.0, 1.0 - (avgCost / 0.10))); // Normalize against 10 cent baseline
  }
}

// Supporting data classes

class ApiCall {
  final String id;
  final String service;
  final String operation;
  final int tokenCount;
  final double cost;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ApiCall({
    required this.id,
    required this.service,
    required this.operation,
    required this.tokenCount,
    required this.cost,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'service': service,
    'operation': operation,
    'token_count': tokenCount,
    'cost': cost,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

class CostBreakdown {
  final String date;
  double totalCost;
  Map<String, double> serviceBreakdown;

  CostBreakdown({
    required this.date,
    required this.totalCost,
    required this.serviceBreakdown,
  });
}

class ContentReuseEvent {
  final String id;
  final String contentId;
  final String originalService;
  final double estimatedSavings;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ContentReuseEvent({
    required this.id,
    required this.contentId,
    required this.originalService,
    required this.estimatedSavings,
    required this.timestamp,
    this.metadata = const {},
  });
}

class OptimizationStrategy {
  final String service;
  final String strategy;
  double totalSavings;
  final DateTime implementedAt;

  OptimizationStrategy({
    required this.service,
    required this.strategy,
    required this.totalSavings,
    required this.implementedAt,
  });
}

class OptimizationRecommendation {
  final String id;
  final String title;
  final String description;
  final String category;
  final double potentialSavings;
  final String implementation;
  final String priority;

  OptimizationRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.potentialSavings,
    required this.implementation,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'potential_savings': potentialSavings,
    'implementation': implementation,
    'priority': priority,
  };
}
