import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';

/// Notified after every local write so changes can be pushed to the cloud.
/// Implemented by SyncService while a user is signed in.
abstract class SyncHooks {
  void groupChanged(int groupId);
  void groupArchiveChanged(int groupId, bool archived);
  void groupDeleted(Group group, List<Member> members);
  void expenseChanged(int expenseId);
  void expenseDeleted(String? groupRemoteId, String? expenseRemoteId);
  void settlementChanged(int settlementId);
  void settlementDeleted(String? groupRemoteId, String? settlementRemoteId);
}

/// Database service for managing Isar database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

  /// Set by SyncService; null in offline-only mode
  static SyncHooks? syncHooks;

  static const _uuid = Uuid();
  static String newRemoteId() => _uuid.v4();

  /// Get Isar instance
  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    _isar = await _initIsar();
    return _isar!;
  }

  /// Initialize Isar database
  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [GroupSchema, MemberSchema, ExpenseSchema, SettlementSchema],
      directory: dir.path,
      inspector: true, // Enable Isar Inspector for debugging
    );
  }

  void _stampGroup(Group group) {
    group.remoteId ??= newRemoteId();
    group.updatedAt = DateTime.now();
    group.pendingSync = true;
  }

  // MARK: - Group Operations

  /// Create a new group
  Future<int> createGroup(Group group) async {
    final db = await isar;
    _stampGroup(group);
    final id = await db.writeTxn(() async {
      return await db.groups.put(group);
    });
    syncHooks?.groupChanged(id);
    return id;
  }

  /// Get all groups (excluding archived by default)
  Future<List<Group>> getAllGroups({bool includeArchived = false}) async {
    final db = await isar;
    if (includeArchived) {
      return await db.groups.where().findAll();
    }
    return await db.groups.filter().isArchivedEqualTo(false).findAll();
  }

  /// Get group by ID
  Future<Group?> getGroupById(int id) async {
    final db = await isar;
    return await db.groups.get(id);
  }

  /// Update group
  Future<void> updateGroup(Group group) async {
    final db = await isar;
    _stampGroup(group);
    await db.writeTxn(() async {
      await db.groups.put(group);
    });
    syncHooks?.groupChanged(group.id);
  }

  /// Archive/Unarchive group (archiving is per user, not shared)
  Future<void> toggleGroupArchive(int groupId) async {
    final db = await isar;
    final group = await getGroupById(groupId);
    if (group != null) {
      group.isArchived = !group.isArchived;
      await db.writeTxn(() async {
        await db.groups.put(group);
      });
      syncHooks?.groupArchiveChanged(groupId, group.isArchived);
    }
  }

  /// Delete group and all related data
  Future<void> deleteGroup(int groupId) async {
    final db = await isar;
    final group = await getGroupById(groupId);
    if (group == null) return;
    final members = await getMembersByIds(group.memberIds);
    await db.writeTxn(() async {
      // Delete all expenses for this group
      await db.expenses.filter().groupIdEqualTo(groupId).deleteAll();
      // Delete all settlements for this group
      await db.settlements.filter().groupIdEqualTo(groupId).deleteAll();
      await db.members.deleteAll(group.memberIds);
      // Delete the group
      await db.groups.delete(groupId);
    });
    syncHooks?.groupDeleted(group, members);
  }

  /// Groups (on this device) that contain a member linked to [uid]
  Future<List<Group>> getGroupsWithMemberUid(String uid) async {
    final db = await isar;
    final memberIds = (await db.members.filter().uidEqualTo(uid).findAll())
        .map((m) => m.id)
        .toSet();
    final groups = await db.groups.where().findAll();
    return groups.where((g) => g.memberIds.any(memberIds.contains)).toList();
  }

  // MARK: - Member Operations
  // Members are synced as part of their group, so callers update the group
  // afterwards (which triggers the push).

  /// Create a new member
  Future<int> createMember(Member member) async {
    final db = await isar;
    member.remoteId ??= newRemoteId();
    return await db.writeTxn(() async {
      return await db.members.put(member);
    });
  }

  /// Get all members
  Future<List<Member>> getAllMembers() async {
    final db = await isar;
    return await db.members.where().findAll();
  }

  /// Get member by ID
  Future<Member?> getMemberById(int id) async {
    final db = await isar;
    return await db.members.get(id);
  }

  /// Get members by IDs
  Future<List<Member>> getMembersByIds(List<int> ids) async {
    final db = await isar;
    return await db.members.getAll(ids).then((members) {
      return members.whereType<Member>().toList();
    });
  }

  /// Update member
  Future<void> updateMember(Member member) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.members.put(member);
    });
  }

  /// Delete member
  Future<void> deleteMember(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.members.delete(id);
    });
  }

  // MARK: - Expense Operations

  /// Create a new expense
  Future<int> createExpense(Expense expense) async {
    final db = await isar;
    expense.remoteId ??= newRemoteId();
    expense.updatedAt = DateTime.now();
    expense.pendingSync = true;
    final id = await db.writeTxn(() async {
      return await db.expenses.put(expense);
    });
    syncHooks?.expenseChanged(id);
    return id;
  }

  /// Get all expenses for a group
  Future<List<Expense>> getExpensesByGroup(int groupId) async {
    final db = await isar;
    return await db.expenses
        .filter()
        .groupIdEqualTo(groupId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    final db = await isar;
    return await db.expenses.get(id);
  }

  /// Update expense
  Future<void> updateExpense(Expense expense) async {
    final db = await isar;
    expense.remoteId ??= newRemoteId();
    expense.updatedAt = DateTime.now();
    expense.pendingSync = true;
    await db.writeTxn(() async {
      await db.expenses.put(expense);
    });
    syncHooks?.expenseChanged(expense.id);
  }

  /// Delete expense
  Future<void> deleteExpense(int id) async {
    final db = await isar;
    final expense = await db.expenses.get(id);
    if (expense == null) return;
    final group = await db.groups.get(expense.groupId);
    await db.writeTxn(() async {
      await db.expenses.delete(id);
    });
    syncHooks?.expenseDeleted(group?.remoteId, expense.remoteId);
  }

  /// Get expenses by category for a group
  Future<List<Expense>> getExpensesByCategory(
    int groupId,
    String category,
  ) async {
    final db = await isar;
    return await db.expenses
        .filter()
        .groupIdEqualTo(groupId)
        .categoryEqualTo(category)
        .findAll();
  }

  // MARK: - Settlement Operations

  /// Create a new settlement
  Future<int> createSettlement(Settlement settlement) async {
    final db = await isar;
    settlement.remoteId ??= newRemoteId();
    settlement.updatedAt = DateTime.now();
    settlement.pendingSync = true;
    final id = await db.writeTxn(() async {
      return await db.settlements.put(settlement);
    });
    syncHooks?.settlementChanged(id);
    return id;
  }

  /// Get all settlements for a group
  Future<List<Settlement>> getSettlementsByGroup(int groupId) async {
    final db = await isar;
    return await db.settlements
        .filter()
        .groupIdEqualTo(groupId)
        .sortBySettledAtDesc()
        .findAll();
  }

  /// Get settlement by ID
  Future<Settlement?> getSettlementById(int id) async {
    final db = await isar;
    return await db.settlements.get(id);
  }

  /// Update settlement
  Future<void> updateSettlement(Settlement settlement) async {
    final db = await isar;
    settlement.remoteId ??= newRemoteId();
    settlement.updatedAt = DateTime.now();
    settlement.pendingSync = true;
    await db.writeTxn(() async {
      await db.settlements.put(settlement);
    });
    syncHooks?.settlementChanged(settlement.id);
  }

  /// Delete settlement
  Future<void> deleteSettlement(int id) async {
    final db = await isar;
    final settlement = await db.settlements.get(id);
    if (settlement == null) return;
    final group = await db.groups.get(settlement.groupId);
    await db.writeTxn(() async {
      await db.settlements.delete(id);
    });
    syncHooks?.settlementDeleted(group?.remoteId, settlement.remoteId);
  }

  // MARK: - Utility Methods

  /// Clear all data (sign-out / reset). Never synced.
  Future<void> clearAllData() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.clear();
    });
  }

  /// Close database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }
}
