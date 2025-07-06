import '../../core/exports.dart';
import '../widgets/voice_selector_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  TopicAnalysis? _selectedTopic;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final lessonProvider = context.read<LessonProvider>();
    if (lessonProvider.topics.isNotEmpty) {
      setState(() {
        _selectedTopic = lessonProvider.topics.first;
      });
      if (_selectedTopic != null) {
        lessonProvider.loadLessonsByTopic(_selectedTopic!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeScreen(context);
  }

  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisme - Learn Anything'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTopicSelector(),
          _buildVoiceSelector(),
          Expanded(child: _buildLessonsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${user?.displayName ?? 'Learner'}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to learn today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppSearchField(
        controller: _searchController,
        hintText: 'Search lessons or ask anything...',
        onSubmitted: (_) => _performSearch(),
        onChanged: (value) {
          // Optional: Implement real-time search
        },
      ),
    );
  }

  Widget _buildTopicSelector() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.topics.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lessonProvider.topics.length,
            itemBuilder: (context, index) {
              final topic = lessonProvider.topics[index];
              final isSelected = topic == _selectedTopic;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(topic.originalQuery),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTopic = topic;
                      });
                      lessonProvider.loadLessonsByTopic(topic);
                    }
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVoiceSelector() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.record_voice_over, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Voice: ${voiceProvider.getVoiceDisplayName(voiceProvider.selectedVoice?.voiceId)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: _showVoiceSelector,
                child: const Text('Change'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonsList() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        if (lessonProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (lessonProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  lessonProvider.error!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => lessonProvider.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (lessonProvider.contentBlocks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No lessons yet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to generate your first lesson',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: lessonProvider.contentBlocks.length,
          itemBuilder: (context, index) {
            final lesson = lessonProvider.contentBlocks[index];
            return LessonCard(
              lesson: lesson,
              onTap: () => _openLesson(lesson),
            );
          },
        );
      },
    );
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    if (query.length < 10) {
      // Simple search
      context.read<LessonProvider>().searchLessons(query);
    } else {
      // Generate new lesson from query
      _generateLessonFromQuery(query);
    }
  }

  void _generateLessonFromQuery(String query) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Lesson'),
        content: Text('Generate a lesson about: "$query"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateLesson(
                topic: 'General',
                subtopic: 'learning',
                userQuery: query,
              );
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showVoiceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const VoiceSelectorWidget(),
    );
  }

  void _generateLesson({
    required String topic,
    required String subtopic,
    required String userQuery,
  }) async {
    final lessonProvider = context.read<LessonProvider>();

    final lesson = await lessonProvider.generateContentBlock(
      topic: topic,
      category: userQuery,
    );

    if (lesson != null && mounted) {
      _openLesson(lesson);
    }
  }

  void _openLesson(lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lesson: lesson),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Simple dialog for generating lessons
class GenerateLessonDialog extends StatefulWidget {
  const GenerateLessonDialog({super.key});

  @override
  State<GenerateLessonDialog> createState() => _GenerateLessonDialogState();
}

class _GenerateLessonDialogState extends State<GenerateLessonDialog> {
  final _topicController = TextEditingController();
  final _queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate New Lesson'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _topicController,
            decoration: const InputDecoration(
              labelText: 'Topic (e.g., AI, Business)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _queryController,
            decoration: const InputDecoration(
              labelText: 'What do you want to learn?',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _generateLesson,
          child: const Text('Generate'),
        ),
      ],
    );
  }

  void _generateLesson() {
    final topic = _topicController.text.trim();
    final query = _queryController.text.trim();

    if (topic.isEmpty || query.isEmpty) return;

    Navigator.pop(context);
    
    // Call the home screen's generate lesson method
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._generateLesson(
      topic: topic,
      subtopic: 'general',
      userQuery: query,
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _queryController.dispose();
    super.dispose();
  }
}

