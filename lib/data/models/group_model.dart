import 'package:isar_community/isar.dart';

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

  /// Compressed cover image (JPEG, base64) - synced inside the group doc
  String? imageBase64;

  /// Firebase uid of the creator (null for groups never synced)
  String? ownerUid;

  /// Stable id shared with Firestore (assigned on first save)
  @Index()
  String? remoteId;

  /// Last local or remote modification, used for conflict resolution
  DateTime? updatedAt;

  /// True while a local change hasn't been confirmed by the server
  bool pendingSync = false;

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
