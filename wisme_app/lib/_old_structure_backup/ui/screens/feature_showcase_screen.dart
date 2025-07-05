import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes.dart';
import '../widgets/modern_components.dart';

/// Feature showcase screen demonstrating all app capabilities
class FeatureShowcaseScreen extends StatelessWidget {
  const FeatureShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisme Features'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCoreFeatures(context),
            const SizedBox(height: 24),
            _buildPremiumFeatures(context),
            const SizedBox(height: 24),
            _buildAIFeatures(context),
            const SizedBox(height: 24),
            _buildSocialFeatures(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Wisme',
            style: AppTextStyles.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The world\'s most advanced AI-powered microlearning platform',
            style: AppTextStyles.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('🧠', '100+', 'AI Coaches'),
              const SizedBox(width: 12),
              _buildStatChip('📚', '1000+', 'Topics'),
              const SizedBox(width: 12),
              _buildStatChip('⚡', '10min', 'Lessons'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoreFeatures(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Core Learning Features',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              Icons.school,
              'AI Lesson Generation',
              'Create personalized lessons on any topic instantly',
              () => Navigator.pushNamed(context, AppRoutes.topicSelection),
            ),
            _buildFeatureRow(
              Icons.psychology,
              'AI Coach Selection',
              'Choose from different AI personalities for your learning',
              () => Navigator.pushNamed(context, AppRoutes.coachSelection),
            ),
            _buildFeatureRow(
              Icons.route,
              'Learning Journeys',
              'Structured paths to master complex subjects',
              () => Navigator.pushNamed(context, AppRoutes.journeyPlanning),
            ),
            _buildFeatureRow(
              Icons.record_voice_over,
              'Voice Learning',
              'High-quality AI voices with emotion and personality',
              () => Navigator.pushNamed(context, AppRoutes.voiceSettings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Premium Features',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PRO',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              Icons.analytics,
              'Advanced Analytics',
              'Deep insights into your learning patterns and progress',
              () => Navigator.pushNamed(context, AppRoutes.dashboard),
            ),
            _buildFeatureRow(
              Icons.library_books,
              'Content Library',
              'Curated collections and trending topics',
              () => Navigator.pushNamed(context, AppRoutes.contentLibrary),
            ),
            _buildFeatureRow(
              Icons.download,
              'Offline Learning',
              'Download lessons for learning anywhere, anytime',
              () => Navigator.pushNamed(context, AppRoutes.offlineLearning),
            ),
            _buildFeatureRow(
              Icons.multitrack_audio,
              'Enhanced Player',
              'Advanced audio controls with speed, skip, and bookmarks',
              () => Navigator.pushNamed(context, AppRoutes.enhancedAudioPlayer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeatures(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI-Powered Intelligence',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              Icons.auto_awesome,
              'Smart Recommendations',
              'AI suggests the perfect content for your goals',
              () => Navigator.pushNamed(context, AppRoutes.contentLibrary),
            ),
            _buildFeatureRow(
              Icons.insights,
              'Learning Analytics',
              'AI analyzes your progress and optimizes your learning',
              () => Navigator.pushNamed(context, AppRoutes.learningStats),
            ),
            _buildFeatureRow(
              Icons.schedule,
              'Adaptive Scheduling',
              'AI schedules lessons based on your availability and goals',
              () => Navigator.pushNamed(context, AppRoutes.advancedSettings),
            ),
            _buildFeatureRow(
              Icons.psychology_outlined,
              'Personalized Coaching',
              'AI adapts teaching style to your learning preferences',
              () => Navigator.pushNamed(context, AppRoutes.coachNaming),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialFeatures(BuildContext context) {
    return ModernCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Social & Gamification',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow(
              Icons.leaderboard,
              'Social Leaderboard',
              'Compete and connect with learners worldwide',
              () => Navigator.pushNamed(context, AppRoutes.socialLeaderboard),
            ),
            _buildFeatureRow(
              Icons.emoji_events,
              'Achievement System',
              'Unlock badges and celebrate your learning milestones',
              () => Navigator.pushNamed(context, AppRoutes.achievementsGallery),
            ),
            _buildFeatureRow(
              Icons.group,
              'Learning Communities',
              'Join topic-based communities and study groups',
              () => Navigator.pushNamed(context, AppRoutes.socialLeaderboard),
            ),
            _buildFeatureRow(
              Icons.share,
              'Progress Sharing',
              'Share your achievements and inspire others',
              () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
