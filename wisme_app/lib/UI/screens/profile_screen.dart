import '../../core/exports.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.voiceSettings),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(context, user.displayName ?? 'User', user.email),
              const SizedBox(height: 24),
              _buildStatsCard(user.completedLessons.length, user.totalLearningTime),
              const SizedBox(height: 16),
              _buildMenuItems(context, userProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int lessonsCompleted, int streakDays) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$lessonsCompleted',
                    style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lessons Completed',
                    style: AppTextStyles.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$streakDays',
                    style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Day Streak',
                    style: AppTextStyles.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, UserProvider userProvider) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.record_voice_over,
          title: 'Voice Settings',
          onTap: () => Navigator.pushNamed(context, AppRoutes.voiceSettings),
        ),
        _buildMenuItem(
          icon: Icons.download,
          title: 'Downloaded Lessons',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.downloads);
          },
        ),
        _buildMenuItem(
          icon: Icons.favorite,
          title: 'Favorites',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.favorites);
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: 'Learning History',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.learningHistory);
          },
        ),
        _buildMenuItem(
          icon: Icons.help,
          title: 'Help & Support',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.helpSupport);
          },
        ),
        _buildMenuItem(
          icon: Icons.info,
          title: 'About',
          onTap: () {
            _showAboutDialog(context);
          },
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () => _showLogoutDialog(context, userProvider),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Wisme'),
        content: const Text(
          'Wisme is an AI-powered microlearning app that creates personalized audio lessons on any topic you want to learn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              userProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

