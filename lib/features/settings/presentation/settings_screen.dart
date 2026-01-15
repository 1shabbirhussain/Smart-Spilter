import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          children: [
            _buildSectionHeader(context, 'Appearance'),
            _buildThemeToggle(context),
            const SizedBox(height: AppDimensions.spacing24),
            _buildSectionHeader(context, 'About'),
            _buildInfoTile(
              context,
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.grey600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lavenderGradient[0].withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.dark_mode, color: AppColors.lavenderGradient[1]),
        ),
        title: const Text('Dark Mode'),
        subtitle: const Text('Switch between light and dark themes'),
        trailing: Switch(
          value: Get.isDarkMode,
          onChanged: (value) {
            Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
          },
          activeColor: AppColors.lavenderGradient[1],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.skyGradient[0].withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.info),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
