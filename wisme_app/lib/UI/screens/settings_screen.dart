import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes.dart';
import '../../services/cache_service.dart';
import '../../services/performance_service.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_services.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _downloadOnWifi = true;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Preferences
          _buildSectionHeader('App Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive learning reminders and updates'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme for the app'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Download on WiFi only'),
                  subtitle: const Text('Save mobile data by downloading content only on WiFi'),
                  value: _downloadOnWifi,
                  onChanged: (value) {
                    setState(() {
                      _downloadOnWifi = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Playback Settings
          _buildSectionHeader('Playback'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Playback Speed'),
                  subtitle: Text('${_playbackSpeed}x'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPlaybackSpeedDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Voice Settings'),
                  subtitle: const Text('Manage voice preferences'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.voiceSettings);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account & Data
          _buildSectionHeader('Account & Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Profile'),
                  subtitle: const Text('Manage your profile information'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Learning Data'),
                  subtitle: const Text('View your learning progress and statistics'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.learningData);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up storage space'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearCacheDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy policy screen
                    Navigator.of(context).pushNamed('/privacy_policy');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to terms of service screen
                    Navigator.of(context).pushNamed('/terms_of_service');
                  },
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                  trailing: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign Out
          ElevatedButton(
            onPressed: () => _showSignOutDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.textTheme.titleSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<double>(
                title: const Text('0.5x'),
                value: 0.5,
                groupValue: _playbackSpeed,
                onChanged: (value) => setDialogState(() => _playbackSpeed = value!),
              ),
              RadioListTile<double>(
                title: const Text('1.0x'),
                value: 1.0,
                groupValue: _playbackSpeed,
                onChanged: (value) => setDialogState(() => _playbackSpeed = value!),
              ),
              RadioListTile<double>(
                title: const Text('1.5x'),
                value: 1.5,
                groupValue: _playbackSpeed,
                onChanged: (value) => setDialogState(() => _playbackSpeed = value!),
              ),
              RadioListTile<double>(
                title: const Text('2.0x'),
                value: 2.0,
                groupValue: _playbackSpeed,
                onChanged: (value) => setDialogState(() => _playbackSpeed = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove all downloaded content and cached data. You can re-download content later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Clear all caches using production services
                await context.read<CacheService>().clearCache();
                await PerformanceService.clearAllCache();
                await AnalyticsService.clearLocalAnalytics();
                
                // Track cache clearing
                AnalyticsService.trackEvent('cache_cleared', {
                  'user_action': true,
                  'timestamp': DateTime.now().toIso8601String(),
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear cache: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear'),
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
        content: const Text('Are you sure you want to sign out? Your learning progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // End analytics session before sign out
                final userProvider = context.read<UserProvider>();
                if (userProvider.currentUser?.id != null) {
                  AnalyticsService.endSession(userProvider.currentUser!.id);
                }
                
                // Sign out using auth service
                await context.read<AuthService>().signOut();
                
                // Track sign out event
                AnalyticsService.trackEvent('user_signed_out', {
                  'user_action': true,
                  'timestamp': DateTime.now().toIso8601String(),
                });
                
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    AppRoutes.login, 
                    (route) => false
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
