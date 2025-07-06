import '../../core/exports.dart';
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      screen: const HomeScreen(),
    ),
    NavigationTab(
      icon: Icons.library_books_outlined,
      selectedIcon: Icons.library_books,
      label: 'Library',
      screen: const ContentLibraryScreen(),
    ),
    NavigationTab(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Dashboard',
      screen: const DashboardScreen(),
    ),
    NavigationTab(
      icon: Icons.leaderboard_outlined,
      selectedIcon: Icons.leaderboard,
      label: 'Social',
      screen: const SocialLeaderboardScreen(),
    ),
    NavigationTab(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      screen: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      _fabAnimationController.reset();
      _fabAnimationController.forward();
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == _selectedIndex;
              
              // Add space for FAB in the middle
              if (index == 2) {
                return const SizedBox(width: 56); // FAB space
              }
              
              return GestureDetector(
                onTap: () => _onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha:0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? tab.selectedIcon : tab.icon,
                        color: isSelected ? AppColors.primary : Colors.grey[600],
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: isSelected ? AppColors.primary : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimation,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _showQuickActions,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Text(
              'Quick Actions',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickAction(
                    icon: Icons.school,
                    label: 'Generate Lesson',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.topicSelection);
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.psychology,
                    label: 'AI Coach',
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.coachSelection);
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.search,
                    label: 'Search',
                    color: AppColors.success,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.search);
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.download,
                    label: 'Offline',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.offlineLearning);
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.settings,
                    label: 'Settings',
                    color: Colors.grey[600]!,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.help,
                    label: 'Help',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help and support
                      Navigator.of(context).pushNamed('/help_support');
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationTab {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  NavigationTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });
}


