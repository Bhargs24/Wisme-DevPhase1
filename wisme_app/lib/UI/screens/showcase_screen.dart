import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Component showcase demonstrating all available components
/// UI/UX developers: Use this as a reference for component capabilities
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() => _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Showcase'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Buttons', _buildButtons()),
            const SizedBox(height: 32),
            _buildSection('Text Fields', _buildTextFields()),
            const SizedBox(height: 32),
            _buildSection('Colors', _buildColors()),
            const SizedBox(height: 32),
            _buildSection('Typography', _buildTypography()),
            const SizedBox(height: 64),
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
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Buttons
        Text('Primary Buttons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Primary',
                onPressed: () => _showSnackBar('Primary button pressed'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                text: 'Loading',
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Button Variants
        Text('Button Variants', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AppButton(
          text: 'Secondary',
          variant: AppButtonVariant.secondary,
          onPressed: () => _showSnackBar('Secondary button pressed'),
        ),
        const SizedBox(height: 8),
        AppButton(
          text: 'Ghost',
          variant: AppButtonVariant.ghost,
          onPressed: () => _showSnackBar('Ghost button pressed'),
        ),
        const SizedBox(height: 8),
        AppButton(
          text: 'Danger',
          variant: AppButtonVariant.danger,
          onPressed: () => _showSnackBar('Danger button pressed'),
        ),
        const SizedBox(height: 16),

        // Button with Icons
        Text('Buttons with Icons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AppButton(
          text: 'Save',
          icon: Icons.save,
          onPressed: () => _showSnackBar('Save button pressed'),
        ),
        const SizedBox(height: 8),
        AppButton(
          text: 'Download',
          icon: Icons.download,
          trailingIcon: Icons.arrow_drop_down,
          variant: AppButtonVariant.secondary,
          onPressed: () => _showSnackBar('Download button pressed'),
        ),
        const SizedBox(height: 16),

        // Button Sizes
        Text('Button Sizes', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            AppButton(
              text: 'Small',
              size: AppButtonSize.small,
              isFullWidth: false,
              onPressed: () => _showSnackBar('Small button'),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Medium',
              size: AppButtonSize.medium,
              isFullWidth: false,
              onPressed: () => _showSnackBar('Medium button'),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Large',
              size: AppButtonSize.large,
              isFullWidth: false,
              onPressed: () => _showSnackBar('Large button'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Icon Buttons
        Text('Icon Buttons', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            AppIconButton(
              icon: Icons.favorite,
              onPressed: () => _showSnackBar('Favorite'),
              tooltip: 'Add to favorites',
            ),
            const SizedBox(width: 8),
            AppIconButton(
              icon: Icons.share,
              onPressed: () => _showSnackBar('Share'),
              tooltip: 'Share',
              backgroundColor: AppColors.primary,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 8),
            AppIconButton(
              icon: Icons.settings,
              onPressed: () => _showSnackBar('Settings'),
              tooltip: 'Settings',
              size: AppButtonSize.large,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Custom Styled Button
        Text('Custom Styled', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AppButton(
          text: 'Gradient Button',
          variant: AppButtonVariant.custom,
          customGradient: const LinearGradient(
            colors: [Colors.purple, Colors.blue],
          ),
          customBorderRadius: BorderRadius.circular(20),
          icon: Icons.star,
          onPressed: () => _showSnackBar('Custom gradient button'),
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Text Fields
        Text('Basic Text Fields', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const AppTextField(
          labelText: 'Name',
          hintText: 'Enter your name',
          isRequired: true,
        ),
        const SizedBox(height: 8),
        AppTextField(
          labelText: 'Email',
          hintText: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          controller: _textController,
          helperText: 'We will never share your email',
        ),
        const SizedBox(height: 16),

        // Text Field Variants
        Text('Text Field Variants', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const AppTextField(
          labelText: 'Outlined (Default)',
          hintText: 'Outlined border',
          variant: AppTextFieldVariant.outlined,
        ),
        const SizedBox(height: 8),
        const AppTextField(
          labelText: 'Filled',
          hintText: 'Filled background',
          variant: AppTextFieldVariant.filled,
        ),
        const SizedBox(height: 8),
        const AppTextField(
          labelText: 'Underlined',
          hintText: 'Underline border',
          variant: AppTextFieldVariant.underlined,
        ),
        const SizedBox(height: 16),

        // Specialized Fields
        Text('Specialized Fields', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AppSearchField(
          hintText: 'Search anything...',
          controller: _searchController,
          onChanged: (value) => debugPrint('Searching: $value'),
        ),
        const SizedBox(height: 8),
        AppPasswordField(
          labelText: 'Password',
          controller: _passwordController,
          showStrengthIndicator: true,
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildColors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brand Colors', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildColorSwatch('Primary', AppColors.primary),
            const SizedBox(width: 8),
            _buildColorSwatch('Secondary', AppColors.secondary),
          ],
        ),
        const SizedBox(height: 8),
        
        Text('Semantic Colors', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildColorSwatch('Success', AppColors.success),
            const SizedBox(width: 8),
            _buildColorSwatch('Warning', AppColors.warning),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildColorSwatch('Error', AppColors.error),
            const SizedBox(width: 8),
            _buildColorSwatch('Info', AppColors.info),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Large',
          style: AppTypography.displayLarge,
        ),
        Text(
          'Headline Large',
          style: AppTypography.headlineLarge,
        ),
        Text(
          'Title Large',
          style: AppTypography.titleLarge,
        ),
        Text(
          'Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          style: AppTypography.bodyLarge,
        ),
        Text(
          'Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          style: AppTypography.bodyMedium,
        ),
        Text(
          'Body Small - Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          style: AppTypography.bodySmall,
        ),
        Text(
          'Caption - Additional information',
          style: AppTypography.caption,
        ),
      ],
    );
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
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
