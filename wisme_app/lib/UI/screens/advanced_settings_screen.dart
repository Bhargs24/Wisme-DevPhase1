import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
// TODO: Replace with UserManager import
// TODO: Replace with AudioManager import
import '../widgets/modern_components.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings state
  bool notificationsEnabled = true;
  bool offlineDownloads = true;
  bool analyticsSharing = false;
  bool autoPlayNext = true;
  bool showTranscripts = true;
  bool darkMode = false;
  double audioQuality = 1.0; // 0.5 = low, 1.0 = high, 1.5 = ultra
  double playbackSpeed = 1.0;
  String language = 'English';
  String theme = 'system';

  final List<Map<String, dynamic>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
    {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
    {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildUserProfile(),
                      const SizedBox(height: 24),
                      _buildNotificationSettings(),
                      const SizedBox(height: 24),
                      _buildAudioSettings(),
                      const SizedBox(height: 24),
                      _buildLearningSettings(),
                      const SizedBox(height: 24),
                      _buildAppearanceSettings(),
                      const SizedBox(height: 24),
                      _buildPrivacySettings(),
                      const SizedBox(height: 24),
                      _buildAdvancedOptions(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: AppTextStyles.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Customize your Wisme experience',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Builder( // TODO: Replace Consumer<UserProvider> with UserManager
        builder: (context) {
          return ModernCard(
            backgroundColor: AppColors.primary.withValues(alpha: 0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                      ),
                      child: const Center(
                        child: Text('😊', style: TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learner', // TODO: userProvider.currentUser?.displayName ?? 'Learner',
                            style: AppTextStyles.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'user@example.com', // TODO: userProvider.currentUser?.email ?? 'user@example.com',
                            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Premium Member',
                              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editProfile(),
                      icon: Icon(Icons.edit, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat('🔥', '7', 'Day Streak'),
                    _buildProfileStat('📚', '23', 'Lessons'),
                    _buildProfileStat('⏱️', '12.5h', 'Total Time'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSettingsSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Get reminders and updates',
          value: notificationsEnabled,
          onChanged: (value) => setState(() => notificationsEnabled = value),
        ),
        _buildSwitchTile(
          title: 'Learning Reminders',
          subtitle: 'Daily learning streak reminders',
          value: true,
          onChanged: (value) {},
        ),
        _buildSwitchTile(
          title: 'Achievement Alerts',
          subtitle: 'Get notified when you unlock achievements',
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildAudioSettings() {
    return _buildSettingsSection(
      title: 'Audio & Voice',
      icon: Icons.volume_up,
      children: [
        _buildSliderTile(
          title: 'Audio Quality',
          subtitle: _getAudioQualityText(),
          value: audioQuality,
          min: 0.5,
          max: 1.5,
          divisions: 2,
          onChanged: (value) => setState(() => audioQuality = value),
        ),
        _buildSliderTile(
          title: 'Playback Speed',
          subtitle: '${playbackSpeed.toStringAsFixed(1)}x',
          value: playbackSpeed,
          min: 0.5,
          max: 2.0,
          divisions: 6,
          onChanged: (value) => setState(() => playbackSpeed = value),
        ),
        _buildTapTile(
          title: 'Voice Coach',
          subtitle: 'Change your AI coach voice',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showVoiceSelection(),
        ),
      ],
    );
  }

  Widget _buildLearningSettings() {
    return _buildSettingsSection(
      title: 'Learning Experience',
      icon: Icons.school,
      children: [
        _buildSwitchTile(
          title: 'Auto-play Next Lesson',
          subtitle: 'Automatically start the next lesson',
          value: autoPlayNext,
          onChanged: (value) => setState(() => autoPlayNext = value),
        ),
        _buildSwitchTile(
          title: 'Show Transcripts',
          subtitle: 'Display text while listening',
          value: showTranscripts,
          onChanged: (value) => setState(() => showTranscripts = value),
        ),
        _buildSwitchTile(
          title: 'Offline Downloads',
          subtitle: 'Download lessons for offline learning',
          value: offlineDownloads,
          onChanged: (value) => setState(() => offlineDownloads = value),
        ),
        _buildTapTile(
          title: 'Language',
          subtitle: language,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageSelection(),
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return _buildSettingsSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        _buildTapTile(
          title: 'Theme',
          subtitle: theme == 'system' ? 'Follow system' : theme,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showThemeSelection(),
        ),
        _buildSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Use dark theme',
          value: darkMode,
          onChanged: (value) => setState(() => darkMode = value),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSettingsSection(
      title: 'Privacy & Data',
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          title: 'Analytics Sharing',
          subtitle: 'Help improve Wisme with usage data',
          value: analyticsSharing,
          onChanged: (value) => setState(() => analyticsSharing = value),
        ),
        _buildTapTile(
          title: 'Data Usage',
          subtitle: 'See how your data is used',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDataUsage(),
        ),
        _buildTapTile(
          title: 'Export Data',
          subtitle: 'Download your learning data',
          trailing: const Icon(Icons.download, size: 16),
          onTap: () => _exportData(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return _buildSettingsSection(
      title: 'Advanced',
      icon: Icons.settings_applications,
      children: [
        _buildTapTile(
          title: 'Cache Management',
          subtitle: 'Clear downloaded content',
          trailing: const Icon(Icons.storage, size: 16),
          onTap: () => _manageClearCache(),
        ),
        _buildTapTile(
          title: 'Backup & Sync',
          subtitle: 'Cloud backup settings',
          trailing: const Icon(Icons.cloud_sync, size: 16),
          onTap: () => _showBackupSettings(),
        ),
        _buildTapTile(
          title: 'Developer Options',
          subtitle: 'Advanced debugging features',
          trailing: const Icon(Icons.developer_mode, size: 16),
          onTap: () => _showDeveloperOptions(),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ModernCard(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ModernButton(
          text: 'Save Changes',
          width: double.infinity,
          onPressed: () => _saveSettings(),
          icon: Icons.save,
        ),
        const SizedBox(height: 12),
        ModernButton(
          text: 'Reset to Defaults',
          width: double.infinity,
          onPressed: () => _resetSettings(),
          isPrimary: false,
          icon: Icons.restore,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ModernButton(
                text: 'Help & Support',
                onPressed: () => _showSupport(),
                isPrimary: false,
                icon: Icons.help,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModernButton(
                text: 'About Wisme',
                onPressed: () => _showAbout(),
                isPrimary: false,
                icon: Icons.info,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getAudioQualityText() {
    if (audioQuality <= 0.5) return 'Low (saves data)';
    if (audioQuality <= 1.0) return 'High (recommended)';
    return 'Ultra (premium quality)';
  }

  void _editProfile() {
    // Navigate to profile editing
  }

  void _showVoiceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<VoiceProvider>(
        builder: (context, voiceProvider, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Voice Coach',
                  style: AppTextStyles.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Voice options would go here
                ModernButton(
                  text: 'Preview Voices',
                  width: double.infinity,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...languages.map((lang) => ListTile(
              leading: Text(lang['flag'], style: const TextStyle(fontSize: 24)),
              title: Text(lang['name']),
              trailing: language == lang['name'] 
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => language = lang['name']);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showThemeSelection() {
    // Show theme selection dialog
  }

  void _showDataUsage() {
    // Show data usage information
  }

  void _exportData() {
    // Export user data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export started! Check your downloads.')),
    );
  }

  void _manageClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove all downloaded content. You can re-download it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Clear',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBackupSettings() {
    // Show backup and sync settings
  }

  void _showDeveloperOptions() {
    // Show developer options
  }

  void _saveSettings() {
    // Save all settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!')),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will reset all settings to their default values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Reset',
            onPressed: () {
              // Reset all settings to defaults
              setState(() {
                notificationsEnabled = true;
                offlineDownloads = true;
                analyticsSharing = false;
                autoPlayNext = true;
                showTranscripts = true;
                audioQuality = 1.0;
                playbackSpeed = 1.0;
                language = 'English';
                theme = 'system';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    // Show help and support
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('About Wisme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            const SizedBox(height: 8),
            Text('AI-Powered Microlearning Platform'),
            const SizedBox(height: 16),
            Text('© 2024 Wisme. All rights reserved.'),
          ],
        ),
        actions: [
          ModernButton(
            text: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
