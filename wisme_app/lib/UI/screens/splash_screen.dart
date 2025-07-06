import '../../core/exports.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo Animation
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Text(
                      '🧠',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Text Animation
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Wisme',
                        style: AppTextStyles.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'AI-Powered Microlearning',
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha:0.9),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Loading indicator
              FadeTransition(
                opacity: _textAnimation,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Preparing your learning experience...',
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha:0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}


