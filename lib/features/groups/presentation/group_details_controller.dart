import 'dart:async';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../../../core/utils/balance_calculator.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/settlement_model.dart';
import '../../../data/models/social_models.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/social_service.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:math';

/// Controller for Group Details Screen
class GroupDetailsController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final int groupId;

  GroupDetailsController(this.groupId);

  StreamSubscription? _expenseSubscription;
  StreamSubscription? _groupSubscription;
  StreamSubscription? _settlementSubscription;

  // MARK: - Observable State

  final Rx<Group?> group = Rx<Group?>(null);
  final RxList<Member> members = <Member>[].obs;
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Settlement> settlements = <Settlement>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<int, double> balances = <int, double>{}.obs;

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    loadGroupDetails();
    _setupWatchers();
  }

  @override
  void onClose() {
    _expenseSubscription?.cancel();
    _groupSubscription?.cancel();
    _settlementSubscription?.cancel();
    super.onClose();
  }

  Future<void> _setupWatchers() async {
    final db = await _db.isar;

    // Watch for expense changes
    _expenseSubscription = db.expenses
        .filter()
        .groupIdEqualTo(groupId)
        .watchLazy()
        .listen((_) => loadGroupDetails());

    // Watch for settlement changes
    _settlementSubscription = db.settlements
        .filter()
        .groupIdEqualTo(groupId)
        .watchLazy()
        .listen((_) => loadGroupDetails());

    // Watch for group changes
    _groupSubscription = db.groups
        .watchObject(groupId)
        .listen((_) => loadGroupDetails());
  }

  // MARK: - Data Loading

  bool _loadedOnce = false;

  Future<void> loadGroupDetails() async {
    try {
      // Watchers reload often; only show the full-screen spinner initially
      if (!_loadedOnce) isLoading.value = true;

      // Load group
      group.value = await _db.getGroupById(groupId);

      if (group.value != null) {
        // Load data in parallel
        final results = await Future.wait([
          _db.getMembersByIds(group.value!.memberIds),
          _db.getExpensesByGroup(groupId),
          _db.getSettlementsByGroup(groupId),
        ]);

        members.value = results[0] as List<Member>;
        expenses.value = results[1] as List<Expense>;
        settlements.value = results[2] as List<Settlement>;

        // Calculate balances
        _calculateBalances();
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to load group details: $e');
    } finally {
      _loadedOnce = true;
      isLoading.value = false;
    }
  }

  // MARK: - Balance Calculation

  void _calculateBalances() {
    balances.value = BalanceCalculator.calculate(
      memberIds: members.map((m) => m.id),
      expenses: expenses,
      settlements: settlements,
    );
  }

  // MARK: - Actions

  Future<void> deleteExpense(int expenseId) async {
    try {
      await _db.deleteExpense(expenseId);
      // Watcher will reload data
      SnackbarUtils.showSuccess('Success', 'Expense deleted');
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to delete expense: $e');
    }
  }

  Future<void> toggleArchive() async {
    if (group.value == null) return;
    final wasArchived = group.value!.isArchived;
    try {
      await _db.toggleGroupArchive(groupId);
      // The popup menu is already closed; go back to the group list
      Get.back();
      SnackbarUtils.showSuccess(
        'Success',
        wasArchived ? 'Group unarchived' : 'Group archived',
      );
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to update archive status: $e');
    }
  }

  Future<void> deleteGroup() async {
    try {
      await _db.deleteGroup(groupId);
      Get.until((route) => route.isFirst);
      SnackbarUtils.showSuccess('Success', 'Group deleted');
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to delete group: $e');
    }
  }

  // MARK: - Member Management

  Future<void> addMember(String name, String emoji, String colorHex) async {
    if (group.value == null) return;
    try {
      final member = Member(name: name, emoji: emoji, colorHex: colorHex);
      final memberId = await _db.createMember(member);

      final updatedGroup = group.value!;
      final currentMemberIds = updatedGroup.memberIds.toList();
      currentMemberIds.add(memberId);
      updatedGroup.memberIds = currentMemberIds;

      await _db.updateGroup(updatedGroup);

      Get.back(); // Close dialog
      SnackbarUtils.showSuccess('Success', 'Member added successfully');
      // Watcher handles reload
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to add member: $e');
    }
  }

  Set<String> get linkedUids =>
      members.map((m) => m.uid).whereType<String>().toSet();

  void _notifyFriends(Iterable<String> uids) {
    final name = group.value?.name;
    if (name == null || uids.isEmpty || !Get.isRegistered<SocialService>()) {
      return;
    }
    SocialService.to.notifyAddedToGroup(uids, name);
  }

  /// Adds friends as members; the group then syncs to their accounts
  Future<void> addFriends(List<Friend> friends) async {
    final current = group.value;
    if (current == null || friends.isEmpty) return;
    try {
      final fresh = friends.where((f) => !linkedUids.contains(f.uid)).toList();
      final ids = current.memberIds.toList();
      for (final f in fresh) {
        final color = AppColors
            .avatarColors[Random().nextInt(AppColors.avatarColors.length)];
        ids.add(
          await _db.createMember(
            Member(
              name: f.displayName,
              emoji: '👤',
              colorHex: color
                  .toARGB32()
                  .toRadixString(16)
                  .padLeft(8, '0')
                  .substring(2)
                  .toUpperCase(),
              uid: f.uid,
            ),
          ),
        );
      }
      current.memberIds = ids;
      await _db.updateGroup(current);
      _notifyFriends(fresh.map((f) => f.uid));
      SnackbarUtils.showSuccess(
        'Friends added',
        'The group now appears in their app',
      );
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to add friends: $e');
    }
  }

  /// Connects a local-only member to a friend's account. All of that
  /// member's expenses and settlements become visible to the friend.
  Future<void> linkMember(int memberId, Friend friend) async {
    final current = group.value;
    final member = getMemberById(memberId);
    if (current == null || member == null) return;
    if (linkedUids.contains(friend.uid)) {
      SnackbarUtils.showError(
        'Already in group',
        '${friend.displayName} is already a member of this group',
      );
      return;
    }
    try {
      member
        ..uid = friend.uid
        ..name = friend.displayName;
      await _db.updateMember(member);
      await _db.updateGroup(current); // pushes the new member link
      _notifyFriends([friend.uid]);
      SnackbarUtils.showSuccess(
        'Linked',
        '${member.name} is now connected to @${friend.username}',
      );
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to link member: $e');
    }
  }

  Future<void> removeMember(int memberId) async {
    if (group.value == null) return;

    if (expenses.isNotEmpty) {
      SnackbarUtils.showError(
        'Cannot Remove',
        'Members cannot be removed once expenses are listed in the group.',
      );
      return;
    }

    try {
      final updatedGroup = group.value!;
      final currentMemberIds = updatedGroup.memberIds.toList();
      currentMemberIds.remove(memberId);
      updatedGroup.memberIds = currentMemberIds;

      await _db.updateGroup(updatedGroup);
      await _db.deleteMember(memberId);

      SnackbarUtils.showSuccess('Success', 'Member removed');
      // Watcher handles reload
    } catch (e) {
      SnackbarUtils.showError('Error', 'Failed to remove member: $e');
    }
  }

  // MARK: - Computed Properties

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Member? getMemberById(int id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
