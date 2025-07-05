import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';

/// Content home screen
class ContentHomeScreen extends StatelessWidget {
  const ContentHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading content...'),
      ),
    );
  }
}

/// Content library screen
class ContentLibraryScreen extends StatelessWidget {
  const ContentLibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading library...'),
      ),
    );
  }
}

/// Topic explorer screen
class TopicExplorerScreen extends StatelessWidget {
  const TopicExplorerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading topics...'),
      ),
    );
  }
}

/// Content generation screen
class ContentGenerationScreen extends StatelessWidget {
  const ContentGenerationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading generator...'),
      ),
    );
  }
}
