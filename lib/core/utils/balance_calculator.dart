import '../../data/models/expense_model.dart';
import '../../data/models/settlement_model.dart';

/// Computes net balances per member.
/// Positive = the member is owed money, negative = the member owes money.
class BalanceCalculator {
  BalanceCalculator._();

  static Map<int, double> calculate({
    required Iterable<int> memberIds,
    required Iterable<Expense> expenses,
    required Iterable<Settlement> settlements,
  }) {
    final balances = <int, double>{for (final id in memberIds) id: 0.0};

    for (final expense in expenses) {
      // Person who paid gets positive balance (money owed TO them)
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      // People who split get negative balance (money they OWE)
      for (final split in expense.splits) {
        balances[split.memberId] =
            (balances[split.memberId] ?? 0) - split.amount;
      }
    }

    // Payments: payer's debt shrinks, receiver's credit shrinks
    for (final settlement in settlements) {
      balances[settlement.fromMemberId] =
          (balances[settlement.fromMemberId] ?? 0) + settlement.amount;
      balances[settlement.toMemberId] =
          (balances[settlement.toMemberId] ?? 0) - settlement.amount;
    }

    return balances;
  }
}
