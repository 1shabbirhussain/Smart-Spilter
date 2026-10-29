import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/database_service.dart';

/// Controller for Group List Screen
class GroupListController extends GetxController {
  final DatabaseService _db = DatabaseService();

  // MARK: - Observable State

  final RxList<Group> groups = <Group>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showArchived = false.obs;

  StreamSubscription? _groupsSubscription;
  bool _loadedOnce = false;

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    loadGroups();
    _watchGroups();
  }

  @override
  void onClose() {
    _groupsSubscription?.cancel();
    super.onClose();
  }

  /// Keeps the list in sync with changes made on other screens
  /// (archive/delete from details, groups joined via invites, ...)
  Future<void> _watchGroups() async {
    final db = await _db.isar;
    _groupsSubscription = db.groups.watchLazy().listen((_) => loadGroups());
  }

  // MARK: - Data Loading

  Future<void> loadGroups() async {
    try {
      // Only show the spinner on first load to avoid flicker on refreshes
      if (!_loadedOnce) isLoading.value = true;
      final allGroups = await _db.getAllGroups(includeArchived: true);

      // Filter based on showArchived state
      if (showArchived.value) {
        // Show only archived groups
        groups.value = allGroups.where((g) => g.isArchived).toList();
      } else {
        // Show only non-archived groups
        groups.value = allGroups.where((g) => !g.isArchived).toList();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load groups: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _loadedOnce = true;
      isLoading.value = false;
    }
  }

  // MARK: - Actions

  void toggleArchived() {
    showArchived.value = !showArchived.value;
    loadGroups();
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      await _db.deleteGroup(groupId);
      await loadGroups();
      Get.snackbar(
        'Success',
        'Group deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete group: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleArchiveGroup(int groupId) async {
    try {
      await _db.toggleGroupArchive(groupId);
      await loadGroups();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to archive group: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
