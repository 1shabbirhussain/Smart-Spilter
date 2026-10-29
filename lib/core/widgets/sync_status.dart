import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/sync_service.dart';
import '../constants/app_colors.dart';
import '../utils/snackbar_utils.dart';

bool get _syncAvailable =>
    Get.isRegistered<SyncService>() && AuthService.to.isSignedIn;

/// Runs a manual sync and reports the outcome
Future<void> runManualSync() async {
  if (!Get.isRegistered<SyncService>()) return;
  final result = await SyncService.to.syncNow();
  switch (result) {
    case SyncResult.synced:
      SnackbarUtils.showSuccess('Synced', 'All your data is up to date');
    case SyncResult.offline:
      SnackbarUtils.showError(
        'No internet',
        'Your data is saved on this device and will sync when you are online',
      );
    case SyncResult.notSignedIn:
      SnackbarUtils.showInfo('Not signed in', 'Sign in to sync your data');
    case SyncResult.timeout:
      SnackbarUtils.showError(
        'Still syncing',
        'The connection is slow. Changes will keep syncing in the background',
      );
    case SyncResult.failed:
      SnackbarUtils.showError('Sync failed', 'Please try again');
  }
}

/// Shown while offline: changes are kept locally until connectivity returns
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncService>()) return const SizedBox.shrink();
    final sync = SyncService.to;
    return Obx(() {
      if (!AuthService.to.isSignedIn || sync.online.value) {
        return const SizedBox.shrink();
      }
      final pending = sync.pendingCount.value;
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: AppColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "You're offline. Data is saved on this device and will sync "
                'automatically when internet is available'
                '${pending > 0 ? ' ($pending pending)' : ''}.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// App bar button: shows sync state and syncs manually on tap
class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<SyncService>()) return const SizedBox.shrink();
    final sync = SyncService.to;
    return Obx(() {
      if (!_syncAvailable) return const SizedBox.shrink();
      if (sync.syncing.value) {
        return const Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }
      final pending = sync.pendingCount.value;
      final IconData icon;
      final String tooltip;
      if (!sync.online.value) {
        icon = Icons.cloud_off;
        tooltip = 'Offline - saved locally';
      } else if (pending > 0) {
        icon = Icons.cloud_upload_outlined;
        tooltip = '$pending change${pending == 1 ? '' : 's'} to sync';
      } else {
        icon = Icons.cloud_done_outlined;
        tooltip = 'Synced - tap to sync now';
      }
      return IconButton(
        tooltip: tooltip,
        onPressed: runManualSync,
        icon: Badge(
          isLabelVisible: pending > 0,
          label: Text('$pending'),
          child: Icon(icon),
        ),
      );
    });
  }
}
