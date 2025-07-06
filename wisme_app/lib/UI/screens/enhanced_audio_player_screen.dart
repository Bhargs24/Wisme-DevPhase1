import '../../core/exports.dart';

class EnhancedAudioPlayerScreen extends StatefulWidget {
  final String lessonId;
  final Map<String, dynamic>? lessonData;

  const EnhancedAudioPlayerScreen({
    super.key,
    required this.lessonId,
    this.lessonData,
  });

  @override
  State<EnhancedAudioPlayerScreen> createState() => _EnhancedAudioPlayerScreenState();
}

class _EnhancedAudioPlayerScreenState extends State<EnhancedAudioPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _avatarAnimationController;
  late Animation<double> _waveAnimation;
  late Animation<double> _avatarPulseAnimation;
  
  bool isPlaying = false;
  double currentPosition = 0.0;
  double totalDuration = 180.0; // 3 minutes default
  double playbackSpeed = 1.0;
  bool showTranscript = false;
  bool showNotes = false;

  @override
  void initState() {
    super.initState();
    
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _avatarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveAnimationController, curve: Curves.easeInOut),
    );
    
    _avatarPulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _avatarAnimationController, curve: Curves.easeInOut),
    );

    _waveAnimationController.repeat(reverse: true);
    _avatarAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _avatarAnimationController.dispose();
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
                      _buildCoachAvatar(),
                      const SizedBox(height: 24),
                      _buildLessonInfo(),
                      const SizedBox(height: 32),
                      _buildAudioVisualizer(),
                      const SizedBox(height: 32),
                      _buildProgressBar(),
                      const SizedBox(height: 24),
                      _buildPlaybackControls(),
                      const SizedBox(height: 32),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      if (showTranscript) _buildTranscript(),
                      if (showNotes) _buildNotes(),
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
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Session',
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Stay focused and enjoy the journey',
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAvatar() {
    return Consumer<CoachProvider>(
      builder: (context, coachProvider, child) {
        final coach = coachProvider.selectedCoach;
        if (coach == null) return const SizedBox();
        
        return AnimatedBuilder(
          animation: _avatarPulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isPlaying ? _avatarPulseAnimation.value : 1.0,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.secondary.withOpacity(0.3),
                      AppColors.accent.withOpacity(0.3),
                    ],
                  ),
                  boxShadow: isPlaying ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ] : [],
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      coach.avatarUrl.isNotEmpty ? coach.avatarUrl : '👨‍🏫',
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLessonInfo() {
    return Consumer<LessonProvider>(
      builder: (context, lessonProvider, child) {
        return ModernCard(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Text(
                widget.lessonData?['title'] ?? 'Understanding AI Fundamentals',
                style: AppTextStyles.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.lessonData?['description'] ?? 'Exploring the basics of artificial intelligence and its real-world applications.',
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(Icons.schedule, '${(totalDuration / 60).ceil()} min'),
                  _buildInfoItem(Icons.speed, '${playbackSpeed}x'),
                  _buildInfoItem(Icons.headphones, '${(currentPosition / totalDuration * 100).toInt()}%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioVisualizer() {
    return SizedBox(
      height: 80,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(20, (index) {
              final height = isPlaying 
                  ? 20 + (40 * _waveAnimation.value * (index % 3 == 0 ? 1 : index % 2 == 0 ? 0.7 : 0.4))
                  : 20.0;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              _formatDuration(currentPosition),
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Expanded(
              child: Slider(
                value: currentPosition,
                max: totalDuration,
                onChanged: (value) {
                  setState(() {
                    currentPosition = value;
                  });
                },
                activeColor: AppColors.primary,
                inactiveColor: Colors.grey[300],
              ),
            ),
            Text(
              _formatDuration(totalDuration),
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onTap: () => _skipBackward(),
        ),
        _buildControlButton(
          icon: Icons.skip_previous,
          onTap: () => _previousLesson(),
        ),
        _buildMainPlayButton(),
        _buildControlButton(
          icon: Icons.skip_next,
          onTap: () => _nextLesson(),
        ),
        _buildControlButton(
          icon: Icons.forward_10,
          onTap: () => _skipForward(),
        ),
      ],
    );
  }

  Widget _buildMainPlayButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlaying = !isPlaying;
        });
        if (isPlaying) {
          _simulatePlayback();
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionChip(
          icon: Icons.speed,
          label: '${playbackSpeed}x',
          onTap: () => _changePlaybackSpeed(),
        ),
        _buildActionChip(
          icon: Icons.text_fields,
          label: 'Transcript',
          isActive: showTranscript,
          onTap: () => setState(() => showTranscript = !showTranscript),
        ),
        _buildActionChip(
          icon: Icons.note_add,
          label: 'Notes',
          isActive: showNotes,
          onTap: () => setState(() => showNotes = !showNotes),
        ),
        _buildActionChip(
          icon: Icons.bookmark,
          label: 'Save',
          onTap: () => _saveLesson(),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isActive ? AppColors.accent : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.accent : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: isActive ? AppColors.accent : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscript() {
    return ModernCard(
      backgroundColor: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Transcript',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to today\'s lesson on AI fundamentals. In this session, we\'ll explore the core concepts that make artificial intelligence possible, starting with machine learning algorithms and their real-world applications...',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return ModernCard(
      backgroundColor: Colors.amber[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_add, color: Colors.amber[600]),
              const SizedBox(width: 8),
              Text(
                'Your Notes',
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add your thoughts, key insights, or questions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.amber[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _simulatePlayback() {
    if (isPlaying) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && isPlaying) {
          setState(() {
            currentPosition = (currentPosition + 1).clamp(0, totalDuration);
          });
          if (currentPosition < totalDuration) {
            _simulatePlayback();
          } else {
            isPlaying = false;
          }
        }
      });
    }
  }

  void _skipBackward() {
    setState(() {
      currentPosition = (currentPosition - 10).clamp(0, totalDuration);
    });
  }

  void _skipForward() {
    setState(() {
      currentPosition = (currentPosition + 10).clamp(0, totalDuration);
    });
  }

  void _previousLesson() {
    // Navigate to previous lesson
  }

  void _nextLesson() {
    // Navigate to next lesson
  }

  void _changePlaybackSpeed() {
    setState(() {
      if (playbackSpeed == 1.0) {
        playbackSpeed = 1.25;
      } else if (playbackSpeed == 1.25) {
        playbackSpeed = 1.5;
      } else if (playbackSpeed == 1.5) {
        playbackSpeed = 2.0;
      } else {
        playbackSpeed = 1.0;
      }
    });
  }

  void _saveLesson() {
    // Save lesson to favorites
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lesson saved to your library!')),
    );
  }

  void _showMoreOptions() {
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
            _buildOptionItem(Icons.share, 'Share Lesson', () {}),
            _buildOptionItem(Icons.download, 'Download for Offline', () {}),
            _buildOptionItem(Icons.report, 'Report Issue', () {}),
            _buildOptionItem(Icons.settings, 'Audio Settings', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

