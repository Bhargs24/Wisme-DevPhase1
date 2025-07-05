import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';

/// Coach home screen
class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading coach...'),
      ),
    );
  }
}

/// Coach chat screen
class CoachChatScreen extends StatelessWidget {
  final String? coachId;
  
  const CoachChatScreen({Key? key, this.coachId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading chat...'),
      ),
    );
  }
}

/// Coach selection screen
class CoachSelectionScreen extends StatelessWidget {
  const CoachSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading coaches...'),
      ),
    );
  }
}

/// Coach profile screen
class CoachProfileScreen extends StatelessWidget {
  final String? coachId;
  
  const CoachProfileScreen({Key? key, this.coachId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: WismeLoadingIndicator(message: 'Loading coach profile...'),
      ),
    );
  }
}
