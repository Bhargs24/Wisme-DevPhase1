import 'package:flutter/material.dart';

/// Simplified voice selector widget for the new architecture
/// TODO: Integrate with new AudioManager when ready
class VoiceSelectorWidget extends StatefulWidget {
  final Function(String)? onVoiceSelected;
  final String? selectedVoiceId;
  final bool isLoading;

  const VoiceSelectorWidget({
    super.key,
    this.onVoiceSelected,
    this.selectedVoiceId,
    this.isLoading = false,
  });

  @override
  State<VoiceSelectorWidget> createState() => _VoiceSelectorWidgetState();
}

class _VoiceSelectorWidgetState extends State<VoiceSelectorWidget> {
  final List<String> _availableVoices = [
    'default',
    'alloy',
    'echo',
    'fable',
    'onyx',
    'nova',
    'shimmer',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voice Selection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableVoices.map((voice) {
                final isSelected = voice == widget.selectedVoiceId;
                return FilterChip(
                  label: Text(voice.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && widget.onVoiceSelected != null) {
                      widget.onVoiceSelected!(voice);
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          Text(
            'Select a voice for audio playback',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

