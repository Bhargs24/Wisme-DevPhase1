import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../widgets/modern_components.dart';

/// Interactive feature showcase highlighting app capabilities
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<ShowcaseFeature> _features = [
    ShowcaseFeature(
      title: 'AI-Powered Learning',
      subtitle: 'Personalized lessons that adapt to your pace',
      icon: Icons.psychology,
      color: AppColors.primary,
      description: 'Our advanced AI creates custom learning paths tailored to your knowledge level and learning style.',
    ),
    ShowcaseFeature(
      title: 'Smart Audio Coach',
      subtitle: 'Your personal AI voice assistant',
      icon: Icons.record_voice_over,
      color: Colors.purple,
      description: 'Natural voice interactions with advanced text-to-speech and real-time feedback.',
    ),
    ShowcaseFeature(
      title: 'Social Learning',
      subtitle: 'Learn together, achieve more',
      icon: Icons.groups,
      color: Colors.orange,
      description: 'Join a community of learners, compete on leaderboards, and share achievements.',
    ),
    ShowcaseFeature(
      title: 'Offline Ready',
      subtitle: 'Learn anywhere, anytime',
      icon: Icons.offline_pin,
      color: Colors.green,
      description: 'Download lessons for offline access and sync progress when you\'re back online.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/auth-wrapper');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) => _buildFeaturePage(_features[index]),
              ),
            ),
            _buildBottomNavigation(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Discover Wisme',
            style: AppTextStyles.textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/auth-wrapper'),
            child: Text(
              'Skip',
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage(ShowcaseFeature feature) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: feature.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature.icon,
                      size: 60,
                      color: feature.color,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    feature.title,
                    style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    feature.subtitle,
                    style: AppTextStyles.textTheme.titleLarge?.copyWith(
                      color: feature.color,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    feature.description,
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalPages,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ModernButton(
                  text: 'Previous',
                  onPressed: _previousPage,
                  width: 120,
                  isPrimary: false,
                )
              else
                const SizedBox(width: 120),
              
              ModernButton(
                text: _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                onPressed: _nextPage,
                width: 140,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShowcaseFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;

  const ShowcaseFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
  });
}
