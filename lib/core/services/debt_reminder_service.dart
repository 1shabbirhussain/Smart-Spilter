import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/services/sync_service.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/member_model.dart';
import '../../data/models/settlement_model.dart';
import '../../data/services/database_service.dart';
import '../utils/balance_calculator.dart';
import '../utils/settlement_optimizer.dart';
import 'app_prefs.dart';
import 'notification_service.dart';

/// One "who pays whom" line from the device owner's point of view
class DebtEntry {
  final int groupId;
  final String groupName;
  final String currency;
  final int otherMemberId;
  final String otherName;
  final double amount;

  /// True when the device owner has to pay [otherName]
  final bool iOwe;

  const DebtEntry({
    required this.groupId,
    required this.groupName,
    required this.currency,
    required this.otherMemberId,
    required this.otherName,
    required this.amount,
    required this.iOwe,
  });
}

/// Net position with one person in one currency, across all groups
class PersonBalance {
  final String name;
  final String currency;

  /// Positive = they owe you, negative = you owe them
  final double net;

  const PersonBalance(this.name, this.currency, this.net);
}

/// Generates local notifications about the device owner's debts:
/// - a summary when the app opens
/// - an alert when a new expense puts you (further) in debt
/// - a scheduled daily reminder listing who you have to pay
class DebtReminderService {
  DebtReminderService._();
  static final DebtReminderService instance = DebtReminderService._();

  final DatabaseService _db = DatabaseService();
  final NotificationService _notifications = NotificationService.instance;

  final List<StreamSubscription> _subscriptions = [];
  Timer? _debounce;
  bool _started = false;

  /// groupId -> (other member id -> amount I owe)
  Map<int, Map<int, double>> _lastOwed = {};

  Future<void> start() async {
    if (_started) return;
    _started = true;

    final entries = await computeEntries();
    _lastOwed = _owedByGroup(entries);
    await _showOpenSummary(entries);
    await _rescheduleDaily(entries);

    final isar = await _db.isar;
    for (final stream in [
      isar.expenses.watchLazy(),
      isar.settlements.watchLazy(),
      isar.groups.watchLazy(),
      isar.members.watchLazy(),
    ]) {
      _subscriptions.add(stream.listen((_) => _scheduleRefresh()));
    }
  }

  void _scheduleRefresh() {
    // Several writes usually land together (e.g. members + group); batch them
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _refresh);
  }

  Future<void> _refresh() async {
    try {
      final entries = await computeEntries();
      final owed = _owedByGroup(entries);
      final downloading =
          Get.isRegistered<SyncService>() && !SyncService.to.initialPullDone;
      if (!downloading) await _alertNewDebts(entries, owed);
      _lastOwed = owed;
      await _rescheduleDaily(entries);
    } catch (e) {
      debugPrint('Debt refresh failed: $e');
    }
  }

  /// Re-apply the daily reminder after the user changes its settings
  Future<void> onReminderSettingsChanged() async {
    await _rescheduleDaily(await computeEntries());
  }

  // MARK: - Computation

  Future<List<DebtEntry>> computeEntries() async {
    final entries = <DebtEntry>[];
    final groups = await _db.getAllGroups();

    for (final group in groups) {
      final members = await _db.getMembersByIds(group.memberIds);
      final me = _findMe(members);
      if (me == null) continue;

      final balances = BalanceCalculator.calculate(
        memberIds: members.map((m) => m.id),
        expenses: await _db.getExpensesByGroup(group.id),
        settlements: await _db.getSettlementsByGroup(group.id),
      );
      final transfers = SettlementOptimizer.optimizeSettlements(
        balances: balances,
        groupId: group.id,
      );

      for (final t in transfers) {
        final iOwe = t.fromMemberId == me.id;
        if (!iOwe && t.toMemberId != me.id) continue;
        final otherId = iOwe ? t.toMemberId : t.fromMemberId;
        final other = members.where((m) => m.id == otherId).firstOrNull;
        if (other == null) continue;
        entries.add(
          DebtEntry(
            groupId: group.id,
            groupName: group.name,
            currency: group.currency,
            otherMemberId: otherId,
            otherName: other.name,
            amount: t.amount,
            iOwe: iOwe,
          ),
        );
      }
    }
    return entries;
  }

  Member? _findMe(List<Member> members) {
    return members.where((m) => m.isMe).firstOrNull ??
        members.where((m) => m.representsMe).firstOrNull;
  }

  /// Nets debts per person + currency across groups
  static List<PersonBalance> netByPerson(List<DebtEntry> entries) {
    final totals = <String, PersonBalance>{};
    for (final e in entries) {
      final key = '${e.otherName.trim().toLowerCase()}|${e.currency}';
      final signed = e.iOwe ? -e.amount : e.amount;
      final prev = totals[key];
      totals[key] = PersonBalance(
        prev?.name ?? e.otherName,
        e.currency,
        (prev?.net ?? 0) + signed,
      );
    }
    return totals.values.where((b) => b.net.abs() >= 0.01).toList()
      ..sort((a, b) => a.net.compareTo(b.net)); // biggest debts first
  }

  static String formatAmount(String currency, double amount) {
    final fixed = amount.abs().toStringAsFixed(2);
    final trimmed = fixed.endsWith('.00')
        ? fixed.substring(0, fixed.length - 3)
        : fixed;
    return '$currency $trimmed';
  }

  static String _joinNames(List<String> parts) {
    if (parts.length <= 1) return parts.join();
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  Map<int, Map<int, double>> _owedByGroup(List<DebtEntry> entries) {
    final result = <int, Map<int, double>>{};
    for (final e in entries.where((e) => e.iOwe)) {
      result.putIfAbsent(e.groupId, () => {})[e.otherMemberId] = e.amount;
    }
    return result;
  }

  // MARK: - Notifications

  Future<void> _showOpenSummary(List<DebtEntry> entries) async {
    final people = netByPerson(entries);
    if (people.isEmpty) return;

    final lines = people.map((p) {
      final amount = formatAmount(p.currency, p.net);
      return p.net < 0
          ? 'You owe ${p.name} $amount'
          : 'You have to receive $amount from ${p.name}';
    }).toList();

    await _notifications.showReminder(
      id: NotificationIds.openSummary,
      title: 'Your balances',
      body: lines.join('\n'),
    );
  }

  Future<void> _alertNewDebts(
    List<DebtEntry> entries,
    Map<int, Map<int, double>> owed,
  ) async {
    for (final groupId in owed.keys) {
      final now = owed[groupId]!;
      final before = _lastOwed[groupId] ?? const <int, double>{};
      final totalNow = now.values.fold(0.0, (a, b) => a + b);
      final totalBefore = before.values.fold(0.0, (a, b) => a + b);
      // Only alert when your overall debt in this group went up
      if (totalNow <= totalBefore + 0.01) continue;

      final increased = entries
          .where(
            (e) =>
                e.iOwe &&
                e.groupId == groupId &&
                e.amount > (before[e.otherMemberId] ?? 0) + 0.01,
          )
          .toList();
      if (increased.isEmpty) continue;

      final parts = increased
          .map((e) => '${e.otherName} ${formatAmount(e.currency, e.amount)}')
          .toList();
      await _notifications.showReminder(
        id: NotificationIds.debtAlertBase + groupId,
        title: 'New debt in ${increased.first.groupName}',
        body: 'You now owe ${_joinNames(parts)}',
      );
    }
  }

  Future<void> _rescheduleDaily(List<DebtEntry> entries) async {
    final people = netByPerson(entries);
    final toPay = people.where((p) => p.net < 0).toList();
    final toReceive = people.where((p) => p.net > 0).toList();

    if (!AppPrefs.reminderEnabled || people.isEmpty) {
      await _notifications.cancel(NotificationIds.dailyReminder);
      return;
    }

    final lines = <String>[];
    if (toPay.isNotEmpty) {
      lines.add(
        'You have to pay ${_joinNames(toPay.map((p) => '${p.name} ${formatAmount(p.currency, p.net)}').toList())}',
      );
    }
    if (toReceive.isNotEmpty) {
      lines.add(
        'Collect ${_joinNames(toReceive.map((p) => '${formatAmount(p.currency, p.net)} from ${p.name}').toList())}',
      );
    }

    await _notifications.scheduleDaily(
      id: NotificationIds.dailyReminder,
      hour: AppPrefs.reminderHour,
      minute: AppPrefs.reminderMinute,
      title: toPay.isNotEmpty ? 'Payment reminder' : 'Money to collect',
      body: lines.join('\n'),
    );
  }

  /// Fires the reminder immediately (used by "Send test reminder")
  Future<bool> showReminderNow() async {
    final entries = await computeEntries();
    if (netByPerson(entries).isEmpty) return false;
    await _showOpenSummary(entries);
    return true;
  }
}
