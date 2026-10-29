import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/app_prefs.dart';
import '../../../core/services/debt_reminder_service.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/sync_status.dart';
import '../../../data/services/sync_service.dart';
import 'package:intl/intl.dart';
import '../../../data/services/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/username_setup_screen.dart';
import '../../social/presentation/user_avatar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _reminderEnabled = AppPrefs.reminderEnabled;
  TimeOfDay _reminderTime = TimeOfDay(
    hour: AppPrefs.reminderHour,
    minute: AppPrefs.reminderMinute,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacing16),
          children: [
            if (AuthService.to.firebaseReady) ...[
              _buildSectionHeader(context, 'Account'),
              _buildAccountSection(context),
              const SizedBox(height: AppDimensions.spacing24),
              _buildSyncSection(context),
            ],
            _buildSectionHeader(context, 'Reminders'),
            _buildReminderSection(context),
            const SizedBox(height: AppDimensions.spacing24),
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

  // MARK: - Account

  Widget _buildAccountSection(BuildContext context) {
    final auth = AuthService.to;
    return Obx(() {
      final profile = auth.profile.value;
      if (!auth.isSignedIn) {
        return _card(
          context,
          child: ListTile(
            leading: _iconBadge(Icons.login, AppColors.lavenderGradient),
            title: const Text('Sign in with Google'),
            subtitle: const Text('Add friends and invite them to groups'),
            onTap: () => Get.to(() => const LoginScreen(fromSettings: true)),
          ),
        );
      }

      final name = profile?.displayName ?? auth.user.value?.displayName ?? '';
      return _card(
        context,
        child: Column(
          children: [
            ListTile(
              leading: UserAvatar(name: name, photoUrl: profile?.photoUrl),
              title: Text(name.isEmpty ? 'Signed in' : name),
              subtitle: Text(auth.user.value?.email ?? ''),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.alternate_email),
              title: Text(profile?.handle ?? 'No username'),
              subtitle: const Text('Tap to change'),
              onTap: () =>
                  Get.to(() => const UsernameSetupScreen(isEditing: true)),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('User ID'),
              subtitle: Text(
                auth.uid ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: auth.uid ?? ''));
                  SnackbarUtils.showInfo('Copied', 'User ID copied');
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'Sign out',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: _confirmSignOut,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSyncSection(BuildContext context) {
    if (!Get.isRegistered<SyncService>()) return const SizedBox.shrink();
    final sync = SyncService.to;
    return Obx(() {
      if (!AuthService.to.isSignedIn) return const SizedBox.shrink();
      final pending = sync.pendingCount.value;
      final last = sync.lastSyncedAt.value;
      final String status;
      if (!sync.online.value) {
        status =
            'Offline - ${pending > 0 ? '$pending change(s) saved locally' : 'data saved locally'}';
      } else if (pending > 0) {
        status = '$pending change(s) waiting to sync';
      } else {
        status = last == null
            ? 'Up to date'
            : 'Up to date • last synced ${DateFormat('d MMM, h:mm a').format(last)}';
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(context, 'Cloud sync'),
          _card(
            context,
            child: ListTile(
              leading: _iconBadge(
                sync.online.value ? Icons.cloud_sync : Icons.cloud_off,
                AppColors.mintGradient,
              ),
              title: const Text('Sync now'),
              subtitle: Text(status),
              trailing: sync.syncing.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onTap: sync.syncing.value ? null : runManualSync,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
        ],
      );
    });
  }

  void _confirmSignOut() {
    final pending = Get.isRegistered<SyncService>()
        ? SyncService.to.pendingCount.value
        : 0;
    Get.dialog(
      AlertDialog(
        title: const Text('Sign out'),
        content: Text(
          pending > 0
              ? 'You have $pending change(s) that have not synced yet. '
                    'Signing out removes your data from this device, so those '
                    'changes will be lost. Connect to the internet and sync '
                    'first to keep them.'
              : 'Your data is safely synced. Signing out removes it from '
                    'this device; it comes back when you sign in again.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Get.back();
              // Return to the root so the auth gate can take over
              Get.until((route) => route.isFirst);
              await AuthService.to.signOut();
            },
            child: Text(pending > 0 ? 'Sign out anyway' : 'Sign out'),
          ),
        ],
      ),
    );
  }

  // MARK: - Reminders

  Widget _buildReminderSection(BuildContext context) {
    return _card(
      context,
      child: Column(
        children: [
          SwitchListTile(
            secondary: _iconBadge(
              Icons.notifications_active_outlined,
              AppColors.peachGradient,
            ),
            title: const Text('Daily payment reminder'),
            subtitle: const Text('Who you have to pay and collect from'),
            value: _reminderEnabled,
            activeThumbColor: AppColors.lavenderGradient[1],
            onChanged: (value) async {
              setState(() => _reminderEnabled = value);
              AppPrefs.reminderEnabled = value;
              await DebtReminderService.instance.onReminderSettingsChanged();
            },
          ),
          ListTile(
            enabled: _reminderEnabled,
            leading: const Icon(Icons.schedule),
            title: const Text('Reminder time'),
            trailing: Text(_reminderTime.format(context)),
            onTap: _pickTime,
          ),
          ListTile(
            leading: const Icon(Icons.send_outlined),
            title: const Text('Show my balances now'),
            onTap: () async {
              final shown = await DebtReminderService.instance
                  .showReminderNow();
              if (!shown) {
                SnackbarUtils.showInfo('All settled', 'You have no balances');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null) return;
    setState(() => _reminderTime = picked);
    await AppPrefs.setReminderTime(picked.hour, picked.minute);
    await DebtReminderService.instance.onReminderSettingsChanged();
    if (mounted) {
      SnackbarUtils.showSuccess(
        'Reminder updated',
        'Daily reminder at ${picked.format(context)}',
      );
    }
  }

  // MARK: - Shared

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );
  }

  Widget _iconBadge(IconData icon, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: gradient[0].withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: gradient[1]),
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
    return _card(
      context,
      child: ListTile(
        leading: _iconBadge(Icons.dark_mode, AppColors.lavenderGradient),
        title: const Text('Dark Mode'),
        subtitle: const Text('Switch between light and dark themes'),
        trailing: Switch(
          value: Get.isDarkMode,
          onChanged: (value) {
            AppPrefs.darkMode = value;
            Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            // Get.isDarkMode updates after the theme animates in
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) setState(() {});
            });
          },
          activeThumbColor: AppColors.lavenderGradient[1],
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
    return _card(
      context,
      child: ListTile(
        leading: _iconBadge(icon, AppColors.skyGradient),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
