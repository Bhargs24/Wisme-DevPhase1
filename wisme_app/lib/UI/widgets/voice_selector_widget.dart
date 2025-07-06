import 'package:flutter/material.dart';

// TODO: Replace with AudioManager import
// TODO: Replace with AudioManager import

class VoiceSelectorWidget extends StatefulWidget {
  const VoiceSelectorWidget({super.key});

  @override
  State<VoiceSelectorWidget> createState() => _VoiceSelectorWidgetState();
}

class _VoiceSelectorWidgetState extends State<VoiceSelectorWidget> {
  final Map<String, String> _availableVoices = {
    'zen_coach': 'ðŸ§˜ Zen Coach',
    'startup_buddy': 'ðŸš€ Startup Buddy', 
    'science_guide': 'ðŸ”¬ Science Guide',
    'default': 'ðŸŽ™ï¸ Default',
    'motivational': 'ðŸ’ª Motivational',
    'storyteller': 'ðŸ“š Storyteller',
  };

  List<String> _availableForLesson = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableVoices();
  }

  Future<void> _loadAvailableVoices() async {
    final voiceProvider = // TODO: Replace with AudioManager usage;
    await voiceProvider.refreshVoices();
    
    setState(() {
      _availableForLesson = voiceProvider.availableVoices.map((v) => v.voiceId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, VoiceProvider>(
      builder: (context, audioProvider, voiceProvider, child) {
        if (!audioProvider.hasCurrentBlock) {
          return const SizedBox.shrink();
        }

        final currentVoice = voiceProvider.selectedVoiceId;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Coach Voice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Current voice indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current: ${_availableVoices[currentVoice] ?? currentVoice}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Voice options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableVoices.entries.map((entry) {
                  final voiceId = entry.key;
                  final voiceName = entry.value;
                  final isAvailable = _availableForLesson.contains(voiceId);
                  final isCurrent = voiceId == currentVoice;
                  
                  return _VoiceOption(
                    voiceId: voiceId,
                    voiceName: voiceName,
                    isCurrent: isCurrent,
                    isAvailable: isAvailable,
                    isLoading: audioProvider.isLoading,
                    onTap: () => _switchVoice(voiceId, audioProvider, voiceProvider),
                  );
                }).toList(),
              ),
              
              if (audioProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Generating voice variation...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _switchVoice(String voiceId, AudioProvider audioProvider, VoiceProvider voiceProvider) async {
    if (audioProvider.isLoading || voiceId == voiceProvider.selectedVoiceId) {
      return;
    }

    try {
      await voiceProvider.selectVoice(voiceId);
      await _loadAvailableVoices(); // Refresh available voices
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${voiceProvider.getVoiceDisplayName(voiceId)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch voice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _VoiceOption extends StatelessWidget {
  final String voiceId;
  final String voiceName;
  final bool isCurrent;
  final bool isAvailable;
  final bool isLoading;
  final VoidCallback onTap;

  const _VoiceOption({
    required this.voiceId,
    required this.voiceName,
    required this.isCurrent,
    required this.isAvailable,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrent 
              ? Theme.of(context).primaryColor
              : isAvailable 
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrent 
                ? Theme.of(context).primaryColor
                : isAvailable 
                    ? Colors.green
                    : Colors.grey,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              voiceName,
              style: TextStyle(
                color: isCurrent 
                    ? Colors.white
                    : isAvailable 
                        ? Colors.green.shade700
                        : Colors.grey.shade600,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            
            if (isAvailable && !isCurrent) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green.shade600,
              ),
            ],
            
            if (!isAvailable && !isCurrent) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


