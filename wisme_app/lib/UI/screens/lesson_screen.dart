import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/lesson_model.dart';
import '../../providers/voice_provider.dart';
import '../widgets/voice_selector_widget.dart';

class LessonScreen extends StatefulWidget {
  final ContentBlock lesson;

  const LessonScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  bool _showTranscript = false;

  @override
  void initState() {
    super.initState();
    // TODO: Set current lesson when AudioProvider is properly configured
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.record_voice_over),
            onPressed: _showVoiceSelector,
          ),
          IconButton(
            icon: Icon(_showTranscript ? Icons.headphones : Icons.text_fields),
            onPressed: () {
              setState(() {
                _showTranscript = !_showTranscript;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLessonHeader(),
          _buildPlaybackControls(),
          Expanded(
            child: _showTranscript ? _buildTranscript() : _buildAudioVisualizer(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lesson.title,
            style: AppTextStyles.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.lesson.title,
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.access_time,
                label: "${widget.lesson.duration.inMinutes} min",
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.topic,
                label: widget.lesson.topic,
              ),
              const SizedBox(width: 12),
              Consumer<VoiceProvider>(
                builder: (context, voiceProvider, child) {
                  return _buildInfoChip(
                    icon: Icons.record_voice_over,
                    label: voiceProvider.getVoiceDisplayName('default'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_playbackPosition.toInt()),
                style: AppTextStyles.textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: _playbackPosition,
                  max: widget.lesson.duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _playbackPosition = value;
                    });
                    // TODO: Seek to position
                  },
                  activeColor: AppColors.primary,
                ),
              ),
              Text(
                "${widget.lesson.duration.inMinutes} min",
                style: AppTextStyles.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: _rewind10Seconds,
              ),
              const SizedBox(width: 20),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                  onPressed: _togglePlayback,
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: _forward10Seconds,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Speed control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Speed: '),
              DropdownButton<double>(
                value: 1.0,
                items: const [
                  DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                  DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                  DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                  DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                  DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                  DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                ],
                onChanged: (speed) {
                  // TODO: Implement speed change
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioVisualizer() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Audio visualization placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.graphic_eq,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Audio Visualizer',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Visual representation of audio will appear here',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {
                  // TODO: Implement save lesson
                },
              ),
              _buildQuickAction(
                icon: Icons.share,
                label: 'Share',
                onTap: () {
                  // TODO: Implement share lesson
                },
              ),
              _buildQuickAction(
                icon: Icons.download,
                label: 'Download',
                onTap: () {
                  // TODO: Implement download lesson
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscript() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson Transcript',
            style: AppTextStyles.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              widget.lesson.script,
              style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tags
          if (widget.lesson.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: AppTextStyles.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.lesson.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // TODO: Implement actual audio playback
  }

  void _rewind10Seconds() {
    setState(() {
      _playbackPosition = (_playbackPosition - 10).clamp(0, widget.lesson.duration.inSeconds.toDouble());
    });
  }

  void _forward10Seconds() {
    setState(() {
      _playbackPosition = (_playbackPosition + 10).clamp(0, widget.lesson.duration.inSeconds.toDouble());
    });
  }

  void _showVoiceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const VoiceSelectorWidget(),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
