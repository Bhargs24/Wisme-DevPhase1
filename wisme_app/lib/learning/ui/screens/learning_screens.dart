import 'package:flutter/material.dart';
import '../../shared/ui/widgets/widgets.dart';
import '../../shared/ui/theme/app_theme.dart';rt 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';
import '../../learning_manager.dart';
import '../../../app/navigation/app_router.dart';
import '../widgets/learning_widgets.dart';

/// Learning home screen
class LearningHomeScreen extends StatefulWidget {
  const LearningHomeScreen({Key? key}) : super(key: key);

  @override
  State<LearningHomeScreen> createState() => _LearningHomeScreenState();
}

class _LearningHomeScreenState extends State<LearningHomeScreen> {
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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          children: [
            // Continue learning section
            WismeSection(
              title: 'Continue Learning',
              child: Column(
                children: [
                  WismeLessonCard(
                    title: 'Flutter Widgets',
                    subtitle: 'Mobile Development',
                    progress: 0.65,
                    duration: '15 min left',
                    isRecommended: true,
                  ),
                  SizedBox(height: WismeSpacing.sm),
                  WismeLessonCard(
                    title: 'Machine Learning Basics',
                    subtitle: 'AI & Data Science',
                    progress: 0.30,
                    duration: '25 min left',
                  ),
                ],
              ),
            ),
            
            SizedBox(height: WismeSpacing.lg),
            
            // Learning paths section
            WismeSection(
              title: 'Learning Paths',
              action: WismeTextButton(text: 'View All'),
              child: Column(
                children: [
                  WismeLearningPathCard(
                    title: 'Flutter Development',
                    description: 'Complete mobile development course',
                    progress: 0.75,
                    lessonsCount: 16,
                    completedLessons: 12,
                  ),
                  SizedBox(height: WismeSpacing.sm),
                  WismeLearningPathCard(
                    title: 'AI & Machine Learning',
                    description: 'From basics to advanced AI concepts',
                    progress: 0.45,
                    lessonsCount: 20,
                    completedLessons: 9,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: WismeSpacing.lg),
            
            // Quick actions
            WismeSection(
              title: 'Quick Actions',
              child: WismeQuickActionsGrid(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual lesson screen
class LessonScreen extends StatefulWidget {
  const LessonScreen({Key? key}) : super(key: key);

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Lesson'),
        actions: [
          WismeIconButton(
            icon: Icons.bookmark_border,
            onPressed: () {
              // Bookmark lesson
            },
          ),
        ],
      ),
      body: const Center(
        child: WismeLoadingIndicator(
          message: 'Loading lesson...',
        ),
      ),
    );
  }
}

/// Lesson detail screen
class LessonDetailScreen extends StatefulWidget {
  final String? lessonId;
  
  const LessonDetailScreen({Key? key, this.lessonId}) : super(key: key);

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            WismeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flutter Widgets Deep Dive',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: WismeSpacing.sm),
                  Text(
                    'Master the building blocks of Flutter applications',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: WismeSpacing.md),
                  
                  // Lesson stats
                  Row(
                    children: [
                      const WismeLessonStat(
                        icon: Icons.schedule,
                        label: '45 min',
                      ),
                      const SizedBox(width: WismeSpacing.lg),
                      const WismeLessonStat(
                        icon: Icons.signal_cellular_alt,
                        label: 'Intermediate',
                      ),
                      const SizedBox(width: WismeSpacing.lg),
                      WismeLessonStat(
                        icon: Icons.star,
                        label: '4.8',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: WismeSpacing.lg),
            
            // Progress
            WismeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: WismeSpacing.sm),
                  const WismeProgressIndicator(
                    progress: 0.65,
                    label: 'Lesson Progress',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: WismeSpacing.lg),
            
            // Actions
            WismePrimaryButton(
              text: 'Continue Learning',
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                // Start/continue lesson
              },
            ),
            
            const SizedBox(height: WismeSpacing.sm),
            
            WismeSecondaryButton(
              text: 'Practice Mode',
              icon: const Icon(Icons.fitness_center),
              onPressed: () {
                AppNavigation.pushNamed(AppRoutes.practiceMode);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Learning path screen
class LearningPathScreen extends StatefulWidget {
  const LearningPathScreen({Key? key}) : super(key: key);

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Paths'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(WismeSpacing.lg),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: WismeSpacing.md),
        itemBuilder: (context, index) {
          return WismeLearningPathCard(
            title: 'Learning Path ${index + 1}',
            description: 'Description for learning path ${index + 1}',
            progress: (index + 1) * 0.2,
            lessonsCount: (index + 1) * 5,
            completedLessons: (index + 1) * 2,
            onTap: () {
              // Navigate to path details
            },
          );
        },
      ),
    );
  }
}

/// Practice mode screen
class PracticeModeScreen extends StatefulWidget {
  const PracticeModeScreen({Key? key}) : super(key: key);

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Mode'),
        backgroundColor: Colors.orange.shade50,
        foregroundColor: Colors.orange.shade800,
      ),
      backgroundColor: Colors.orange.shade50,
      body: const Center(
        child: WismeLoadingIndicator(
          message: 'Preparing practice session...',
        ),
      ),
    );
  }
}

/// Quiz screen
class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  final int _totalQuestions = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${_currentQuestion + 1}/$_totalQuestions'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
      ),
      backgroundColor: Colors.blue.shade50,
      body: Padding(
        padding: const EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          children: [
            // Progress
            WismeProgressIndicator(
              progress: (_currentQuestion + 1) / _totalQuestions,
              showPercentage: false,
            ),
            
            const SizedBox(height: WismeSpacing.xl),
            
            // Question
            Expanded(
              child: WismeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestion + 1}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: WismeSpacing.sm),
                    
                    Text(
                      'What is the primary purpose of StatefulWidget in Flutter?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    
                    const SizedBox(height: WismeSpacing.lg),
                    
                    // Answer options
                    Expanded(
                      child: ListView(
                        children: [
                          WismeQuizOption(
                            text: 'To create widgets that never change',
                            isSelected: false,
                            onTap: () {},
                          ),
                          const SizedBox(height: WismeSpacing.sm),
                          WismeQuizOption(
                            text: 'To manage state that can change over time',
                            isSelected: true,
                            onTap: () {},
                          ),
                          const SizedBox(height: WismeSpacing.sm),
                          WismeQuizOption(
                            text: 'To improve app performance',
                            isSelected: false,
                            onTap: () {},
                          ),
                          const SizedBox(height: WismeSpacing.sm),
                          WismeQuizOption(
                            text: 'To handle network requests',
                            isSelected: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: WismeSpacing.lg),
            
            // Next button
            WismePrimaryButton(
              text: _currentQuestion < _totalQuestions - 1 ? 'Next Question' : 'Finish Quiz',
              onPressed: () {
                if (_currentQuestion < _totalQuestions - 1) {
                  setState(() => _currentQuestion++);
                } else {
                  AppNavigation.pushReplacementNamed(AppRoutes.results);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Results screen
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade800,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(WismeSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: WismeShadows.lg,
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: WismeSpacing.xl),
            
            Text(
              'Excellent Work!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: WismeSpacing.sm),
            
            Text(
              'You scored 8 out of 10',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: WismeSpacing.xl),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                WismeQuizStat(
                  label: 'Correct',
                  value: '8',
                  color: Colors.green,
                ),
                WismeQuizStat(
                  label: 'Wrong',
                  value: '2',
                  color: Colors.red,
                ),
                WismeQuizStat(
                  label: 'Score',
                  value: '80%',
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: WismeSpacing.xl * 2),
            
            // Actions
            WismePrimaryButton(
              text: 'Continue Learning',
              onPressed: () {
                AppNavigation.pushNamedAndClearStack(AppRoutes.learning);
              },
            ),
            
            const SizedBox(height: WismeSpacing.md),
            
            WismeSecondaryButton(
              text: 'Review Answers',
              onPressed: () {
                // Review quiz answers
              },
            ),
          ],
        ),
      ),
    );
  }
}
