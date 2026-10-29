import 'package:isar_community/isar.dart';

part 'settlement_model.g.dart';

/// Settlement model representing a payment between members
@collection
class Settlement {
  /// Unique identifier
  Id id = Isar.autoIncrement;

  /// Group ID this settlement belongs to
  @Index()
  late int groupId;

  /// Member ID who is paying
  late int fromMemberId;

  /// Member ID who is receiving
  late int toMemberId;

  /// Amount being settled
  late double amount;

  /// Timestamp when settlement was made
  late DateTime settledAt;

  /// Whether this is a partial payment
  bool isPartial = false;

  /// Optional notes
  String? notes;

  /// Stable id shared with Firestore (assigned on first save)
  @Index()
  String? remoteId;

  /// Last local or remote modification, used for conflict resolution
  DateTime? updatedAt;

  /// True while a local change hasn't been confirmed by the server
  bool pendingSync = false;

  /// Constructor
  Settlement({
    this.id = Isar.autoIncrement,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    this.isPartial = false,
    this.notes,
  }) : settledAt = DateTime.now();

  /// Empty constructor for Isar
  Settlement.empty()
    : groupId = 0,
      fromMemberId = 0,
      toMemberId = 0,
      amount = 0.0,
      settledAt = DateTime.now(),
      isPartial = false,
      notes = null;
}
