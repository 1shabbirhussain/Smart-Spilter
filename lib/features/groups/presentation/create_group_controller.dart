import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/services/database_service.dart';
import 'group_list_controller.dart';

/// Controller for Create Group Screen
class CreateGroupController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  // MARK: - Form Controllers

  final nameController = TextEditingController();

  // MARK: - Observable State

  final RxString selectedEmoji = '👥'.obs;
  final RxString selectedCurrency = 'USD'.obs;
  final RxnString selectedImagePath = RxnString();
  final RxList<Map<String, String>> members = <Map<String, String>>[].obs;
  final RxBool isCreating = false.obs;
  final RxString groupName = ''.obs;

  // MARK: - Data

  final List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'PKR',
    'INR',
    'AED',
    'SAR',
    'JPY',
    'CNY',
    'AUD',
  ];

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    // Add default "You" member
    addMember('You', '👤');

    nameController.addListener(() {
      groupName.value = nameController.text;
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // MARK: - Actions

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void addMember(String name, String emoji) {
    // Generate a random pastel color
    final random = Random();
    final color =
        AppColors.avatarColors[random.nextInt(AppColors.avatarColors.length)];
    final colorHex = color.value.toRadixString(16).substring(2).toUpperCase();

    members.add({'name': name, 'emoji': emoji, 'color': colorHex});
  }

  void removeMember(Map<String, String> member) {
    if (members.length > 1) {
      members.remove(member);
    }
  }

  // MARK: - Validation

  bool get canCreate {
    return groupName.value.isNotEmpty &&
        members.isNotEmpty &&
        !isCreating.value;
  }

  // MARK: - Group Creation

  Future<void> createGroup() async {
    if (!canCreate) return;

    try {
      isCreating.value = true;

      // Create members first
      final memberIds = <int>[];
      for (final memberData in members) {
        final member = Member(
          name: memberData['name']!,
          emoji: memberData['emoji']!,
          colorHex: memberData['color']!,
        );
        final memberId = await _db.createMember(member);
        memberIds.add(memberId);
      }

      // Create group
      final group = Group(
        name: nameController.text.trim(),
        emoji: selectedEmoji.value,
        currency: selectedCurrency.value,
        imagePath: selectedImagePath.value,
        memberIds: memberIds,
      );

      await _db.createGroup(group);

      // Refresh group list
      if (Get.isRegistered<GroupListController>()) {
        await Get.find<GroupListController>().loadGroups();
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Group created successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create group: $e');
    } finally {
      isCreating.value = false;
    }
  }
}
