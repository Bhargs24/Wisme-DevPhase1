import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';
import '../../user_manager.dart';
import '../../../app/navigation/app_router.dart';
import '../widgets/user_widgets.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          WismeIconButton(
            icon: Icons.settings,
            onPressed: () {
              AppNavigation.pushNamed(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: UserManager().getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: WismeLoadingIndicator());
          }

          if (snapshot.hasError) {
            return WismeErrorState(
              title: 'Error loading profile',
              subtitle: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }

          final user = snapshot.data;
          if (user == null) {
            return const WismeErrorState(
              title: 'User not found',
              subtitle: 'Please sign in again',
            );
          }

          return _buildProfileContent(user);
        },
      ),
    );
  }

  Widget _buildProfileContent(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(WismeSpacing.lg),
      child: Column(
        children: [
          // Profile header
          _buildProfileHeader(user),
          const SizedBox(height: WismeSpacing.xl),

          // Stats section
          _buildStatsSection(),
          const SizedBox(height: WismeSpacing.lg),

          // Progress section
          _buildProgressSection(),
          const SizedBox(height: WismeSpacing.lg),

          // Achievements section
          _buildAchievementsSection(),
          const SizedBox(height: WismeSpacing.lg),

          // Account section
          _buildAccountSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return WismeCard(
      child: Column(
        children: [
          WismeUserAvatar(
            imageUrl: user.photoUrl,
            name: user.displayName,
            radius: 50,
            showEditIcon: true,
            onTap: () {
              // Edit profile picture
            },
          ),
          const SizedBox(height: WismeSpacing.md),
          Text(
            user.displayName ?? 'User',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: WismeSpacing.xs),
          Text(
            user.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: WismeSpacing.md),
          WismeSecondaryButton(
            text: 'Edit Profile',
            onPressed: () {
              // Navigate to edit profile
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return WismeSection(
      title: 'Learning Stats',
      child: Row(
        children: [
          Expanded(
            child: WismeStatsCard(
              label: 'Days Streak',
              value: '12',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: WismeSpacing.sm),
          Expanded(
            child: WismeStatsCard(
              label: 'Total Hours',
              value: '45',
              icon: Icons.schedule,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: WismeSpacing.sm),
          Expanded(
            child: WismeStatsCard(
              label: 'Completed',
              value: '28',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return WismeSection(
      title: 'Current Progress',
      child: Column(
        children: [
          WismeProgressCard(
            title: 'Flutter Development',
            progress: 0.75,
            subtitle: '12 of 16 lessons completed',
            icon: Icons.code,
          ),
          const SizedBox(height: WismeSpacing.sm),
          WismeProgressCard(
            title: 'AI & Machine Learning',
            progress: 0.45,
            subtitle: '9 of 20 lessons completed',
            icon: Icons.psychology,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return WismeSection(
      title: 'Achievements',
      action: WismeTextButton(
        text: 'View All',
        onPressed: () {
          AppNavigation.pushNamed(AppRoutes.achievements);
        },
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: WismeSpacing.sm,
        crossAxisSpacing: WismeSpacing.sm,
        children: [
          WismeAchievementBadge(
            title: 'First Steps',
            icon: Icons.baby_changing_station,
            isUnlocked: true,
          ),
          WismeAchievementBadge(
            title: 'Quick Learner',
            icon: Icons.speed,
            isUnlocked: true,
          ),
          WismeAchievementBadge(
            title: 'Streak Master',
            icon: Icons.local_fire_department,
            isUnlocked: false,
          ),
          WismeAchievementBadge(
            title: 'Expert',
            icon: Icons.school,
            isUnlocked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return WismeSection(
      title: 'Account',
      child: Column(
        children: [
          WismeListTile(
            title: const Text('Subscription'),
            subtitle: const Text('Wisme Pro - Active'),
            leading: const Icon(Icons.star),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppNavigation.pushNamed(AppRoutes.subscription);
            },
          ),
          WismeListTile(
            title: const Text('Preferences'),
            subtitle: const Text('Learning settings & notifications'),
            leading: const Icon(Icons.tune),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppNavigation.pushNamed(AppRoutes.preferences);
            },
          ),
          WismeListTile(
            title: const Text('Privacy & Security'),
            subtitle: const Text('Manage your data and privacy'),
            leading: const Icon(Icons.security),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          WismeListTile(
            title: const Text('Sign Out'),
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            onTap: () {
              _showSignOutDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserManager().signOut();
              if (mounted) {
                AppNavigation.pushNamedAndClearStack(AppRoutes.welcome);
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          children: [
            WismeSection(
              title: 'General',
              child: Column(
                children: [
                  WismeSwitchTile(
                    title: 'Dark Mode',
                    subtitle: 'Use dark theme',
                    value: false,
                  ),
                  WismeSwitchTile(
                    title: 'Notifications',
                    subtitle: 'Receive learning reminders',
                    value: true,
                  ),
                  WismeSwitchTile(
                    title: 'Sound Effects',
                    subtitle: 'Play sounds for interactions',
                    value: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subscription screen
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: const Center(
        child: WismeLoadingIndicator(
          message: 'Loading subscription details...',
        ),
      ),
    );
  }
}

/// Preferences screen
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          children: [
            WismeSection(
              title: 'Learning Preferences',
              child: Column(
                children: [
                  WismeSwitchTile(
                    title: 'Daily Reminders',
                    subtitle: 'Remind me to practice daily',
                    value: true,
                  ),
                  WismeSwitchTile(
                    title: 'Progress Tracking',
                    subtitle: 'Track my learning progress',
                    value: true,
                  ),
                  WismeSwitchTile(
                    title: 'Adaptive Difficulty',
                    subtitle: 'Adjust difficulty based on performance',
                    value: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await UserManager().completeOnboarding();
    if (mounted) {
      AppNavigation.pushNamedAndClearStack(AppRoutes.assessment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  OnboardingPage(
                    title: 'Welcome to Wisme',
                    subtitle: 'Your AI-powered learning companion',
                    icon: Icons.school,
                  ),
                  OnboardingPage(
                    title: 'Personalized Learning',
                    subtitle: 'Adaptive content that grows with you',
                    icon: Icons.psychology,
                  ),
                  OnboardingPage(
                    title: 'Track Progress',
                    subtitle: 'See your growth and achievements',
                    icon: Icons.trending_up,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(WismeSpacing.lg),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: WismeSpacing.lg),
                  
                  // Next button
                  WismePrimaryButton(
                    text: _currentPage < 2 ? 'Next' : 'Get Started',
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual onboarding page
class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WismeSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: WismeSpacing.xl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WismeSpacing.md),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Assessment screen
class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Assessment'),
      ),
      body: const Center(
        child: WismeLoadingIndicator(
          message: 'Preparing your assessment...',
        ),
      ),
    );
  }
}
