import '../../../data/models/settlement_model.dart';

/// Settlement optimization algorithm
/// Minimizes the number of transactions needed to settle all debts
class SettlementOptimizer {
  /// Calculate optimized settlements from balances
  /// Returns list of (fromId, toId, amount) tuples
  static List<Settlement> optimizeSettlements({
    required Map<int, double> balances,
    required int groupId,
  }) {
    final settlements = <Settlement>[];

    // Separate creditors (positive balance) and debtors (negative balance)
    final creditors = <MapEntry<int, double>>[];
    final debtors = <MapEntry<int, double>>[];

    balances.forEach((memberId, balance) {
      if (balance > 0.01) {
        creditors.add(MapEntry(memberId, balance));
      } else if (balance < -0.01) {
        debtors.add(MapEntry(memberId, balance.abs()));
      }
    });

    // Sort by amount (largest first) for better optimization
    creditors.sort((a, b) => b.value.compareTo(a.value));
    debtors.sort((a, b) => b.value.compareTo(a.value));

    // Greedy algorithm to minimize transactions
    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final amount = creditor.value < debtor.value
          ? creditor.value
          : debtor.value;

      settlements.add(
        Settlement(
          groupId: groupId,
          fromMemberId: debtor.key,
          toMemberId: creditor.key,
          amount: amount,
        ),
      );

      // Update remaining amounts
      creditors[creditorIndex] = MapEntry(
        creditor.key,
        creditor.value - amount,
      );
      debtors[debtorIndex] = MapEntry(debtor.key, debtor.value - amount);

      // Move to next if settled
      if (creditors[creditorIndex].value < 0.01) creditorIndex++;
      if (debtors[debtorIndex].value < 0.01) debtorIndex++;
    }

    return settlements;
  }
}
