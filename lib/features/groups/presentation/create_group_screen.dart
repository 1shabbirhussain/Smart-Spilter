import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/animated_button.dart';
import 'create_group_controller.dart';

/// Create Group Screen
class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateGroupController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Create Group')),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacing24),

                // Group Identity Section (Emoji & Image)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji Selector
                    _buildIdentitySelector(
                      context,
                      onTap: () => _showEmojiPicker(context, controller),
                      child: Obx(
                        () => Text(
                          controller.selectedEmoji.value,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      label: 'Emoji',
                    ),
                    const SizedBox(width: AppDimensions.spacing24),
                    // Image Selector
                    _buildIdentitySelector(
                      context,
                      onTap: controller.pickImage,
                      child: Obx(() {
                        if (controller.selectedImagePath.value != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            child: Image.file(
                              File(controller.selectedImagePath.value!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          );
                        }
                        return const Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: Colors.white,
                        );
                      }),
                      label: 'Cover',
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Group Name
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g., Bali Trip, Flat Expenses',
                    prefixIcon: const Icon(Icons.group),
                    filled: true,
                    fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMedium,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Currency Selector
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.selectedCurrency.value,
                    decoration: InputDecoration(
                      labelText: 'Currency',
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: controller.currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCurrency.value = value;
                      }
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Members Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Members',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          _showAddMemberDialog(context, controller),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacing12),

                Obx(
                  () => Column(
                    children: controller.members.map((member) {
                      return _MemberTile(
                        name: member['name']!,
                        emoji: member['emoji']!,
                        color: Color(int.parse('0xFF${member['color']}')),
                        onDelete: () => controller.removeMember(member),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing40),

                // Create Button
                Obx(
                  () => AnimatedButton(
                    text: 'Create Group',
                    onPressed: controller.canCreate
                        ? () => controller.createGroup()
                        : null,
                    gradientColors: controller.canCreate
                        ? AppColors.lavenderGradient
                        : [AppColors.grey400, AppColors.grey400],
                    isLoading: controller.isCreating.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentitySelector(
    BuildContext context, {
    required VoidCallback onTap,
    required Widget child,
    required String label,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.lavenderGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lavenderGradient[1].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showEmojiPicker(
    BuildContext context,
    CreateGroupController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  controller.selectedEmoji.value = emoji.emoji;
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    CreateGroupController controller,
  ) {
    final nameController = TextEditingController();
    final RxString selectedEmoji = '👤'.obs;

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
                controller.addMember(nameController.text, selectedEmoji.value);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Member Tile Widget
class _MemberTile extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;
  final VoidCallback onDelete;

  const _MemberTile({
    required this.name,
    required this.emoji,
    required this.color,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: Theme.of(context).textTheme.titleMedium),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: onDelete,
            color: AppColors.grey600,
          ),
        ],
      ),
    );
  }
}
