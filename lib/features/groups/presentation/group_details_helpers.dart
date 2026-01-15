import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/snackbar_utils.dart'; // Ensure generic helper methods are not duplicating logic if possible, but this is fine.
import 'group_details_controller.dart';

/// Shows delete confirmation dialog
void showDeleteDialog(BuildContext context, GroupDetailsController controller) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete Group'),
      content: const Text(
        'Are you sure you want to delete this group? This will also delete all expenses and settlements.',
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Get.back(); // Close dialog
            await controller.deleteGroup();
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

/// Shows manage members dialog (add/remove)
void showManageMembersDialog(
  BuildContext context,
  GroupDetailsController controller,
) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Members',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add Member Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddMemberDialog(context, controller),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Group Member'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Current Members', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

          Expanded(
            child: Obx(
              () => ListView.separated(
                itemCount: controller.members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = controller.members[index];
                  final canRemove = controller.expenses.isEmpty;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse('0xFF${member.colorHex}'),
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              member.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            member.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: canRemove
                                ? AppColors.error
                                : Colors.grey[400],
                          ),
                          onPressed: () {
                            if (canRemove) {
                              _confirmRemoveMember(
                                context,
                                controller,
                                member.id,
                                member.name,
                              );
                            } else {
                              SnackbarUtils.showError(
                                'Unavailable',
                                'Cannot remove members when expenses exist.',
                              );
                            }
                          },
                          tooltip: canRemove
                              ? 'Remove'
                              : 'Cannot remove (Expenses exist)',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

void _confirmRemoveMember(
  BuildContext context,
  GroupDetailsController controller,
  int memberId,
  String name,
) {
  Get.dialog(
    AlertDialog(
      title: const Text('Remove Member'),
      content: Text('Are you sure you want to remove $name?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.removeMember(memberId);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

void _showAddMemberDialog(
  BuildContext context,
  GroupDetailsController controller,
) {
  final nameController = TextEditingController();
  final RxString selectedEmoji = '👤'.obs;
  // Use a default color for now or random
  final colorHex =
      'FF${(0xFFFFFF & DateTime.now().millisecondsSinceEpoch).toRadixString(16).padLeft(6, '0')}';

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter member name',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Obx(
            () => OutlinedButton.icon(
              onPressed: () {
                Get.bottomSheet(
                  Container(
                    height: 300,
                    color: Theme.of(context).cardColor,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        selectedEmoji.value = emoji.emoji;
                        Get.back(); // Close bottom sheet
                      },
                    ),
                  ),
                );
              },
              icon: Text(
                selectedEmoji.value,
                style: const TextStyle(fontSize: 20),
              ),
              label: const Text('Choose Emoji'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              controller.addMember(
                nameController.text,
                selectedEmoji.value,
                colorHex,
              );
              // Dialog closes inside controller
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
