import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import 'insights_controller.dart';

/// Insights Screen showing spending analytics
class InsightsScreen extends StatelessWidget {
  final int groupId;

  const InsightsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InsightsController(groupId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Insights')),
      body: GradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.expenses.isEmpty) {
              return _buildEmptyState(context);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Total Summary
                  _TotalSummaryCard(controller: controller),
                  const SizedBox(height: AppDimensions.spacing16),

                  // Summary Cards Row
                  _SummaryCards(controller: controller),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Category Breakdown Section
                  _SectionHeader(context, 'Spending by Category'),
                  const SizedBox(height: AppDimensions.spacing16),

                  GlassmorphicCard(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: controller.categoryChartData,
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing24),
                        // Legend
                        _CategoryLegend(controller: controller),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Member Spending Section
                  _SectionHeader(context, 'Who Paid What?'),
                  const SizedBox(height: AppDimensions.spacing16),

                  GlassmorphicCard(
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 24,
                              right: 16,
                              left:
                                  6, // Reduced left padding as titles are reserved
                              bottom: 0,
                            ),
                            child: BarChart(
                              BarChartData(
                                barGroups: controller.memberChartData,
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0) return const SizedBox();
                                        return Text(
                                          _formatCurrency(value),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                      reservedSize: 40, // Prevent overlap
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >=
                                                controller
                                                    .memberTotals
                                                    .length) {
                                          return const SizedBox();
                                        }
                                        final memberId = controller
                                            .memberTotals
                                            .keys
                                            .elementAt(index);
                                        final member = controller.getMemberById(
                                          memberId,
                                        );
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            member?.emoji ?? '?',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: Colors.grey.withOpacity(0.1),
                                    strokeWidth: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacing16),
                        const Divider(height: 1),
                        // Member List/Legend
                        _MemberListLegend(controller: controller),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacing32),

                  // Top Spender Highlight
                  if (controller.topSpenderId != null)
                    _TopSpenderCard(controller: controller),

                  const SizedBox(height: AppDimensions.spacing32),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _SectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined, size: 80, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No insights yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add expenses to see analytics',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _TotalSummaryCard extends StatelessWidget {
  final InsightsController controller;

  const _TotalSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Total Spent',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
            ),
            const SizedBox(height: 4),
            Text(
              // Assuming currency is consistent with group, simplified here
              '${controller.totalExpenses.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.lavenderGradient[1],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final InsightsController controller;

  const _SummaryCards({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphicCard(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.lavenderGradient[1],
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.expenses.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Expenses', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassmorphicCard(
            child: Column(
              children: [
                Icon(
                  Icons.category,
                  color: AppColors.peachGradient[1],
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.categoryTotals.length}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  final InsightsController controller;

  const _CategoryLegend({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: controller.categoryTotals.entries.map((entry) {
          final color = controller.categoryColorMap[entry.key]!;
          final amount = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  amount.toStringAsFixed(2),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MemberListLegend extends StatelessWidget {
  final InsightsController controller;

  const _MemberListLegend({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: controller.memberTotals.entries.map((entry) {
          final member = controller.getMemberById(entry.key);
          final amount = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Center(
                    child: Text(
                      member?.emoji ?? '?',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member?.name ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.lavenderGradient[1],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TopSpenderCard extends StatelessWidget {
  final InsightsController controller;

  const _TopSpenderCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final topMember = controller.getMemberById(controller.topSpenderId!);
    final topAmount = controller.memberTotals[controller.topSpenderId!] ?? 0;

    return GlassmorphicCard(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.sunsetGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Contributor',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    topMember?.name ?? 'Unknown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  topAmount.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
