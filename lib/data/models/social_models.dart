import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _toDate(dynamic value) =>
    value is Timestamp ? value.toDate() : DateTime.now();

/// Public profile stored at users/{uid}
class AppUser {
  final String uid;
  final String? username;
  final String displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.displayName,
    this.username,
    this.photoUrl,
  });

  bool get hasUsername => username != null && username!.isNotEmpty;

  /// "@username" when available, otherwise the display name
  String get handle => hasUsername ? '@$username' : displayName;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      username: data['username'] as String?,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? data['displayName'] as String
          : (data['username'] as String? ?? 'User'),
      photoUrl: data['photoUrl'] as String?,
    );
  }
}

/// Friend entry stored at users/{uid}/friends/{friendUid}
class Friend {
  final String uid;
  final String username;
  final String displayName;
  final String? photoUrl;

  const Friend({
    required this.uid,
    required this.username,
    required this.displayName,
    this.photoUrl,
  });

  factory Friend.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Friend(
      uid: doc.id,
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Friend',
      photoUrl: data['photoUrl'] as String?,
    );
  }

  static Map<String, dynamic> toMap(AppUser user) => {
    'username': user.username,
    'displayName': user.displayName,
    'photoUrl': user.photoUrl,
    'since': FieldValue.serverTimestamp(),
  };
}

/// Pending friend request stored at friendRequests/{fromUid}_{toUid}
class FriendRequest {
  final String id;
  final String fromUid;
  final String fromUsername;
  final String fromName;
  final String? fromPhotoUrl;
  final String toUid;
  final String toUsername;
  final String toName;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.fromUsername,
    required this.fromName,
    required this.toUid,
    required this.toUsername,
    required this.toName,
    required this.createdAt,
    this.fromPhotoUrl,
  });

  static String idFor(String fromUid, String toUid) => '${fromUid}_$toUid';

  factory FriendRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return FriendRequest(
      id: doc.id,
      fromUid: data['fromUid'] as String? ?? '',
      fromUsername: data['fromUsername'] as String? ?? '',
      fromName: data['fromName'] as String? ?? 'Someone',
      fromPhotoUrl: data['fromPhotoUrl'] as String?,
      toUid: data['toUid'] as String? ?? '',
      toUsername: data['toUsername'] as String? ?? '',
      toName: data['toName'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
    );
  }
}

enum AppNotificationType { friendRequest, friendAccepted, addedToGroup }

/// In-app inbox entry stored at users/{uid}/notifications/{id}
class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppNotification(
      id: doc.id,
      type: AppNotificationType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AppNotificationType.friendRequest,
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      createdAt: _toDate(data['createdAt']),
    );
  }
}
