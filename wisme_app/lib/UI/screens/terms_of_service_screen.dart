import '../../core/exports.dart';
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Terms of Service',
          style: AppTextStyles.textTheme.titleLarge!.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using the Wisme app, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              'Use License',
              'Permission is granted to temporarily download one copy of Wisme for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              'User Account',
              'When you create an account with us, you must provide information that is accurate, complete, and current at all times.',
            ),
            _buildSection(
              'Content and Services',
              'Our service may contain links to third-party web sites or services that are not owned or controlled by Wisme.',
            ),
            _buildSection(
              'Limitation of Liability',
              'In no event shall Wisme, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages.',
            ),
            _buildSection(
              'Termination',
              'We may terminate or suspend your account and bar access to the service immediately, without prior notice or liability, under our sole discretion.',
            ),
            _buildSection(
              'Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time.',
            ),
            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms of Service, please contact us at legal@wisme.app',
            ),
            SizedBox(height: 20),
            Text(
              'Last updated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: AppTextStyles.textTheme.bodySmall!.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.textTheme.titleMedium!.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

