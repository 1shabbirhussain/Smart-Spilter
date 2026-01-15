import 'package:isar/isar.dart';

part 'member_model.g.dart';

/// Member model representing a person in a group
@collection
class Member {
  /// Unique identifier
  Id id = Isar.autoIncrement;

  /// Member's name
  late String name;

  /// Emoji for visual identification
  late String emoji;

  /// Color hex code for avatar background (e.g., "FF6B9D")
  late String colorHex;

  /// Timestamp when member was created
  late DateTime createdAt;

  /// Constructor
  Member({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.emoji,
    required this.colorHex,
  }) : createdAt = DateTime.now();

  /// Empty constructor for Isar
  Member.empty()
    : name = '',
      emoji = '👤',
      colorHex = 'FF6B9D',
      createdAt = DateTime.now();
}
