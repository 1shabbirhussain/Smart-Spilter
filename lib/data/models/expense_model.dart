import 'package:isar/isar.dart';

part 'expense_model.g.dart';

/// Split type enum
enum SplitType { equal, custom, percentage }

/// Expense split embedded object
@embedded
class ExpenseSplit {
  /// Member ID
  late int memberId;

  /// Amount (actual amount for custom, percentage for percentage split)
  late double amount;

  /// Constructor
  ExpenseSplit({this.memberId = 0, this.amount = 0.0});

  /// Empty constructor for Isar
  ExpenseSplit.empty() : memberId = 0, amount = 0.0;
}

/// Expense model representing a single expense in a group
@collection
class Expense {
  /// Unique identifier
  Id id = Isar.autoIncrement;

  /// Group ID this expense belongs to
  @Index()
  late int groupId;

  /// Expense title
  late String title;

  /// Total amount
  late double amount;

  /// Category (Food, Transport, Shopping, etc.)
  late String category;

  /// Optional notes
  String? notes;

  /// Timestamp when expense was created
  late DateTime createdAt;

  /// Member ID who paid for this expense
  late int paidById;

  /// Split type
  @enumerated
  late SplitType splitType;

  /// Split details for each member
  late List<ExpenseSplit> splits;

  /// Constructor
  Expense({
    this.id = Isar.autoIncrement,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.category,
    this.notes,
    required this.paidById,
    required this.splitType,
    required this.splits,
  }) : createdAt = DateTime.now();

  /// Empty constructor for Isar
  Expense.empty()
    : groupId = 0,
      title = '',
      amount = 0.0,
      category = 'Other',
      notes = null,
      createdAt = DateTime.now(),
      paidById = 0,
      splitType = SplitType.equal,
      splits = [];
}
