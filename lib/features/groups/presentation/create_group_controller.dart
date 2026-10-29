import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/group_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/social_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/social_service.dart';
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

  /// Compressed cover image, stored as base64 so it syncs inside the group
  /// document (no Firebase Storage needed)
  final RxnString selectedImageBase64 = RxnString();
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
    // Add default "You" member (the device owner, used for reminders)
    addMember('You', '👤', isMe: true);

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
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 60,
      );
      if (image == null) return;
      final encoded = base64Encode(await image.readAsBytes());
      // Firestore documents are capped at 1 MB; keep plenty of headroom
      if (encoded.length > 600 * 1024) {
        SnackbarUtils.showError(
          'Image too large',
          'Please pick a smaller image',
        );
        return;
      }
      selectedImageBase64.value = encoded;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  void addMember(String name, String emoji, {bool isMe = false, String? uid}) {
    // Generate a random pastel color
    final random = Random();
    final color =
        AppColors.avatarColors[random.nextInt(AppColors.avatarColors.length)];
    final colorHex = color.value.toRadixString(16).substring(2).toUpperCase();

    members.add({
      'name': name,
      'emoji': emoji,
      'color': colorHex,
      if (isMe) 'isMe': 'true',
      'uid': ?uid,
    });
  }

  Set<String> get friendUids =>
      members.map((m) => m['uid']).whereType<String>().toSet();

  void addFriends(List<Friend> friends) {
    for (final f in friends) {
      if (friendUids.contains(f.uid)) continue;
      addMember(f.displayName, '👤', uid: f.uid);
    }
  }

  void removeMember(Map<String, String> member) {
    if (members.length > 1) {
      members.remove(member);
    }
  }

  // MARK: - Validation

  bool get canCreate {
    return groupName.value.trim().isNotEmpty &&
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
          isMe: memberData['isMe'] == 'true',
          // The creator's own member is linked to their account
          uid: memberData['isMe'] == 'true'
              ? AuthService.to.uid
              : memberData['uid'],
        );
        final memberId = await _db.createMember(member);
        memberIds.add(memberId);
      }

      // Create group
      final group =
          Group(
              name: nameController.text.trim(),
              emoji: selectedEmoji.value,
              currency: selectedCurrency.value,
              memberIds: memberIds,
            )
            ..imageBase64 = selectedImageBase64.value
            ..ownerUid = AuthService.to.uid;

      await _db.createGroup(group);

      if (friendUids.isNotEmpty && Get.isRegistered<SocialService>()) {
        SocialService.to.notifyAddedToGroup(friendUids, group.name);
      }

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
