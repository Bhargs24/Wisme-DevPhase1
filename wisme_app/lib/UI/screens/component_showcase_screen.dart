import '../../core/exports.dart';
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() => _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Buttons',
              _buildButtonSection(),
            ),
            _buildSection(
              'Text Fields',
              _buildTextFieldSection(),
            ),
            _buildSection(
              'Lesson Cards',
              _buildCardSection(),
            ),
            _buildSection(
              'Theme Colors',
              _buildColorSection(),
            ),
            _buildSection(
              'Typography',
              _buildTypographySection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        content,
        const SizedBox(height: AppDimensions.spaceXL),
      ],
    );
  }

  Widget _buildButtonSection() {
    return Column(
      children: [
        // Button variants
        const Text('Button Variants:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Primary Button',
          onPressed: () => _showSnackBar('Primary button pressed'),
          variant: AppButtonVariant.primary,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Secondary Button',
          onPressed: () => _showSnackBar('Secondary button pressed'),
          variant: AppButtonVariant.secondary,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Ghost Button',
          onPressed: () => _showSnackBar('Ghost button pressed'),
          variant: AppButtonVariant.ghost,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Danger Button',
          onPressed: () => _showSnackBar('Danger button pressed'),
          variant: AppButtonVariant.danger,
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Button sizes
        const Text('Button Sizes:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Small Button',
          onPressed: () => _showSnackBar('Small button pressed'),
          size: AppButtonSize.small,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Medium Button',
          onPressed: () => _showSnackBar('Medium button pressed'),
          size: AppButtonSize.medium,
        ),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Large Button',
          onPressed: () => _showSnackBar('Large button pressed'),
          size: AppButtonSize.large,
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Button with icon
        const Text('Button with Icon:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Download',
          icon: Icons.download,
          onPressed: () => _showSnackBar('Download button pressed'),
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Loading button
        const Text('Loading States:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppButton(
          text: 'Toggle Loading',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : () {
            setState(() {
              _isLoading = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isLoading = false;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextFieldSection() {
    return Column(
      children: [
        // Basic text field
        const Text('Basic Text Field:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppTextField(
          controller: _textController,
          labelText: 'Enter your name',
          hintText: 'John Doe',
          prefixIcon: const Icon(Icons.person),
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Search field
        const Text('Search Field:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppSearchField(
          controller: _searchController,
          hintText: 'Search for anything...',
          onChanged: (value) => debugPrint('Search: $value'),
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Password field
        const Text('Password Field with Strength Indicator:'),
        const SizedBox(height: AppDimensions.spaceS),
        AppPasswordField(
          controller: _passwordController,
          labelText: 'Password',
          showStrengthIndicator: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Disabled field
        const Text('Disabled Field:'),
        const SizedBox(height: AppDimensions.spaceS),
        const AppTextField(
          labelText: 'Disabled Field',
          hintText: 'This field is disabled',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildCardSection() {
    final sampleLesson = ContentBlock(
      id: 'sample_1',
      title: 'Understanding Provider Pattern',
      description: 'This lesson covers the Provider pattern in Flutter, which is one of the most popular state management solutions.',
      duration: const Duration(minutes: 3),
      audioUrl: '',
      category: 'Flutter Development',
      knowledgeLevel: 'beginner',
      tags: ['flutter', 'state-management', 'provider'],
      contentType: 'concept',
      difficultyLevel: 1,
      coachPersonality: 'friendly',
      voiceId: 'default',
      transcript: 'This lesson covers the Provider pattern in Flutter, which is one of the most popular state management solutions.',
      keywords: ['flutter', 'provider', 'state management'],
      prerequisites: ['basic dart knowledge'],
      learningOutcomes: ['understand provider pattern', 'implement provider in flutter'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Column(
      children: [
        // Full lesson card
        const Text('Full Lesson Card:'),
        const SizedBox(height: AppDimensions.spaceS),
        LessonCard(
          lesson: sampleLesson,
          onTap: () => _showSnackBar('Lesson card tapped'),
          onPlayPressed: () => _showSnackBar('Play button pressed'),
          onFavoritePressed: () => _showSnackBar('Favorite button pressed'),
          showPlayButton: true,
          showFavoriteButton: true,
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Compact lesson card
        const Text('Compact Lesson Card:'),
        const SizedBox(height: AppDimensions.spaceS),
        LessonCard(
          lesson: sampleLesson,
          onTap: () => _showSnackBar('Compact lesson card tapped'),
          onPlayPressed: () => _showSnackBar('Play button pressed'),
          isCompact: true,
          showPlayButton: true,
        ),
        
        const SizedBox(height: AppDimensions.spaceL),
        
        // Lesson card with progress
        const Text('Lesson Card with Progress:'),
        const SizedBox(height: AppDimensions.spaceS),
        LessonCard(
          lesson: sampleLesson,
          onTap: () => _showSnackBar('Progress lesson card tapped'),
          showProgress: true,
          progressValue: 0.65,
          showPlayButton: true,
          showFavoriteButton: true,
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Wrap(
      spacing: AppDimensions.spaceS,
      runSpacing: AppDimensions.spaceS,
      children: [
        _buildColorChip('Primary', AppColors.primary),
        _buildColorChip('Accent', AppColors.accent),
        _buildColorChip('Success', AppColors.success),
        _buildColorChip('Warning', AppColors.warning),
        _buildColorChip('Error', AppColors.error),
        _buildColorChip('Info', AppColors.info),
        _buildColorChip('Surface', AppColors.surface),
        _buildColorChip('Background', AppColors.background),
      ],
    );
  }

  Widget _buildColorChip(String name, Color color) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.spaceS),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _getContrastColor(color),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
        Text('Display Medium', style: Theme.of(context).textTheme.displayMedium),
        Text('Display Small', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppDimensions.spaceS),
        Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
        Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
        Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppDimensions.spaceS),
        Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
        Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
        Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppDimensions.spaceS),
        Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
        Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
        Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppDimensions.spaceS),
        Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
        Text('Label Medium', style: Theme.of(context).textTheme.labelMedium),
        Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Simple contrast calculation
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _searchController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

