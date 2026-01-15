import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import '../../../core/services/export_service.dart';
import 'group_details_controller.dart';
import '../../expenses/presentation/add_expense_screen.dart';
import '../../insights/presentation/insights_screen.dart';
import '../../settlements/presentation/settlements_screen.dart';
import 'group_details_helpers.dart';

/// Group Details Screen showing expenses and balances
class GroupDetailsScreen extends StatelessWidget {
  final int groupId;

  const GroupDetailsScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupDetailsController(groupId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Obx(() => Text(controller.group.value?.name ?? 'Group Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              Get.to(() => InsightsScreen(groupId: groupId));
            },
            tooltip: 'Insights',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showExportOptions(context, controller),
            tooltip: 'Export',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.people_outline, size: 20),
                    SizedBox(width: 12),
                    Text('Manage Members'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    showManageMembersDialog(context, controller);
                  });
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.archive, size: 20),
                    SizedBox(width: 12),
                    Text('Archive Group'),
                  ],
                ),
                onTap: () async {
                  await controller.toggleArchive();
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.delete, size: 20, color: AppColors.error),
                    SizedBox(width: 12),
                    Text(
                      'Delete Group',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    showDeleteDialog(context, controller);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.loadGroupDetails,
              child: CustomScrollView(
                slivers: [
                  // Summary Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: _SummaryCard(controller: controller),
                    ),
                  ),

                  // Balances Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacing16,
                      ),
                      child: Text(
                        'Balances',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _BalancesSection(controller: controller),
                  ),

                  // Expenses Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expenses',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${controller.expenses.length} items',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expense List
                  controller.expenses.isEmpty
                      ? SliverToBoxAdapter(child: _EmptyExpenses())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final expense = controller.expenses[index];
                            return _ExpenseCard(
                              expense: expense,
                              controller: controller,
                            );
                          }, childCount: controller.expenses.length),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => AddExpenseScreen(groupId: groupId));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.lavenderGradient[1],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final GroupDetailsController controller;

  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Total Spent',
                value:
                    '${controller.group.value?.currency ?? ''} ${controller.totalExpenses.toStringAsFixed(2)}',
                icon: Icons.payments,
                color: AppColors.lavenderGradient[1],
              ),
              Container(width: 1, height: 40, color: AppColors.grey300),
              _StatItem(
                label: 'Members',
                value: '${controller.members.length}',
                icon: Icons.people,
                color: AppColors.mintGradient[1],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _BalancesSection extends StatelessWidget {
  final GroupDetailsController controller;

  const _BalancesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasBalances = controller.members.any((member) {
      final balance = controller.balances[member.id] ?? 0.0;
      return balance.abs() > 0.01;
    });

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      child: Column(
        children: [
          ...controller.members.map((member) {
            final balance = controller.balances[member.id] ?? 0.0;
            if (balance == 0) return const SizedBox.shrink();

            return _BalanceCard(
              member: member,
              balance: balance,
              currency: controller.group.value?.currency ?? '',
            );
          }).toList(),

          if (hasBalances) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(
                    () => SettlementsScreen(
                      groupId: controller.group.value!.id,
                      balances: controller.balances,
                      members: controller.members,
                      currency: controller.group.value!.currency,
                    ),
                  );
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Settle Up'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final dynamic member;
  final double balance;
  final String currency;

  const _BalanceCard({
    required this.member,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance > 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse('0xFF${member.colorHex}')),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(member.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  isPositive ? 'Gets back' : 'Owes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '$currency ${balance.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final dynamic expense;
  final GroupDetailsController controller;

  const _ExpenseCard({required this.expense, required this.controller});

  @override
  Widget build(BuildContext context) {
    final paidBy = controller.getMemberById(expense.paidById);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing16,
        vertical: 4,
      ),
      child: GlassmorphicCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.peachGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(expense.category),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Paid by ${paidBy?.name ?? "Unknown"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${controller.group.value?.currency ?? ''} ${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  expense.category,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.medical_services;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }
}

void _showExportOptions(
  BuildContext context,
  GroupDetailsController controller,
) {
  final exportService = ExportService();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export as PDF'),
            onTap: () async {
              Get.back();
              await exportService.exportToPDF(
                group: controller.group.value!,
                expenses: controller.expenses,
                members: controller.members,
                balances: controller.balances,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Share as Image'),
            onTap: () async {
              Get.back();
              await exportService.shareScreenshot(
                exportService.buildSummaryImage(
                  group: controller.group.value!,
                  expenses: controller.expenses,
                  balances: controller.balances,
                  members: controller.members,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing32),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
