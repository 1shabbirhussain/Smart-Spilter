import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import '../models/expense_model.dart';
import '../models/group_model.dart';
import '../models/member_model.dart';
import '../models/settlement_model.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'firestore_paths.dart';

enum SyncResult { synced, offline, notSignedIn, timeout, failed }

/// Two-way sync between the local Isar database and Firestore.
///
/// - Every local write goes to Isar first (so the app works offline), is
///   flagged `pendingSync`, and is pushed to Firestore. Firestore's offline
///   queue persists writes made without internet and sends them later.
/// - Firestore listeners pull groups the user belongs to (memberUids) plus
///   their expenses and settlements into Isar. Screens only read Isar.
/// - Conflicts: last write wins by `updatedAt`; an unsynced local change
///   that is newer than the remote copy is kept and pushed.
class SyncService extends GetxService implements SyncHooks {
  static SyncService get to => Get.find<SyncService>();

  final AuthService _auth = AuthService.to;
  final DatabaseService _db = DatabaseService();

  final RxBool online = true.obs;
  final RxBool syncing = false.obs;
  final RxInt pendingCount = 0.obs;
  final Rxn<DateTime> lastSyncedAt = Rxn<DateTime>();

  /// False while the first download after sign-in is still arriving, so
  /// reminders don't treat existing debts as brand new ones
  bool initialPullDone = true;
  Timer? _initialPullTimer;

  String? _uid;
  bool get isActive => _uid != null;

  Worker? _authWorker;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _groupsSub;
  final Map<String, StreamSubscription> _expenseSubs = {};
  final Map<String, StreamSubscription> _settlementSubs = {};
  final Map<String, List<DocumentSnapshot<Map<String, dynamic>>>>
  _expenseCache = {};
  final Map<String, List<DocumentSnapshot<Map<String, dynamic>>>>
  _settlementCache = {};
  final Map<int, Timer> _groupPushTimers = {};
  final List<StreamSubscription> _isarWatchers = [];
  Timer? _pendingTimer;

  /// Pull handlers run one at a time so snapshots can't interleave
  Future<void> _serial = Future.value();

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    final connectivity = Connectivity();
    _connectivitySub = connectivity.onConnectivityChanged.listen(
      _onConnectivity,
    );
    connectivity.checkConnectivity().then(_onConnectivity);

    _authWorker = ever(_auth.user, (_) => _onAuthChanged());
    _onAuthChanged();
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    _connectivitySub?.cancel();
    _stop();
    super.onClose();
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    final wasOnline = online.value;
    online.value = results.any((r) => r != ConnectivityResult.none);
    if (!wasOnline && online.value && isActive) {
      // Firestore resumes on its own; this re-sends anything still flagged
      _pushAllPending();
    }
  }

  Future<void> _onAuthChanged() async {
    final uid = _auth.uid;
    if (uid == _uid) return;
    if (_uid != null) _stop();
    if (uid != null) await _start(uid);
  }

  Future<void> _start(String uid) async {
    _uid = uid;
    initialPullDone = false;
    // Fallback in case the server never answers (offline sign-in)
    _initialPullTimer = Timer(const Duration(seconds: 20), () {
      initialPullDone = true;
    });
    DatabaseService.syncHooks = this;
    try {
      await _claimLocalData(uid);
      await _watchPending();
      _listenGroups();
      await _pushAllPending();
    } catch (e) {
      debugPrint('Sync start failed: $e');
    }
  }

  void _stop() {
    DatabaseService.syncHooks = null;
    _uid = null;
    _cancelListeners();
    for (final t in _groupPushTimers.values) {
      t.cancel();
    }
    _groupPushTimers.clear();
    for (final s in _isarWatchers) {
      s.cancel();
    }
    _isarWatchers.clear();
    _pendingTimer?.cancel();
    _initialPullTimer?.cancel();
    initialPullDone = true;
    pendingCount.value = 0;
    lastSyncedAt.value = null;
  }

  void _cancelListeners() {
    _groupsSub?.cancel();
    _groupsSub = null;
    for (final s in [..._expenseSubs.values, ..._settlementSubs.values]) {
      s.cancel();
    }
    _expenseSubs.clear();
    _settlementSubs.clear();
    _expenseCache.clear();
    _settlementCache.clear();
  }

  /// Called before Firebase sign-out: stop syncing and wipe local data
  Future<void> onSignOut() async {
    _stop();
    await _db.clearAllData();
  }

  /// Local data created before signing in (offline mode) becomes yours
  Future<void> _claimLocalData(String uid) async {
    final isar = await _db.isar;
    final unowned = await isar.groups.filter().ownerUidIsNull().findAll();
    final orphanExpenses = await isar.expenses
        .filter()
        .remoteIdIsNull()
        .findAll();
    final orphanSettlements = await isar.settlements
        .filter()
        .remoteIdIsNull()
        .findAll();
    if (unowned.isEmpty &&
        orphanExpenses.isEmpty &&
        orphanSettlements.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await isar.writeTxn(() async {
      for (final group in unowned) {
        final members = (await isar.members.getAll(
          group.memberIds,
        )).whereType<Member>().toList();
        final me =
            members.where((m) => m.isMe).firstOrNull ??
            members.where((m) => m.representsMe).firstOrNull;
        for (final m in members) {
          m.remoteId ??= DatabaseService.newRemoteId();
          if (identical(m, me)) {
            m.uid = uid;
            m.isMe = true;
          }
        }
        await isar.members.putAll(members);
        group
          ..ownerUid = uid
          ..remoteId ??= DatabaseService.newRemoteId()
          ..updatedAt = now
          ..pendingSync = true;
        await isar.groups.put(group);
      }
      for (final e in orphanExpenses) {
        e
          ..remoteId = DatabaseService.newRemoteId()
          ..updatedAt = now
          ..pendingSync = true;
      }
      await isar.expenses.putAll(orphanExpenses);
      for (final s in orphanSettlements) {
        s
          ..remoteId = DatabaseService.newRemoteId()
          ..updatedAt = now
          ..pendingSync = true;
      }
      await isar.settlements.putAll(orphanSettlements);
    });
  }

  // MARK: - Pending counter

  Future<void> _watchPending() async {
    final isar = await _db.isar;
    for (final stream in [
      isar.groups.watchLazy(),
      isar.expenses.watchLazy(),
      isar.settlements.watchLazy(),
    ]) {
      _isarWatchers.add(stream.listen((_) => _schedulePendingRecount()));
    }
    await _recountPending();
  }

  void _schedulePendingRecount() {
    _pendingTimer?.cancel();
    _pendingTimer = Timer(const Duration(milliseconds: 400), _recountPending);
  }

  Future<void> _recountPending() async {
    if (!isActive) return;
    final isar = await _db.isar;
    pendingCount.value =
        await isar.groups.filter().pendingSyncEqualTo(true).count() +
        await isar.expenses.filter().pendingSyncEqualTo(true).count() +
        await isar.settlements.filter().pendingSyncEqualTo(true).count();
  }

  // MARK: - Manual sync

  Future<SyncResult> syncNow() async {
    if (!isActive) return SyncResult.notSignedIn;
    if (!online.value) return SyncResult.offline;
    if (syncing.value) return SyncResult.synced;

    syncing.value = true;
    try {
      final fs = FirebaseFirestore.instance;
      await fs.enableNetwork();
      await _pushAllPending();
      await fs.waitForPendingWrites().timeout(const Duration(seconds: 30));
      // Re-attach listeners to pull a fresh server copy of everything
      _cancelListeners();
      _listenGroups();
      lastSyncedAt.value = DateTime.now();
      await _recountPending();
      return SyncResult.synced;
    } on TimeoutException {
      return SyncResult.timeout;
    } catch (e) {
      debugPrint('Manual sync failed: $e');
      return SyncResult.failed;
    } finally {
      syncing.value = false;
    }
  }

  Future<void> _pushAllPending() async {
    if (!isActive) return;
    final isar = await _db.isar;
    // Groups first: expense/settlement rules check group membership
    for (final g
        in await isar.groups.filter().pendingSyncEqualTo(true).findAll()) {
      await _pushGroupNow(g.id);
    }
    for (final e
        in await isar.expenses.filter().pendingSyncEqualTo(true).findAll()) {
      await _pushExpense(e.id);
    }
    for (final s
        in await isar.settlements.filter().pendingSyncEqualTo(true).findAll()) {
      await _pushSettlement(s.id);
    }
  }

  // MARK: - Push (SyncHooks)

  String get _myName {
    final name =
        _auth.profile.value?.displayName ?? _auth.user.value?.displayName;
    return (name == null || name.trim().isEmpty) ? 'Member' : name;
  }

  Map<String, dynamic> _groupDoc(
    Group g,
    List<Member> members, {
    bool leaving = false,
  }) {
    final memberMaps = members.map((m) {
      final isSelf = m.uid != null && m.uid == _uid;
      return {
        'id': m.remoteId,
        // Locally your own member is "You"; others see your real name
        'name': isSelf ? _myName : m.name,
        'emoji': m.emoji,
        'colorHex': m.colorHex,
        'uid': (leaving && isSelf) ? null : m.uid,
      };
    }).toList();
    final uids = memberMaps.map((m) => m['uid']).whereType<String>().toSet();
    if (!leaving) uids.add(_uid!); // never lock yourself out of your group

    return {
      'name': g.name,
      'emoji': g.emoji,
      'currency': g.currency,
      'imageBase64': g.imageBase64,
      'ownerUid': g.ownerUid ?? _uid,
      'members': memberMaps,
      'memberUids': uids.toList(),
      'createdAt': Timestamp.fromDate(g.createdAt),
      'updatedAt': Timestamp.fromDate(g.updatedAt ?? DateTime.now()),
      'updatedBy': _uid,
      'deleted': false,
    };
  }

  @override
  void groupChanged(int groupId) {
    // Members and the group are usually written back-to-back; batch them
    _groupPushTimers[groupId]?.cancel();
    _groupPushTimers[groupId] = Timer(const Duration(milliseconds: 300), () {
      _groupPushTimers.remove(groupId);
      _pushGroupNow(groupId);
    });
  }

  Future<void> _pushGroupNow(int groupId) async {
    if (!isActive) return;
    try {
      final group = await _db.getGroupById(groupId);
      if (group == null || group.remoteId == null) return;
      final members = await _db.getMembersByIds(group.memberIds);
      if (members.any((m) => m.remoteId == null)) {
        for (final m in members.where((m) => m.remoteId == null)) {
          m.remoteId = DatabaseService.newRemoteId();
          await _db.updateMember(m);
        }
      }
      final stamp = group.updatedAt;
      // Not awaited: offline, this completes only once the server confirms
      FsPaths.groups
          .doc(group.remoteId)
          .set(_groupDoc(group, members), SetOptions(merge: true))
          .then((_) => _markSynced<Group>(groupId, stamp))
          .catchError((Object e) => debugPrint('Group push failed: $e'));
    } catch (e) {
      debugPrint('Group push failed: $e');
    }
  }

  @override
  void groupArchiveChanged(int groupId, bool archived) async {
    if (!isActive) return;
    final group = await _db.getGroupById(groupId);
    if (group?.remoteId == null) return;
    FsPaths.groups
        .doc(group!.remoteId)
        .set({
          'archivedBy': archived
              ? FieldValue.arrayUnion([_uid])
              : FieldValue.arrayRemove([_uid]),
        }, SetOptions(merge: true))
        .catchError((Object e) => debugPrint('Archive push failed: $e'));
  }

  @override
  void groupDeleted(Group group, List<Member> members) {
    final rid = group.remoteId;
    if (!isActive || rid == null) return;
    _stopGroupListeners(rid);

    final Map<String, dynamic> data;
    if (group.ownerUid == null || group.ownerUid == _uid) {
      // Owner deletes the group for everyone
      data = {'deleted': true, 'updatedAt': Timestamp.now(), 'updatedBy': _uid};
    } else {
      // Others just leave: unlink themselves, keep the shared history
      data = _groupDoc(group, members, leaving: true)
        ..['updatedAt'] = Timestamp.now();
    }
    FsPaths.groups
        .doc(rid)
        .set(data, SetOptions(merge: true))
        .catchError((Object e) => debugPrint('Group delete failed: $e'));
  }

  Future<Map<int, String>> _memberRemoteIds(Group group) async {
    final members = await _db.getMembersByIds(group.memberIds);
    return {
      for (final m in members)
        if (m.remoteId != null) m.id: m.remoteId!,
    };
  }

  @override
  void expenseChanged(int expenseId) => _pushExpense(expenseId);

  Future<void> _pushExpense(int expenseId) async {
    if (!isActive) return;
    try {
      final e = await _db.getExpenseById(expenseId);
      if (e == null || e.remoteId == null) return;
      final group = await _db.getGroupById(e.groupId);
      if (group?.remoteId == null) return;
      final rids = await _memberRemoteIds(group!);
      final stamp = e.updatedAt;
      FsPaths.expenses(group.remoteId!)
          .doc(e.remoteId)
          .set({
            'title': e.title,
            'amount': e.amount,
            'category': e.category,
            'notes': e.notes,
            'paidBy': rids[e.paidById],
            'splitType': e.splitType.name,
            'splits': e.splits
                .map((s) => {'member': rids[s.memberId], 'amount': s.amount})
                .toList(),
            'createdAt': Timestamp.fromDate(e.createdAt),
            'updatedAt': Timestamp.fromDate(stamp ?? DateTime.now()),
            'updatedBy': _uid,
            'deleted': false,
          })
          .then((_) => _markSynced<Expense>(expenseId, stamp))
          .catchError((Object err) => debugPrint('Expense push failed: $err'));
    } catch (err) {
      debugPrint('Expense push failed: $err');
    }
  }

  @override
  void expenseDeleted(String? groupRemoteId, String? expenseRemoteId) {
    if (!isActive || groupRemoteId == null || expenseRemoteId == null) return;
    FsPaths.expenses(groupRemoteId)
        .doc(expenseRemoteId)
        .set(_tombstone, SetOptions(merge: true))
        .catchError((Object e) => debugPrint('Expense delete failed: $e'));
  }

  @override
  void settlementChanged(int settlementId) => _pushSettlement(settlementId);

  Future<void> _pushSettlement(int settlementId) async {
    if (!isActive) return;
    try {
      final s = await _db.getSettlementById(settlementId);
      if (s == null || s.remoteId == null) return;
      final group = await _db.getGroupById(s.groupId);
      if (group?.remoteId == null) return;
      final rids = await _memberRemoteIds(group!);
      final stamp = s.updatedAt;
      FsPaths.settlements(group.remoteId!)
          .doc(s.remoteId)
          .set({
            'from': rids[s.fromMemberId],
            'to': rids[s.toMemberId],
            'amount': s.amount,
            'isPartial': s.isPartial,
            'notes': s.notes,
            'settledAt': Timestamp.fromDate(s.settledAt),
            'updatedAt': Timestamp.fromDate(stamp ?? DateTime.now()),
            'updatedBy': _uid,
            'deleted': false,
          })
          .then((_) => _markSynced<Settlement>(settlementId, stamp))
          .catchError((Object e) => debugPrint('Settlement push failed: $e'));
    } catch (e) {
      debugPrint('Settlement push failed: $e');
    }
  }

  @override
  void settlementDeleted(String? groupRemoteId, String? settlementRemoteId) {
    if (!isActive || groupRemoteId == null || settlementRemoteId == null) {
      return;
    }
    FsPaths.settlements(groupRemoteId)
        .doc(settlementRemoteId)
        .set(_tombstone, SetOptions(merge: true))
        .catchError((Object e) => debugPrint('Settlement delete failed: $e'));
  }

  Map<String, dynamic> get _tombstone => {
    'deleted': true,
    'updatedAt': Timestamp.now(),
    'updatedBy': _uid,
  };

  /// Clears the pending flag unless the record changed again meanwhile
  Future<void> _markSynced<T>(int id, DateTime? stamp) async {
    final isar = await _db.isar;
    await isar.writeTxn(() async {
      if (T == Group) {
        final g = await isar.groups.get(id);
        if (g != null && g.updatedAt == stamp) {
          g.pendingSync = false;
          await isar.groups.put(g);
        }
      } else if (T == Expense) {
        final e = await isar.expenses.get(id);
        if (e != null && e.updatedAt == stamp) {
          e.pendingSync = false;
          await isar.expenses.put(e);
        }
      } else if (T == Settlement) {
        final s = await isar.settlements.get(id);
        if (s != null && s.updatedAt == stamp) {
          s.pendingSync = false;
          await isar.settlements.put(s);
        }
      }
    });
    lastSyncedAt.value = DateTime.now();
  }

  // MARK: - Pull

  void _enqueue(Future<void> Function() task) {
    _serial = _serial.then((_) => task()).catchError((Object e) {
      debugPrint('Sync pull failed: $e');
    });
  }

  void _listenGroups() {
    final uid = _uid;
    if (uid == null) return;
    _groupsSub = FsPaths.groups
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .listen(
          (snap) => _enqueue(() => _onGroupsSnapshot(snap)),
          onError: (Object e) {
            debugPrint('Groups listener error: $e');
            // Re-attach later (e.g. rules deployed / connection restored)
            _groupsSub = null;
            Timer(const Duration(seconds: 15), () {
              if (isActive && _groupsSub == null) _listenGroups();
            });
          },
        );
  }

  Future<void> _onGroupsSnapshot(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) async {
    for (final change in snap.docChanges) {
      final doc = change.doc;
      if (change.type == DocumentChangeType.removed) {
        // You were removed from the group (or it no longer matches)
        await _removeLocalGroup(doc.id);
        continue;
      }
      final data = doc.data();
      if (data == null) continue;
      if (data['deleted'] == true) {
        await _removeLocalGroup(doc.id);
        continue;
      }
      if (!doc.metadata.hasPendingWrites) await _upsertGroup(doc);
      _ensureGroupListeners(doc.id);
    }
    if (!snap.metadata.isFromCache) {
      lastSyncedAt.value = DateTime.now();
      if (!initialPullDone) {
        // Give the per-group expense listeners a moment to land
        _initialPullTimer?.cancel();
        _initialPullTimer = Timer(const Duration(seconds: 4), () {
          initialPullDone = true;
        });
      }
    }
  }

  Future<Group?> _localGroup(String remoteId) async {
    final isar = await _db.isar;
    return isar.groups.filter().remoteIdEqualTo(remoteId).findFirst();
  }

  static DateTime _date(dynamic v) =>
      v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _upsertGroup(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final isar = await _db.isar;
    final local = await _localGroup(doc.id);
    final remoteUpdated = _date(data['updatedAt']);

    // Keep an unsynced local edit that is newer than the server copy
    if (local != null &&
        local.pendingSync &&
        (local.updatedAt ?? DateTime(0)).isAfter(remoteUpdated)) {
      return;
    }

    final existing = local == null
        ? <Member>[]
        : await _db.getMembersByIds(local.memberIds);
    final byRemoteId = {for (final m in existing) m.remoteId: m};
    final remoteMembers = ((data['members'] as List?) ?? const [])
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    final archivedBy = List<String>.from(data['archivedBy'] ?? const []);

    await isar.writeTxn(() async {
      final memberIds = <int>[];
      for (final raw in remoteMembers) {
        final uid = raw['uid'] as String?;
        final member =
            byRemoteId[raw['id']] ??
            Member(name: '', emoji: '👤', colorHex: 'FF6B9D');
        member
          ..remoteId = raw['id'] as String?
          ..uid = uid
          ..isMe = uid != null && uid == _uid
          ..emoji = raw['emoji'] as String? ?? '👤'
          ..colorHex = raw['colorHex'] as String? ?? 'FF6B9D';
        member.name = member.isMe
            ? 'You'
            : (raw['name'] as String? ?? 'Member');
        memberIds.add(await isar.members.put(member));
      }
      final stale = existing
          .where((m) => !memberIds.contains(m.id))
          .map((m) => m.id)
          .toList();
      await isar.members.deleteAll(stale);

      final group = local ?? Group.empty();
      group
        ..remoteId = doc.id
        ..name = data['name'] as String? ?? 'Group'
        ..emoji = data['emoji'] as String? ?? '👥'
        ..currency = data['currency'] as String? ?? 'USD'
        ..imageBase64 = data['imageBase64'] as String?
        ..ownerUid = data['ownerUid'] as String?
        ..memberIds = memberIds
        ..createdAt = _date(data['createdAt'])
        ..updatedAt = remoteUpdated
        ..pendingSync = false
        ..isArchived = archivedBy.contains(_uid);
      await isar.groups.put(group);
    });

    // Expenses that arrived before their members can be applied now
    for (final d in _expenseCache[doc.id] ?? const []) {
      await _upsertExpense(doc.id, d);
    }
    for (final d in _settlementCache[doc.id] ?? const []) {
      await _upsertSettlement(doc.id, d);
    }
  }

  Future<void> _removeLocalGroup(String remoteId) async {
    _stopGroupListeners(remoteId);
    final group = await _localGroup(remoteId);
    if (group == null) return;
    final isar = await _db.isar;
    await isar.writeTxn(() async {
      await isar.expenses.filter().groupIdEqualTo(group.id).deleteAll();
      await isar.settlements.filter().groupIdEqualTo(group.id).deleteAll();
      await isar.members.deleteAll(group.memberIds);
      await isar.groups.delete(group.id);
    });
  }

  void _ensureGroupListeners(String groupRid) {
    _expenseSubs.putIfAbsent(
      groupRid,
      () => FsPaths.expenses(groupRid).snapshots().listen(
        (snap) => _enqueue(() async {
          _expenseCache[groupRid] = snap.docs;
          for (final change in snap.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              await _deleteLocalExpense(change.doc.id);
            } else {
              await _upsertExpense(groupRid, change.doc);
            }
          }
        }),
        onError: (Object e) => _retryGroupListeners(groupRid, e),
      ),
    );
    _settlementSubs.putIfAbsent(
      groupRid,
      () => FsPaths.settlements(groupRid).snapshots().listen(
        (snap) => _enqueue(() async {
          _settlementCache[groupRid] = snap.docs;
          for (final change in snap.docChanges) {
            if (change.type == DocumentChangeType.removed) {
              await _deleteLocalSettlement(change.doc.id);
            } else {
              await _upsertSettlement(groupRid, change.doc);
            }
          }
        }),
        onError: (Object e) => _retryGroupListeners(groupRid, e),
      ),
    );
  }

  /// A listener can be rejected if it reaches the server before the group
  /// itself (created offline); drop it and try again shortly.
  void _retryGroupListeners(String groupRid, Object error) {
    debugPrint('Group $groupRid listener error: $error');
    _stopGroupListeners(groupRid);
    Timer(const Duration(seconds: 5), () async {
      if (isActive && await _localGroup(groupRid) != null) {
        _ensureGroupListeners(groupRid);
      }
    });
  }

  void _stopGroupListeners(String groupRid) {
    _expenseSubs.remove(groupRid)?.cancel();
    _settlementSubs.remove(groupRid)?.cancel();
    _expenseCache.remove(groupRid);
    _settlementCache.remove(groupRid);
  }

  /// remoteId -> local id for the members of a group
  Future<Map<String, int>> _localMemberIds(Group group) async {
    final members = await _db.getMembersByIds(group.memberIds);
    return {
      for (final m in members)
        if (m.remoteId != null) m.remoteId!: m.id,
    };
  }

  /// Shared "should the remote copy overwrite the local one?" check
  bool _remoteWins(
    bool hasLocal,
    bool pending,
    DateTime? localUpdated,
    DateTime remoteUpdated,
  ) {
    if (!hasLocal) return true;
    if (localUpdated == remoteUpdated && !pending) return false; // unchanged
    if (pending && (localUpdated ?? DateTime(0)).isAfter(remoteUpdated)) {
      return false;
    }
    return true;
  }

  Future<void> _upsertExpense(
    String groupRid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (doc.metadata.hasPendingWrites) return; // our own write
    final data = doc.data();
    if (data == null) return;
    if (data['deleted'] == true) {
      await _deleteLocalExpense(doc.id);
      return;
    }
    final group = await _localGroup(groupRid);
    if (group == null) return;

    final isar = await _db.isar;
    final local = await isar.expenses
        .filter()
        .remoteIdEqualTo(doc.id)
        .findFirst();
    final remoteUpdated = _date(data['updatedAt']);
    if (!_remoteWins(
      local != null,
      local?.pendingSync ?? false,
      local?.updatedAt,
      remoteUpdated,
    )) {
      return;
    }

    final ids = await _localMemberIds(group);
    final paidBy = ids[data['paidBy']];
    final splits = <ExpenseSplit>[];
    for (final raw
        in ((data['splits'] as List?) ?? const []).whereType<Map>()) {
      final memberId = ids[raw['member']];
      if (memberId == null) return; // member not synced yet; retried later
      splits.add(
        ExpenseSplit(
          memberId: memberId,
          amount: (raw['amount'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
    if (paidBy == null) return;

    final expense = local ?? Expense.empty();
    expense
      ..remoteId = doc.id
      ..groupId = group.id
      ..title = data['title'] as String? ?? ''
      ..amount = (data['amount'] as num?)?.toDouble() ?? 0
      ..category = data['category'] as String? ?? 'Other'
      ..notes = data['notes'] as String?
      ..paidById = paidBy
      ..splitType = SplitType.values.firstWhere(
        (t) => t.name == data['splitType'],
        orElse: () => SplitType.custom,
      )
      ..splits = splits
      ..createdAt = _date(data['createdAt'])
      ..updatedAt = remoteUpdated
      ..pendingSync = false;
    await isar.writeTxn(() => isar.expenses.put(expense));
  }

  Future<void> _deleteLocalExpense(String remoteId) async {
    final isar = await _db.isar;
    await isar.writeTxn(
      () => isar.expenses.filter().remoteIdEqualTo(remoteId).deleteAll(),
    );
  }

  Future<void> _upsertSettlement(
    String groupRid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (doc.metadata.hasPendingWrites) return;
    final data = doc.data();
    if (data == null) return;
    if (data['deleted'] == true) {
      await _deleteLocalSettlement(doc.id);
      return;
    }
    final group = await _localGroup(groupRid);
    if (group == null) return;

    final isar = await _db.isar;
    final local = await isar.settlements
        .filter()
        .remoteIdEqualTo(doc.id)
        .findFirst();
    final remoteUpdated = _date(data['updatedAt']);
    if (!_remoteWins(
      local != null,
      local?.pendingSync ?? false,
      local?.updatedAt,
      remoteUpdated,
    )) {
      return;
    }

    final ids = await _localMemberIds(group);
    final from = ids[data['from']];
    final to = ids[data['to']];
    if (from == null || to == null) return;

    final settlement = local ?? Settlement.empty();
    settlement
      ..remoteId = doc.id
      ..groupId = group.id
      ..fromMemberId = from
      ..toMemberId = to
      ..amount = (data['amount'] as num?)?.toDouble() ?? 0
      ..isPartial = data['isPartial'] as bool? ?? false
      ..notes = data['notes'] as String?
      ..settledAt = _date(data['settledAt'])
      ..updatedAt = remoteUpdated
      ..pendingSync = false;
    await isar.writeTxn(() => isar.settlements.put(settlement));
  }

  Future<void> _deleteLocalSettlement(String remoteId) async {
    final isar = await _db.isar;
    await isar.writeTxn(
      () => isar.settlements.filter().remoteIdEqualTo(remoteId).deleteAll(),
    );
  }
}
