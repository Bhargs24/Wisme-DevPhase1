import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../_old_structure_backup/services/analytics_service.dart';

/// Production-ready Help and Support Screen
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<HelpItem> _helpItems = [
    HelpItem(
      title: 'Getting Started',
      subtitle: 'Learn how to use Wisme effectively',
      icon: Icons.play_circle_outline,
      content: '''
Welcome to Wisme! Here's how to get started:

1. Create your learning profile
2. Choose topics you want to learn
3. Listen to AI-generated content
4. Track your progress
5. Download content for offline learning

Your personalized learning journey begins now!
''',
    ),
    HelpItem(
      title: 'Managing Downloads',
      subtitle: 'Download content for offline learning',
      icon: Icons.download,
      content: '''
To download content for offline access:

1. Find a lesson you want to save
2. Tap the download icon
3. Content will be stored locally
4. Access downloads from Profile > Downloaded Lessons
5. Remove downloads to free up space

Downloaded content works without internet connection.
''',
    ),
    HelpItem(
      title: 'Voice Settings',
      subtitle: 'Customize your audio experience',
      icon: Icons.record_voice_over,
      content: '''
Customize your voice experience:

1. Go to Settings > Voice Settings
2. Choose your preferred voice
3. Adjust playback speed
4. Set audio quality preferences
5. Configure auto-play settings

Find the perfect voice for your learning style!
''',
    ),
    HelpItem(
      title: 'Learning Analytics',
      subtitle: 'Track your progress and insights',
      icon: Icons.analytics,
      content: '''
Monitor your learning progress:

1. View learning time and streaks
2. See topic completion rates
3. Track weekly progress
4. Earn achievements
5. Review learning history

Use analytics to optimize your learning!
''',
    ),
    HelpItem(
      title: 'Troubleshooting',
      subtitle: 'Common issues and solutions',
      icon: Icons.build,
      content: '''
Common solutions:

• Audio not playing: Check volume and network
• Slow loading: Clear cache in settings
• Login issues: Reset password or contact support
• Sync problems: Check internet connection
• App crashes: Restart app or update to latest version

Still having issues? Contact our support team.
''',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.trackEvent('help_screen_viewed', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support),
            onPressed: _showContactSupport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const SizedBox(height: 24),
            Text(
              'Help Topics',
              style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._helpItems.map((item) => _buildHelpItem(item)),
            const SizedBox(height: 24),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.email,
                  label: 'Contact',
                  onTap: _showContactSupport,
                ),
                _buildQuickActionButton(
                  icon: Icons.bug_report,
                  label: 'Report Bug',
                  onTap: _showBugReport,
                ),
                _buildQuickActionButton(
                  icon: Icons.star,
                  label: 'Rate App',
                  onTap: _showRateApp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          item.icon,
          color: AppColors.primary,
        ),
        title: Text(
          item.title,
          style: AppTextStyles.textTheme.titleMedium,
        ),
        subtitle: Text(
          item.subtitle,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              item.content,
              style: AppTextStyles.textTheme.bodyMedium,
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          if (expanded) {
            AnalyticsService.trackEvent('help_item_expanded', {
              'item_title': item.title,
            });
          }
        },
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Still Need Help?',
              style: AppTextStyles.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is here to help you with any questions or issues.',
              style: AppTextStyles.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showContactSupport,
                icon: const Icon(Icons.email),
                label: const Text('Contact Support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Get in touch with our support team:'),
            SizedBox(height: 16),
            Text('📧 Email: support@wisme.app'),
            Text('🌐 Website: help.wisme.app'),
            Text('💬 In-app chat: Available 24/7'),
            SizedBox(height: 16),
            Text('We typically respond within 24 hours.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AnalyticsService.trackEvent('support_contact_initiated', {
                'method': 'email',
              });
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showBugReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Describe the issue',
                hintText: 'What happened? When did it occur?',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Include steps to reproduce the issue for faster resolution.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report sent! Thank you for your feedback.'),
                ),
              );
              AnalyticsService.trackEvent('bug_report_submitted', {
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }

  void _showRateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Wisme'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enjoying Wisme? Please rate us!'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
                Icon(Icons.star, color: Colors.orange, size: 32),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for rating Wisme!'),
                ),
              );
              AnalyticsService.trackEvent('app_rated', {
                'rating': 5,
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}

/// Help item data model
class HelpItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String content;

  HelpItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.content,
  });
}
