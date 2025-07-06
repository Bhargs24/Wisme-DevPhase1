import '../../core/exports.dart';
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'Data Collection',
              'We collect information to provide better services to all our users. This includes account information, usage data, and device information necessary for app functionality.',
            ),
            _buildSection(
              'Data Usage',
              'Your data is used to personalize your learning experience, improve our services, and provide customer support. We do not sell your personal information to third parties.',
            ),
            _buildSection(
              'Data Security',
              'We implement industry-standard security measures including encryption, secure servers, and access controls to protect your personal information.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to access, update, delete, or export your personal data. You can also opt-out of certain data collection practices.',
            ),
            _buildSection(
              'Contact Us',
              'If you have questions about this privacy policy, please contact us at privacy@wisme.app',
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


