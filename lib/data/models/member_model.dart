import 'package:isar_community/isar.dart';

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

  /// Whether this member represents the device owner ("You")
  bool isMe = false;

  /// Firebase uid when this member is a linked friend
  String? uid;

  /// Stable id shared with Firestore (members live inside the group doc)
  String? remoteId;

  /// Constructor
  Member({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.emoji,
    required this.colorHex,
    this.isMe = false,
    this.uid,
  }) : createdAt = DateTime.now();

  /// True for the device owner, including groups created before [isMe] existed
  bool get representsMe => isMe || name == 'You';

  /// Empty constructor for Isar
  Member.empty()
    : name = '',
      emoji = '👤',
      colorHex = 'FF6B9D',
      createdAt = DateTime.now();
}
