import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';

/// Audio player screen
class AudioPlayerScreen extends StatelessWidget {
  final dynamic audioFile;
  
  const AudioPlayerScreen({Key? key, this.audioFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading audio player...'),
      ),
    );
  }
}

/// Audio library screen
class AudioLibraryScreen extends StatelessWidget {
  const AudioLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading audio library...'),
      ),
    );
  }
}

/// Audio generation screen
class AudioGenerationScreen extends StatelessWidget {
  const AudioGenerationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading audio generator...'),
      ),
    );
  }
}
