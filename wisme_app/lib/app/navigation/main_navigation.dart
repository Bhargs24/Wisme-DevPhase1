import 'package:flutter/material.dart';
import '../../shared/ui/widgets/widgets.dart';
import '../../shared/ui/theme/app_theme.dart';
import '../../user/user_manager.dart';
import '../../analytics/analytics_manager.dart';
import '../navigation/app_router.dart';

/// Main app navigation structure
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: 'Learn',
    ),
    const NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'Coach',
    ),
    const NavigationDestination(
      icon: Icon(Icons.library_books_outlined),
      selectedIcon: Icon(Icons.library_books),
      label: 'Library',
    ),
    const NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Progress',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _trackNavigation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _trackNavigation() {
    final analytics = AnalyticsManager();
    analytics.trackScreenView(_getScreenName(_currentIndex));
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0: return 'home';
      case 1: return 'learning';
      case 2: return 'coach';
      case 3: return 'content';
      case 4: return 'analytics';
      default: return 'unknown';
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _trackNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _trackNavigation();
        },
        children: const [
          HomeTabView(),
          LearningTabView(),
          CoachTabView(),
          ContentTabView(),
          AnalyticsTabView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: _destinations,
      ),
    );
  }
}

/// Home tab view
class HomeTabView extends StatelessWidget {
  const HomeTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisme'),
        actions: [
          WismeIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () {
              // Navigate to notifications
            },
          ),
          WismeIconButton(
            icon: Icons.account_circle_outlined,
            onPressed: () {
              AppNavigation.pushNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: const HomeScreenContent(),
    );
  }
}

/// Learning tab view
class LearningTabView extends StatelessWidget {
  const LearningTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning'),
        actions: [
          WismeIconButton(
            icon: Icons.search,
            onPressed: () {
              // Open search
            },
          ),
        ],
      ),
      body: const LearningScreenContent(),
    );
  }
}

/// Coach tab view
class CoachTabView extends StatelessWidget {
  const CoachTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Coach'),
        actions: [
          WismeIconButton(
            icon: Icons.settings_outlined,
            onPressed: () {
              // Coach settings
            },
          ),
        ],
      ),
      body: const CoachScreenContent(),
    );
  }
}

/// Content tab view
class ContentTabView extends StatelessWidget {
  const ContentTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Library'),
        actions: [
          WismeIconButton(
            icon: Icons.filter_list,
            onPressed: () {
              // Open filters
            },
          ),
        ],
      ),
      body: const ContentScreenContent(),
    );
  }
}

/// Analytics tab view
class AnalyticsTabView extends StatelessWidget {
  const AnalyticsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        actions: [
          WismeIconButton(
            icon: Icons.share_outlined,
            onPressed: () {
              // Share progress
            },
          ),
        ],
      ),
      body: const AnalyticsScreenContent(),
    );
  }
}

/// Placeholder content widgets - will be replaced with actual implementations
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: WismeLoadingIndicator(message: 'Loading Home...'),
    );
  }
}

class LearningScreenContent extends StatelessWidget {
  const LearningScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: WismeLoadingIndicator(message: 'Loading Learning...'),
    );
  }
}

class CoachScreenContent extends StatelessWidget {
  const CoachScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: WismeLoadingIndicator(message: 'Loading Coach...'),
    );
  }
}

class ContentScreenContent extends StatelessWidget {
  const ContentScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: WismeLoadingIndicator(message: 'Loading Content...'),
    );
  }
}

class AnalyticsScreenContent extends StatelessWidget {
  const AnalyticsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: WismeLoadingIndicator(message: 'Loading Analytics...'),
    );
  }
}
