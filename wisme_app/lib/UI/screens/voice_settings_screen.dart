import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/voice_provider.dart';

class VoiceSettingsScreen extends StatelessWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Settings'),
      ),
      body: Consumer<VoiceProvider>(
        builder: (context, voiceProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Choose Your Preferred Voice',
                style: AppTextStyles.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...voiceProvider.availableVoices.map((voice) {
                final isSelected = voice == voiceProvider.selectedVoice;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.record_voice_over,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    title: Text(voiceProvider.getVoiceDisplayName(voice)),
                    subtitle: Text(voiceProvider.getVoiceDescription(voice)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            voiceProvider.previewVoice(
                              voice,
                              'Hello! This is how I sound. I hope you enjoy learning with me.',
                            );
                          },
                        ),
                        Radio<String>(
                          value: voice,
                          groupValue: voiceProvider.selectedVoice,
                          onChanged: (value) {
                            if (value != null) {
                              voiceProvider.selectVoice(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
