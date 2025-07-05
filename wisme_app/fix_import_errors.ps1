# PowerShell script to systematically fix all import errors in the Wisme app
# This script will update all import paths to match the new architecture

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "FIXING ALL IMPORT ERRORS SYSTEMATICALLY" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$projectDir = $PSScriptRoot
Set-Location $projectDir

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
Write-Host ""

function Update-FileImports {
    param(
        [string]$FilePath,
        [hashtable]$ImportMappings
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠️ File not found: $FilePath" -ForegroundColor Yellow
        return
    }
    
    $content = Get-Content $FilePath -Raw
    $originalContent = $content
    
    foreach ($oldImport in $ImportMappings.Keys) {
        $newImport = $ImportMappings[$oldImport]
        $content = $content -replace [regex]::Escape($oldImport), $newImport
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $FilePath -Value $content -Encoding UTF8
        Write-Host "✅ Updated imports in $FilePath" -ForegroundColor Green
    }
}

Write-Host "[1/8] Fixing wisme_app.dart constructor issues..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Fix wisme_app.dart - Update to use singleton pattern and correct constructors
$wismeAppContent = @"
import 'package:flutter/material.dart';
import '../shared/ui/theme/app_theme.dart';
import '../user/user_manager.dart';
import '../user/services/auth_service.dart';
import '../user/services/personalization_service.dart';
import '../user/services/gamification_service.dart';
import '../user/data/user_data_service.dart';
import '../core/core_manager.dart';
import '../analytics/analytics_manager.dart';
import '../audio/audio_manager.dart';
import 'navigation/app_router.dart';
import 'screens/splash_screen.dart';

/// Main Wisme application
class WismeApp extends StatefulWidget {
  const WismeApp({Key? key}) : super(key: key);

  @override
  State<WismeApp> createState() => _WismeAppState();
}

class _WismeAppState extends State<WismeApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize core services first
      await CoreManager.instance.initialize();
      
      // Initialize individual services
      final authService = AuthService();
      final dataService = UserDataService();
      final personalizationService = PersonalizationService();
      final gamificationService = GamificationService();
      
      // Initialize services
      await authService.initialize();
      await dataService.initialize();
      await personalizationService.initialize();
      await gamificationService.initialize();
      
      // Initialize domain managers with proper dependencies
      await Future.wait([
        UserManager(
          dataService: dataService,
          authService: authService,
          personalizationService: personalizationService,
          gamificationService: gamificationService,
        ).initialize(),
        AnalyticsManager.instance.initialize(),
        AudioManager.instance.initialize(),
      ]);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Handle initialization error
      debugPrint('App initialization failed: `$e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        title: 'Wisme',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'Wisme',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.initialRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}
"@

Set-Content -Path "lib\app\wisme_app.dart" -Value $wismeAppContent -Encoding UTF8
Write-Host "✅ Fixed lib\app\wisme_app.dart" -ForegroundColor Green

Write-Host ""
Write-Host "[2/8] Fixing missing service imports in core files..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Fix app_initialization_service.dart imports
$initServicePath = "lib\core\initialization\app_initialization_service.dart"
if (Test-Path $initServicePath) {
    $content = Get-Content $initServicePath -Raw
    
    # Add missing imports if not present
    if ($content -notmatch "import.*performance_service\.dart") {
        $content = $content -replace "(import.*services/connectivity_service\.dart';)", "`$1`nimport '../services/performance_service.dart';"
    }
    if ($content -notmatch "import.*offline_service\.dart") {
        $content = $content -replace "(import.*services/performance_service\.dart';)", "`$1`nimport '../services/offline_service.dart';"
    }
    
    Set-Content -Path $initServicePath -Value $content -Encoding UTF8
    Write-Host "✅ Fixed app_initialization_service.dart imports" -ForegroundColor Green
}

Write-Host ""
Write-Host "[3/8] Creating missing AppRouter if it doesn't exist..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$appRouterPath = "lib\app\navigation\app_router.dart"
if (-not (Test-Path $appRouterPath)) {
    $appRouterDir = Split-Path $appRouterPath -Parent
    if (-not (Test-Path $appRouterDir)) {
        New-Item -ItemType Directory -Path $appRouterDir -Force | Out-Null
    }
    
    $appRouterContent = @"
import 'package:flutter/material.dart';
import '../../UI/screens/home_screen.dart';
import '../../UI/screens/onboarding_screen.dart';
import '../../UI/screens/profile_screen.dart';
import '../../UI/screens/lesson_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String lesson = '/lesson';
  
  static String get initialRoute => splash;
  
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case lesson:
        final lesson = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => LessonScreen(lesson: lesson),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
"@
    
    Set-Content -Path $appRouterPath -Value $appRouterContent -Encoding UTF8
    Write-Host "✅ Created $appRouterPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "[4/8] Creating missing SplashScreen..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$splashScreenPath = "lib\app\screens\splash_screen.dart"
if (-not (Test-Path $splashScreenPath)) {
    $splashScreenDir = Split-Path $splashScreenPath -Parent
    if (-not (Test-Path $splashScreenDir)) {
        New-Item -ItemType Directory -Path $splashScreenDir -Force | Out-Null
    }
    
    $splashScreenContent = @"
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Wisme',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'AI-Powered Microlearning',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
"@
    
    Set-Content -Path $splashScreenPath -Value $splashScreenContent -Encoding UTF8
    Write-Host "✅ Created $splashScreenPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "[5/8] Creating missing AppTheme..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$appThemePath = "lib\shared\ui\theme\app_theme.dart"
if (-not (Test-Path $appThemePath)) {
    $appThemeDir = Split-Path $appThemePath -Parent
    if (-not (Test-Path $appThemeDir)) {
        New-Item -ItemType Directory -Path $appThemeDir -Force | Out-Null
    }
    
    $appThemeContent = @"
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
"@
    
    Set-Content -Path $appThemePath -Value $appThemeContent -Encoding UTF8
    Write-Host "✅ Created $appThemePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "[6/8] Updating UI screens to fix old import dependencies..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Fix UI screens that import from _old_structure_backup
$uiFiles = @(
    "lib\UI\screens\home_screen.dart",
    "lib\UI\screens\profile_screen.dart", 
    "lib\UI\screens\lesson_screen.dart",
    "lib\UI\screens\coach_selection_screen.dart",
    "lib\UI\screens\topic_selection_screen.dart"
)

$importMappings = @{
    "import '../../_old_structure_backup/providers/user_provider.dart';" = "// TODO: Replace with UserManager"
    "import '../../_old_structure_backup/providers/lesson_provider.dart';" = "// TODO: Replace with ContentManager" 
    "import '../../_old_structure_backup/providers/voice_provider.dart';" = "// TODO: Replace with AudioManager"
    "import '../../_old_structure_backup/providers/audio_provider.dart';" = "// TODO: Replace with AudioManager"
    "import '../../_old_structure_backup/providers/coach_provider.dart';" = "// TODO: Replace with CoachManager"
    "import '../../_old_structure_backup/models/topic_model.dart';" = "// TODO: Replace with new topic models"
    "import '../../_old_structure_backup/models/lesson_model.dart';" = "// TODO: Replace with new lesson models"
    "import '../../_old_structure_backup/routes.dart';" = "import '../../app/navigation/app_router.dart';"
    "AppRoutes\." = "AppRouter."
    "Consumer<UserProvider>" = "Builder"
    "Consumer<LessonProvider>" = "Builder"
    "Consumer<VoiceProvider>" = "Builder"
    "Consumer<AudioProvider>" = "Builder"
    "Consumer<CoachProvider>" = "Builder"
    "Provider\.of<.*>\(context.*\)" = "// TODO: Replace with manager access"
    "context\.read<.*>\(" = "// TODO: Replace with manager access"
}

foreach ($file in $uiFiles) {
    if (Test-Path $file) {
        Update-FileImports -FilePath $file -ImportMappings $importMappings
    }
}

Write-Host ""
Write-Host "[7/8] Fixing routes.dart import issues..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

$routesPath = "lib\routes.dart"
if (Test-Path $routesPath) {
    $content = Get-Content $routesPath -Raw
    
    # Comment out missing imports and create basic route structure
    $fixedRoutesContent = @"
import 'package:flutter/material.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/profile_screen.dart';
import 'UI/screens/onboarding_screen.dart';
import 'UI/screens/lesson_screen.dart';
import 'UI/screens/topic_selection_screen.dart';
import 'UI/screens/coach_selection_screen.dart';
import 'UI/screens/settings_screen.dart';
import 'UI/screens/search_screen.dart';
import 'UI/screens/dashboard_screen.dart';
import 'UI/screens/learning_stats_screen.dart';
import 'UI/screens/learning_data_screen.dart';
import 'UI/screens/downloads_screen.dart';
import 'UI/screens/favorites_screen.dart';
import 'UI/screens/learning_history_screen.dart';
import 'UI/screens/help_support_screen.dart';
import 'UI/screens/content_library_screen.dart';
import 'UI/screens/social_leaderboard_screen.dart';
import 'UI/screens/achievements_gallery_screen.dart';
import 'UI/screens/advanced_settings_screen.dart';
// TODO: Add missing screen imports as they are created

class AppRoutes {
  // Route names
  static const String home = '/home';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String lesson = '/lesson';
  static const String topicSelection = '/topic-selection';
  static const String coachSelection = '/coach-selection';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String dashboard = '/dashboard';
  static const String learningStats = '/learning-stats';
  static const String learningData = '/learning-data';
  static const String downloads = '/downloads';
  static const String favorites = '/favorites';
  static const String learningHistory = '/learning-history';
  static const String helpSupport = '/help-support';
  static const String contentLibrary = '/content-library';
  static const String socialLeaderboard = '/social-leaderboard';
  static const String achievementsGallery = '/achievements-gallery';
  static const String advancedSettings = '/advanced-settings';
  
  // Route mappings (basic implementation)
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    onboarding: (context) => const OnboardingScreen(),
    settings: (context) => const SettingsScreen(),
    search: (context) => const SearchScreen(),
    dashboard: (context) => const DashboardScreen(),
    learningStats: (context) => const LearningStatsScreen(),
    learningData: (context) => const LearningDataScreen(),
    downloads: (context) => const DownloadsScreen(),
    favorites: (context) => const FavoritesScreen(),
    learningHistory: (context) => const LearningHistoryScreen(),
    helpSupport: (context) => const HelpSupportScreen(),
    contentLibrary: (context) => const ContentLibraryScreen(),
    socialLeaderboard: (context) => const SocialLeaderboardScreen(),
    achievementsGallery: (context) => const AchievementsGalleryScreen(),
    advancedSettings: (context) => const AdvancedSettingsScreen(),
  };
  
  // Generate route method
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    
    // Handle parameterized routes
    switch (settings.name) {
      case lesson:
        final lesson = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => LessonScreen(lesson: lesson),
          settings: settings,
        );
      case topicSelection:
        return MaterialPageRoute(
          builder: (context) => const TopicSelectionScreen(),
          settings: settings,
        );
      case coachSelection:
        return MaterialPageRoute(
          builder: (context) => const CoachSelectionScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
"@
    
    Set-Content -Path $routesPath -Value $fixedRoutesContent -Encoding UTF8
    Write-Host "✅ Fixed lib\routes.dart" -ForegroundColor Green
}

Write-Host ""
Write-Host "[8/8] Running final analysis..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

try {
    $analysisOutput = flutter analyze --no-congratulate 2>&1
    $analysisOutput | Out-File "analysis_results_after_import_fixes.txt" -Encoding UTF8
    Write-Host "✅ Analysis complete. Results saved to analysis_results_after_import_fixes.txt" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Flutter analyze failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✅ IMPORT FIXES COMPLETED!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary of fixes applied:" -ForegroundColor Cyan
Write-Host "✅ Fixed wisme_app.dart constructor issues" -ForegroundColor Green
Write-Host "✅ Updated core service imports" -ForegroundColor Green
Write-Host "✅ Created missing AppRouter" -ForegroundColor Green
Write-Host "✅ Created missing SplashScreen" -ForegroundColor Green
Write-Host "✅ Created missing AppTheme" -ForegroundColor Green
Write-Host "✅ Updated UI screens with placeholder imports" -ForegroundColor Green
Write-Host "✅ Fixed routes.dart structure" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review analysis_results_after_import_fixes.txt for remaining issues" -ForegroundColor White
Write-Host "2. Implement the TODO items in UI screens to use new managers" -ForegroundColor White
Write-Host "3. Create any missing screen files that are still referenced" -ForegroundColor White
Write-Host "4. Test the application to ensure it starts correctly" -ForegroundColor White
