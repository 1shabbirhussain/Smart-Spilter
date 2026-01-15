import 'package:get/get.dart';
import '../../../data/models/settlement_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/services/database_service.dart';
import '../../../core/utils/settlement_optimizer.dart';

/// Controller for Settlements Screen
class SettlementsController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final int groupId;
  final Map<int, double> balances;
  final List<Member> members;

  SettlementsController({
    required this.groupId,
    required this.balances,
    required this.members,
  });

  // MARK: - Observable State

  final RxList<Settlement> optimizedSettlements = <Settlement>[].obs;
  final RxList<Settlement> completedSettlements = <Settlement>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool showConfetti = false.obs;

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    _calculateOptimizedSettlements();
    _loadCompletedSettlements();
  }

  // MARK: - Settlement Calculation

  void _calculateOptimizedSettlements() {
    optimizedSettlements.value = SettlementOptimizer.optimizeSettlements(
      balances: balances,
      groupId: groupId,
    );
  }

  Future<void> _loadCompletedSettlements() async {
    try {
      completedSettlements.value = await _db.getSettlementsByGroup(groupId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load settlement history: $e');
    }
  }

  // MARK: - Settlement Actions

  Future<void> markAsSettled(Settlement settlement) async {
    try {
      isLoading.value = true;
      await _db.createSettlement(settlement);
      await _loadCompletedSettlements();
      _calculateOptimizedSettlements();

      // Show confetti celebration
      showConfetti.value = true;
      await Future.delayed(const Duration(seconds: 3));
      showConfetti.value = false;

      Get.snackbar(
        '🎉 Settlement Complete!',
        'Payment has been recorded',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to record settlement: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markPartialPayment(
    Settlement settlement,
    double partialAmount,
  ) async {
    try {
      isLoading.value = true;

      final partialSettlement = Settlement(
        groupId: settlement.groupId,
        fromMemberId: settlement.fromMemberId,
        toMemberId: settlement.toMemberId,
        amount: partialAmount,
        isPartial: true,
      );

      await _db.createSettlement(partialSettlement);
      await _loadCompletedSettlements();

      Get.snackbar(
        'Success',
        'Partial payment recorded',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payment: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Helper Methods

  Member? getMemberById(int id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}
