import 'package:isar/isar.dart';

part 'group_model.g.dart';

/// Group model representing a collection of people and expenses
@collection
class Group {
  /// Unique identifier
  Id id = Isar.autoIncrement;

  /// Group name (e.g., "Bali Trip", "Flat Expenses")
  late String name;

  /// Emoji for visual identification
  late String emoji;

  /// Currency code (e.g., "USD", "EUR", "PKR")
  late String currency;

  /// Timestamp when group was created
  late DateTime createdAt;

  /// Whether the group is archived
  @Index()
  bool isArchived = false;

  /// Optional path to cover image
  String? imagePath;

  /// Member IDs in this group
  late List<int> memberIds;

  /// Constructor
  Group({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.emoji,
    required this.currency,
    this.imagePath,
    this.isArchived = false,
    this.memberIds = const [],
  }) : createdAt = DateTime.now();

  /// Empty constructor for Isar
  Group.empty()
    : name = '',
      emoji = '👥',
      currency = 'USD',
      createdAt = DateTime.now(),
      isArchived = false,
      memberIds = [];
}
