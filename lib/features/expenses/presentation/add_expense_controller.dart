import 'package:get/get.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/services/database_service.dart';

/// Controller for Add Expense Screen
class AddExpenseController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final int groupId;

  AddExpenseController(this.groupId);

  // MARK: - Observable State

  final RxList<Member> members = <Member>[].obs;
  final RxString title = ''.obs;
  final RxDouble amount = 0.0.obs;
  final Rx<int?> paidById = Rx<int?>(null);
  final RxString category = 'Food'.obs;
  final RxString notes = ''.obs;
  final Rx<SplitType> splitType = SplitType.equal.obs;
  final RxMap<int, double> customSplits = <int, double>{}.obs;
  final RxBool isCreating = false.obs;

  final List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Travel',
    'Other',
  ];

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  // MARK: - Data Loading

  Future<void> loadMembers() async {
    try {
      final group = await _db.getGroupById(groupId);
      if (group != null) {
        members.value = await _db.getMembersByIds(group.memberIds);
        if (members.isNotEmpty) {
          paidById.value = members.first.id;
          _initializeEqualSplit();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load members: $e');
    }
  }

  // MARK: - Split Calculation

  void _initializeEqualSplit() {
    if (members.isEmpty || amount.value == 0) return;

    final splitAmount = amount.value / members.length;
    customSplits.clear();
    for (final member in members) {
      customSplits[member.id] = splitAmount;
    }
  }

  void updateSplitType(SplitType type) {
    splitType.value = type;
    if (type == SplitType.equal) {
      _initializeEqualSplit();
    } else if (type == SplitType.percentage) {
      _initializePercentageSplit();
    } else {
      // Custom - initialize with zeros
      customSplits.clear();
      for (final member in members) {
        customSplits[member.id] = 0.0;
      }
    }
  }

  void _initializePercentageSplit() {
    if (members.isEmpty) return;

    final equalPercentage = 100.0 / members.length;
    customSplits.clear();
    for (final member in members) {
      customSplits[member.id] = equalPercentage;
    }
  }

  void updateAmount(double value) {
    amount.value = value;
    if (splitType.value == SplitType.equal) {
      _initializeEqualSplit();
    }
    // For Percentage: We simply keep the percentages in customSplits,
    // so no need to update map. The UI calculates amounts on the fly.
    // For Custom: Values are fixed amounts, they don't change with total.
  }

  void updateCustomSplit(int memberId, double value) {
    customSplits[memberId] = value;
  }

  void updatePercentageSplit(int memberId, double percentage) {
    // Store percentage, then calculate amount
    customSplits[memberId] = percentage;
    customSplits.refresh();
  }

  // MARK: - Validation

  bool get canCreate {
    return title.value.isNotEmpty &&
        amount.value > 0 &&
        paidById.value != null &&
        _validateSplits();
  }

  bool _validateSplits() {
    if (customSplits.isEmpty) return false;

    if (splitType.value == SplitType.percentage) {
      // For percentage, sum should equal 100%
      final totalPercentage = customSplits.values.fold(
        0.0,
        (sum, val) => sum + val,
      );
      return (totalPercentage - 100.0).abs() < 0.01;
    } else {
      // For equal and custom, sum should equal amount
      final total = customSplits.values.fold(0.0, (sum, val) => sum + val);
      return (total - amount.value).abs() < 0.01;
    }
  }

  // MARK: - Expense Creation

  Future<void> createExpense() async {
    if (!canCreate) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    try {
      isCreating.value = true;

      List<ExpenseSplit> splits;

      if (splitType.value == SplitType.percentage) {
        // Convert percentages to amounts
        splits = customSplits.entries.map((e) {
          final calculatedAmount = (amount.value * e.value) / 100;
          return ExpenseSplit(memberId: e.key, amount: calculatedAmount);
        }).toList();
      } else {
        // Equal or Custom already have amounts
        splits = customSplits.entries
            .map((e) => ExpenseSplit(memberId: e.key, amount: e.value))
            .toList();
      }

      final expense = Expense(
        groupId: groupId,
        title: title.value,
        amount: amount.value,
        category: category.value,
        notes: notes.value.isEmpty ? null : notes.value,
        paidById: paidById.value!,
        splitType: splitType.value,
        splits: splits,
      );

      await _db.createExpense(expense);

      Get.back();
      Get.snackbar(
        'Success',
        'Expense added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create expense: $e');
    } finally {
      isCreating.value = false;
    }
  }
}
