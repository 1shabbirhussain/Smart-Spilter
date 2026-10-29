import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_tracker/core/services/debt_reminder_service.dart';
import 'package:smart_expense_tracker/core/utils/balance_calculator.dart';
import 'package:smart_expense_tracker/core/utils/settlement_optimizer.dart';
import 'package:smart_expense_tracker/data/models/expense_model.dart';
import 'package:smart_expense_tracker/data/models/settlement_model.dart';

Expense _expense(int paidBy, double amount, Map<int, double> splits) {
  return Expense(
    groupId: 1,
    title: 'x',
    amount: amount,
    category: 'Food',
    paidById: paidBy,
    splitType: SplitType.custom,
    splits: splits.entries
        .map((e) => ExpenseSplit(memberId: e.key, amount: e.value))
        .toList(),
  );
}

DebtEntry _entry(String name, double amount, {required bool iOwe, String currency = 'PKR'}) {
  return DebtEntry(
    groupId: 1,
    groupName: 'Trip',
    currency: currency,
    otherMemberId: name.hashCode,
    otherName: name,
    amount: amount,
    iOwe: iOwe,
  );
}

void main() {
  group('BalanceCalculator', () {
    test('payer is owed, splitters owe', () {
      final balances = BalanceCalculator.calculate(
        memberIds: [1, 2, 3],
        expenses: [_expense(1, 90, {1: 30, 2: 30, 3: 30})],
        settlements: const [],
      );
      expect(balances[1], 60);
      expect(balances[2], -30);
      expect(balances[3], -30);
    });

    test('settlements reduce balances', () {
      final balances = BalanceCalculator.calculate(
        memberIds: [1, 2],
        expenses: [_expense(1, 100, {1: 50, 2: 50})],
        settlements: [
          Settlement(groupId: 1, fromMemberId: 2, toMemberId: 1, amount: 50),
        ],
      );
      expect(balances[1], 0);
      expect(balances[2], 0);
    });
  });

  group('SettlementOptimizer', () {
    test('produces transfers that zero every balance', () {
      final balances = {1: 60.0, 2: -30.0, 3: -20.0, 4: -10.0};
      final transfers = SettlementOptimizer.optimizeSettlements(
        balances: balances,
        groupId: 1,
      );
      final after = Map<int, double>.of(balances);
      for (final t in transfers) {
        after[t.fromMemberId] = after[t.fromMemberId]! + t.amount;
        after[t.toMemberId] = after[t.toMemberId]! - t.amount;
      }
      for (final v in after.values) {
        expect(v.abs() < 0.01, isTrue);
      }
      expect(transfers.length, 3);
    });

    test('ignores float dust', () {
      final transfers = SettlementOptimizer.optimizeSettlements(
        balances: {1: 1e-12, 2: -1e-12},
        groupId: 1,
      );
      expect(transfers, isEmpty);
    });
  });

  group('DebtReminderService', () {
    test('nets the same person across groups and sorts debts first', () {
      final people = DebtReminderService.netByPerson([
        _entry('Ali', 50, iOwe: true),
        _entry('ali', 10, iOwe: false),
        _entry('Sara', 20, iOwe: false),
        _entry('Bilal', 20, iOwe: true),
      ]);
      expect(people.map((p) => p.name), ['Ali', 'Bilal', 'Sara']);
      expect(people[0].net, -40);
      expect(people[1].net, -20);
      expect(people[2].net, 20);
    });

    test('keeps currencies separate and drops settled people', () {
      final people = DebtReminderService.netByPerson([
        _entry('Ali', 50, iOwe: true, currency: 'PKR'),
        _entry('Ali', 5, iOwe: true, currency: 'USD'),
        _entry('Sara', 20, iOwe: true),
        _entry('Sara', 20, iOwe: false),
      ]);
      expect(people.length, 2);
      expect(people.every((p) => p.name == 'Ali'), isTrue);
    });

    test('formats amounts without trailing zeros', () {
      expect(DebtReminderService.formatAmount('PKR', -50), 'PKR 50');
      expect(DebtReminderService.formatAmount('USD', 12.5), 'USD 12.50');
    });
  });
}
