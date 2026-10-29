import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/services/notification_service.dart';
import '../models/social_models.dart';
import 'auth_service.dart';
import 'firestore_paths.dart';

/// Friends, friend requests and the notification inbox.
/// Paths are documented in [FsPaths]; friend requests only exist while
/// pending.
class SocialService extends GetxService {
  static SocialService get to => Get.find<SocialService>();

  final AuthService _auth = AuthService.to;
  FirebaseFirestore get _fs => FirebaseFirestore.instance;

  final RxList<Friend> friends = <Friend>[].obs;
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;
  final RxList<FriendRequest> outgoingRequests = <FriendRequest>[].obs;
  final RxList<AppNotification> inbox = <AppNotification>[].obs;

  final List<StreamSubscription> _subs = [];
  Worker? _authWorker;
  bool _inboxPrimed = false;
  String? _boundUid;

  int get pendingCount => incomingRequests.length;
  int get unreadCount => inbox.where((n) => !n.read).length;

  @override
  void onInit() {
    super.onInit();
    // Re-bind listeners whenever the signed-in user changes
    _authWorker = ever(_auth.user, (_) {
      if (_auth.uid != _boundUid) _bind();
    });
    _bind();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    _unbind();
    super.onClose();
  }

  String? get _me => _auth.uid;

  void _unbind() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    friends.clear();
    incomingRequests.clear();
    outgoingRequests.clear();
    inbox.clear();
    _inboxPrimed = false;
  }

  void _bind() {
    _unbind();
    final me = _me;
    _boundUid = me;
    if (me == null) return;

    void onError(Object e) => debugPrint('Social listener error: $e');

    _subs.add(
      FsPaths.friends(me).snapshots().listen((snap) {
        friends.value = snap.docs.map(Friend.fromDoc).toList()
          ..sort(
            (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
          );
      }, onError: onError),
    );

    _subs.add(
      FsPaths.friendRequests.where('toUid', isEqualTo: me).snapshots().listen((
        snap,
      ) {
        incomingRequests.value = snap.docs.map(FriendRequest.fromDoc).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }, onError: onError),
    );

    _subs.add(
      FsPaths.friendRequests.where('fromUid', isEqualTo: me).snapshots().listen(
        (snap) {
          outgoingRequests.value = snap.docs.map(FriendRequest.fromDoc).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        },
        onError: onError,
      ),
    );

    _subs.add(
      FsPaths.notifications(me)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(_onInboxSnapshot, onError: onError),
    );
  }

  void _onInboxSnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    inbox.value = snap.docs.map(AppNotification.fromDoc).toList();

    // The first snapshot is history; only alert for items that arrive later
    if (!_inboxPrimed) {
      _inboxPrimed = true;
      return;
    }
    for (final change in snap.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final n = AppNotification.fromDoc(change.doc);
      if (n.read) continue;
      NotificationService.instance.showSocial(
        tag: n.id,
        title: n.title,
        body: n.body,
      );
    }
  }

  // MARK: - Lookup

  /// Finds a user by username (with or without "@") or by user id
  Future<AppUser?> findUser(String query) async {
    final raw = query.trim();
    if (raw.isEmpty) return null;

    final username = AuthService.normalizeUsername(raw);
    if (AuthService.usernamePattern.hasMatch(username)) {
      final nameDoc = await FsPaths.usernames.doc(username).get();
      final uid = nameDoc.data()?['uid'] as String?;
      if (uid != null) {
        final userDoc = await FsPaths.users.doc(uid).get();
        if (userDoc.exists) return AppUser.fromDoc(userDoc);
      }
    }

    // Fall back to treating the query as a user id
    if (raw.contains('/')) return null; // not a valid document id
    final byId = await FsPaths.users.doc(raw).get();
    return byId.exists ? AppUser.fromDoc(byId) : null;
  }

  bool isFriend(String uid) => friends.any((f) => f.uid == uid);
  bool hasOutgoingRequest(String uid) =>
      outgoingRequests.any((r) => r.toUid == uid);

  // MARK: - Friend requests

  AppUser get _myProfile {
    final profile = _auth.profile.value;
    if (profile == null || !profile.hasUsername) {
      throw Exception('Set up your username first');
    }
    return profile;
  }

  Future<void> _notify({
    required String toUid,
    required AppNotificationType type,
    required String title,
    required String body,
    String? refId,
    WriteBatch? batch,
  }) async {
    final ref = FsPaths.notifications(toUid).doc();
    final data = {
      'type': type.name,
      'title': title,
      'body': body,
      'fromUid': _me,
      'refId': refId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (batch != null) {
      batch.set(ref, data);
    } else {
      await ref.set(data);
    }
  }

  /// Sends a request, or accepts theirs if they already asked you
  Future<String> sendFriendRequest(AppUser target) async {
    final me = _myProfile;
    if (target.uid == me.uid) throw Exception("You can't add yourself");
    if (isFriend(target.uid)) throw Exception('You are already friends');
    if (hasOutgoingRequest(target.uid)) {
      throw Exception('Request already sent');
    }

    final theirs = incomingRequests.firstWhereOrNull(
      (r) => r.fromUid == target.uid,
    );
    if (theirs != null) {
      await acceptFriendRequest(theirs);
      return 'You are now friends with ${target.displayName}';
    }

    final id = FriendRequest.idFor(me.uid, target.uid);
    final batch = _fs.batch();
    batch.set(FsPaths.friendRequests.doc(id), {
      'fromUid': me.uid,
      'fromUsername': me.username,
      'fromName': me.displayName,
      'fromPhotoUrl': me.photoUrl,
      'toUid': target.uid,
      'toUsername': target.username,
      'toName': target.displayName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _notify(
      toUid: target.uid,
      type: AppNotificationType.friendRequest,
      title: 'New friend request',
      body: '${me.displayName} (@${me.username}) wants to be your friend',
      refId: id,
      batch: batch,
    );
    await batch.commit();
    return 'Friend request sent to ${target.displayName}';
  }

  Future<void> acceptFriendRequest(FriendRequest request) async {
    final me = _myProfile;
    final batch = _fs.batch();
    batch.set(FsPaths.friends(me.uid).doc(request.fromUid), {
      'username': request.fromUsername,
      'displayName': request.fromName,
      'photoUrl': request.fromPhotoUrl,
      'since': FieldValue.serverTimestamp(),
    });
    batch.set(FsPaths.friends(request.fromUid).doc(me.uid), Friend.toMap(me));
    batch.delete(FsPaths.friendRequests.doc(request.id));
    await _notify(
      toUid: request.fromUid,
      type: AppNotificationType.friendAccepted,
      title: 'Friend request accepted',
      body: '${me.displayName} accepted your friend request',
      batch: batch,
    );
    await batch.commit();
  }

  /// Decline an incoming request or cancel one you sent
  Future<void> deleteFriendRequest(FriendRequest request) {
    return FsPaths.friendRequests.doc(request.id).delete();
  }

  Future<void> removeFriend(String friendUid) async {
    final me = _me;
    if (me == null) return;
    final batch = _fs.batch();
    batch.delete(FsPaths.friends(me).doc(friendUid));
    batch.delete(FsPaths.friends(friendUid).doc(me));
    await batch.commit();
  }

  // MARK: - Groups

  /// Tell friends they were added to (or linked into) one of your groups
  Future<void> notifyAddedToGroup(
    Iterable<String> uids,
    String groupName,
  ) async {
    final me = _auth.profile.value;
    final myUid = _me;
    if (me == null || myUid == null) return;
    final batch = _fs.batch();
    var any = false;
    for (final uid in uids.toSet()) {
      if (uid == myUid) continue;
      any = true;
      await _notify(
        toUid: uid,
        type: AppNotificationType.addedToGroup,
        title: 'Added to a group',
        body: '${me.displayName} added you to their group "$groupName"',
        batch: batch,
      );
    }
    if (!any) return;
    try {
      // Not awaited for long when offline: Firestore queues it
      await batch.commit().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Group notification queued/failed: $e');
    }
  }

  // MARK: - Inbox

  Future<void> markAllRead() async {
    final me = _me;
    final unread = inbox.where((n) => !n.read).toList();
    if (me == null || unread.isEmpty) return;
    final batch = _fs.batch();
    final col = FsPaths.notifications(me);
    for (final n in unread) {
      batch.update(col.doc(n.id), {'read': true});
    }
    await batch.commit();
  }
}
