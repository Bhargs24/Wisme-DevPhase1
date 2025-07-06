import '../../core/exports.dart';

class TopicAnalysisScreen extends StatefulWidget {
  final String searchQuery;
  
  const TopicAnalysisScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<TopicAnalysisScreen> createState() => _TopicAnalysisScreenState();
}

class _TopicAnalysisScreenState extends State<TopicAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _loadingController;
  late AnimationController _resultsController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _resultsAnimation;
  
  TopicAnalysis? _analysis;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _analyzeTopicWithDelay();
  }

  void _setupAnimations() {
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
    _resultsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultsController, curve: Curves.easeOut),
    );
    
    _loadingController.repeat();
  }

  Future<void> _analyzeTopicWithDelay() async {
    // Simulate AI analysis delay for better UX
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final lessonProvider = context.read<LessonProvider>();
      final analysis = await lessonProvider.analyzeTopicIntent(widget.searchQuery);
      
      setState(() {
        _analysis = analysis;
        _isAnalyzing = false;
      });
      
      _loadingController.stop();
      _resultsController.forward();
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _resultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyzing Topic'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isAnalyzing ? _buildAnalyzingView() : _buildResultsView(),
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Thinking Animation
            AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.8),
                        AppColors.accent.withValues(alpha: 0.6),
                      ],
                      transform: GradientRotation(_loadingAnimation.value * 2 * 3.14159),
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 60,
                    color: Colors.white,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Analyzing "${widget.searchQuery}"',
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'AI is understanding your learning intent...',
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Thinking Steps
            _buildThinkingSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingSteps() {
    return Column(
      children: [
        _buildThinkingStep('🔍 Understanding your topic...', 0),
        _buildThinkingStep('🎯 Finding the best category...', 1),
        _buildThinkingStep('📚 Preparing learning options...', 2),
      ],
    );
  }

  Widget _buildThinkingStep(String text, int index) {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        final delay = index * 0.3;
        final progress = (_loadingAnimation.value - delay).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: progress,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: progress > 0.5 ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: progress > 0.5 ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsView() {
    if (_analysis == null) {
      return const Center(child: Text('Analysis failed. Please try again.'));
    }

    return FadeTransition(
      opacity: _resultsAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Perfect! I understand.',
                    style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _analysis!.originalQuery,
                    style: AppTextStyles.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Recommended Category
            Text(
              'Best Learning Category',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ModernCard(
              padding: const EdgeInsets.all(24),
              backgroundColor: AppColors.primary.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(_analysis!.detectedCategory),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _analysis!.detectedCategory,
                              style: AppTextStyles.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _analysis!.knowledgeLevel,
                              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(_analysis!.confidenceScore * 100).toInt()}% match',
                          style: AppTextStyles.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Alternative Categories (if confidence < 90%)
            if (_analysis!.confidenceScore < 0.9) ...[
              Text(
                'Or choose a different focus:',
                style: AppTextStyles.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              ...(_analysis!.suggestedTags.take(3)).map((tag) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAlternativeCategoryCard(tag),
                ),
              ),
              
              const SizedBox(height: 24),
            ],
            
            // Continue Button
            ModernButton(
              text: 'Continue with ${_analysis!.detectedCategory}',
              onPressed: () => _proceedToKnowledgeLevel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeCategoryCard(String category) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.grey.shade50,
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(category),
            color: AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category,
              style: AppTextStyles.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            onPressed: () => _selectAlternativeCategory(category),
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'self-growth':
      case 'self growth':
        return Icons.psychology;
      case 'business & finance':
      case 'business':
        return Icons.business;
      case 'technology':
        return Icons.computer;
      case 'science & nature':
      case 'science':
        return Icons.science;
      case 'creativity & design':
      case 'creativity':
        return Icons.palette;
      case 'history & culture':
      case 'history':
        return Icons.history;
      case 'skills & tools':
      case 'skills':
        return Icons.build;
      case 'career & strategy':
      case 'career':
        return Icons.trending_up;
      default:
        return Icons.school;
    }
  }

  void _selectAlternativeCategory(String category) {
    setState(() {
      _analysis = _analysis!.copyWith(detectedCategory: category);
    });
  }

  void _proceedToKnowledgeLevel() {
    Navigator.pushNamed(
      context,
      AppRoutes.knowledgeLevel,
      arguments: {
        'topic': widget.searchQuery,
        'analysis': _analysis,
      },
    );
  }
}


