import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';

/// Analytics home screen
class AnalyticsHomeScreen extends StatelessWidget {
  const AnalyticsHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading analytics...'),
      ),
    );
  }
}

/// Progress screen
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading progress...'),
      ),
    );
  }
}

/// Achievements screen
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading achievements...'),
      ),
    );
  }
}

/// Insights screen
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading insights...'),
      ),
    );
  }
}
