import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';

/// Database service for managing Isar database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Isar? _isar;

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

  // MARK: - Group Operations

  /// Create a new group
  Future<int> createGroup(Group group) async {
    final db = await isar;
    return await db.writeTxn(() async {
      return await db.groups.put(group);
    });
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
    await db.writeTxn(() async {
      await db.groups.put(group);
    });
  }

  /// Archive/Unarchive group
  Future<void> toggleGroupArchive(int groupId) async {
    final db = await isar;
    final group = await getGroupById(groupId);
    if (group != null) {
      group.isArchived = !group.isArchived;
      await updateGroup(group);
    }
  }

  /// Delete group and all related data
  Future<void> deleteGroup(int groupId) async {
    final db = await isar;
    await db.writeTxn(() async {
      // Delete all expenses for this group
      await db.expenses.filter().groupIdEqualTo(groupId).deleteAll();
      // Delete all settlements for this group
      await db.settlements.filter().groupIdEqualTo(groupId).deleteAll();
      // Delete the group
      await db.groups.delete(groupId);
    });
  }

  // MARK: - Member Operations

  /// Create a new member
  Future<int> createMember(Member member) async {
    final db = await isar;
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
    return await db.writeTxn(() async {
      return await db.expenses.put(expense);
    });
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
    await db.writeTxn(() async {
      await db.expenses.put(expense);
    });
  }

  /// Delete expense
  Future<void> deleteExpense(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.expenses.delete(id);
    });
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
    return await db.writeTxn(() async {
      return await db.settlements.put(settlement);
    });
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
    await db.writeTxn(() async {
      await db.settlements.put(settlement);
    });
  }

  /// Delete settlement
  Future<void> deleteSettlement(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.settlements.delete(id);
    });
  }

  // MARK: - Utility Methods

  /// Clear all data (for testing/reset)
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
