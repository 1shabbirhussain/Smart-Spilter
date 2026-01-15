import 'dart:async';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/settlement_model.dart';
import '../../../data/services/database_service.dart';

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

  Future<void> loadGroupDetails() async {
    try {
      isLoading.value = true;

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
      isLoading.value = false;
    }
  }

  // MARK: - Balance Calculation

  void _calculateBalances() {
    final Map<int, double> tempBalances = {};

    // Initialize all members with 0 balance
    for (final member in members) {
      tempBalances[member.id] = 0.0;
    }

    // 1. Calculate balances from Expenses
    for (final expense in expenses) {
      // Person who paid gets positive balance (money owed TO them)
      tempBalances[expense.paidById] =
          (tempBalances[expense.paidById] ?? 0) + expense.amount;

      // People who split get negative balance (money they OWE)
      for (final split in expense.splits) {
        tempBalances[split.memberId] =
            (tempBalances[split.memberId] ?? 0) - split.amount;
      }
    }

    // 2. Apply Settlements (Payments reduce balances)
    for (final settlement in settlements) {
      // Payer (fromMemberId) PAID money, so their balance increases (debt reduces)
      // e.g. If balance was -100 (debt), paying 100 makes it 0.
      tempBalances[settlement.fromMemberId] =
          (tempBalances[settlement.fromMemberId] ?? 0) + settlement.amount;

      // Receiver (toMemberId) RECEIVED money, so their balance decreases (credit reduces)
      // e.g. If balance was +100 (credit), receiving 100 makes it 0.
      tempBalances[settlement.toMemberId] =
          (tempBalances[settlement.toMemberId] ?? 0) - settlement.amount;
    }

    balances.value = tempBalances;
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
    try {
      await _db.toggleGroupArchive(groupId);
      // Watcher will reload data
      Get.back(); // Close menu
      SnackbarUtils.showSuccess(
        'Success',
        group.value!.isArchived ? 'Group unarchived' : 'Group archived',
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
