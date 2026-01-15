import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import '../../../core/widgets/animated_button.dart';
import 'group_list_controller.dart';
import '../../settings/presentation/settings_screen.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';

/// Group List Screen - Main screen showing all expense groups
class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupListController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.showArchived.value
                    ? Icons.archive
                    : Icons.archive_outlined,
              ),
              onPressed: controller.toggleArchived,
              tooltip: 'Toggle Archived',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.groups.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: controller.loadGroups,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                itemCount: controller.groups.length,
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return _GroupCard(
                    group: group,
                    onTap: () {
                      Get.to(() => GroupDetailsScreen(groupId: group.id));
                    },
                    onArchive: () => controller.toggleArchiveGroup(group.id),
                    onDelete: () =>
                        _showDeleteDialog(context, controller, group.id),
                  );
                },
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateGroupScreen()),
        icon: const Icon(Icons.add),
        label: const Text('New Group'),
        backgroundColor: AppColors.lavenderGradient[1],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder for Lottie animation
          Icon(Icons.groups_outlined, size: 120, color: AppColors.grey400),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            'No Groups Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            'Create your first group to start\nsplitting expenses',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: AppDimensions.spacing32),
          AnimatedButton(
            text: 'Create Group',
            onPressed: () => Get.to(() => const CreateGroupScreen()),
            gradientColors: AppColors.lavenderGradient,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GroupListController controller,
    int groupId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This will also delete all expenses and settlements.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteGroup(groupId);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Group Card Widget
class _GroupCard extends StatelessWidget {
  final dynamic group;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing16),
      child: GlassmorphicCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Emoji Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.lavenderGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMedium,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      group.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacing16),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.memberIds.length} members • ${group.currency}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // More Options
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            group.isArchived ? Icons.unarchive : Icons.archive,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(group.isArchived ? 'Unarchive' : 'Archive'),
                        ],
                      ),
                      onTap: onArchive,
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: const [
                          Icon(Icons.delete, size: 20, color: AppColors.error),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),

            if (group.isArchived) ...[
              const SizedBox(height: AppDimensions.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey300.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusSmall,
                  ),
                ),
                child: Text(
                  'ARCHIVED',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
