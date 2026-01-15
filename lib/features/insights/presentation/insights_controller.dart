import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/settlement_model.dart';
import '../../../data/services/database_service.dart';

/// Controller for Insights Screen
class InsightsController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final int groupId;

  InsightsController(this.groupId);

  // MARK: - Observable State

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Member> members = <Member>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, double> categoryTotals = <String, double>{}.obs;
  final RxMap<int, double> memberTotals = <int, double>{}.obs;
  final RxMap<String, Color> categoryColorMap = <String, Color>{}.obs;

  static const List<Color> _chartColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFFFFA07A),
    Color(0xFF98D8C8),
    Color(0xFFF7DC6F),
    Color(0xFFBB8FCE),
    Color(0xFF85C1E2),
  ];

  // MARK: - Lifecycle

  @override
  void onInit() {
    super.onInit();
    loadData();
    _setupWatcher();
  }

  @override
  void onClose() {
    _expenseSubscription?.cancel();
    _settlementSubscription?.cancel();
    _groupSubscription?.cancel();
    super.onClose();
  }

  // MARK: - Data Loading

  StreamSubscription? _expenseSubscription;
  StreamSubscription? _settlementSubscription;
  StreamSubscription? _groupSubscription;

  void _setupWatcher() async {
    final db = await _db.isar;

    // Watch expenses
    _expenseSubscription = db.expenses
        .filter()
        .groupIdEqualTo(groupId)
        .watchLazy()
        .listen((_) => loadData());

    // Watch settlements
    _settlementSubscription = db.settlements
        .filter()
        .groupIdEqualTo(groupId)
        .watchLazy()
        .listen((_) => loadData());

    // Watch group changes
    _groupSubscription = db.groups
        .watchObject(groupId)
        .listen((_) => loadData());
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final group = await _db.getGroupById(groupId);
      if (group != null) {
        members.value = await _db.getMembersByIds(group.memberIds);
        expenses.value = await _db.getExpensesByGroup(groupId);
        _calculateTotals();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load insights: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // MARK: - Calculations

  void _calculateTotals() {
    // Category totals
    final catTotals = <String, double>{};
    final catColors = <String, Color>{};

    int colorIndex = 0;

    for (final expense in expenses) {
      catTotals[expense.category] =
          (catTotals[expense.category] ?? 0) + expense.amount;

      if (!catColors.containsKey(expense.category)) {
        catColors[expense.category] =
            _chartColors[colorIndex % _chartColors.length];
        colorIndex++;
      }
    }
    categoryTotals.value = catTotals;
    categoryColorMap.value = catColors;

    // Member totals (who paid what)
    final memTotals = <int, double>{};
    for (final expense in expenses) {
      memTotals[expense.paidById] =
          (memTotals[expense.paidById] ?? 0) + expense.amount;
    }
    memberTotals.value = memTotals;
  }

  // MARK: - Chart Data

  List<PieChartSectionData> get categoryChartData {
    if (categoryTotals.isEmpty) return [];

    return categoryTotals.entries.map((entry) {
      final color = categoryColorMap[entry.key] ?? _chartColors[0];
      final total = totalExpenses;
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: color,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> get memberChartData {
    if (memberTotals.isEmpty) return [];

    int index = 0;
    return memberTotals.entries.map((entry) {
      final barData = BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: const Color(0xFF9B7FD8),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
      return barData;
    }).toList();
  }

  // MARK: - Computed Properties

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Member? getMemberById(int id) {
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  int? get topSpenderId {
    if (memberTotals.isEmpty) return null;
    return memberTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
