import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../data/models/expense_model.dart';
import 'add_expense_controller.dart';

/// Add Expense Screen
class AddExpenseScreen extends StatelessWidget {
  final int groupId;

  const AddExpenseScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddExpenseController(groupId));
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    titleController.addListener(
      () => controller.title.value = titleController.text,
    );
    notesController.addListener(
      () => controller.notes.value = notesController.text,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Add Expense')),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Expense Title',
                    hintText: 'e.g., Dinner at Restaurant',
                    prefixIcon: Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Amount
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.updateAmount(double.tryParse(value) ?? 0.0);
                  },
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Category
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.category.value,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: controller.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(_getCategoryIcon(cat), size: 20),
                            const SizedBox(width: 8),
                            Text(cat),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.category.value = value;
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Paid By
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.paidById.value,
                    decoration: const InputDecoration(
                      labelText: 'Paid By',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: controller.members.map((member) {
                      return DropdownMenuItem(
                        value: member.id,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse('0xFF${member.colorHex}'),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  member.emoji,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(member.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) controller.paidById.value = value;
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Split Type
                Text(
                  'Split Type',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Obx(
                  () => SegmentedButton<SplitType>(
                    segments: const [
                      ButtonSegment(
                        value: SplitType.equal,
                        label: Text('Equal'),
                        icon: Icon(Icons.pie_chart),
                      ),
                      ButtonSegment(
                        value: SplitType.custom,
                        label: Text('Custom'),
                        icon: Icon(Icons.edit),
                      ),
                      ButtonSegment(
                        value: SplitType.percentage,
                        label: Text('%'),
                        icon: Icon(Icons.percent),
                      ),
                    ],
                    selected: {controller.splitType.value},
                    onSelectionChanged: (Set<SplitType> selection) {
                      controller.updateSplitType(selection.first);
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing16),

                // Split Details
                _SplitDetails(controller: controller),

                const SizedBox(height: AppDimensions.spacing16),

                // Notes
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any additional details',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: AppDimensions.spacing32),

                // Create Button
                Obx(
                  () => AnimatedButton(
                    text: 'Add Expense',
                    onPressed: controller.canCreate
                        ? controller.createExpense
                        : () {},
                    gradientColors: controller.canCreate
                        ? AppColors.lavenderGradient
                        : [AppColors.grey400, AppColors.grey400],
                    isLoading: controller.isCreating.value,
                  ),
                ),
              ],
            ),
          ),
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

class _SplitDetails extends StatelessWidget {
  final AddExpenseController controller;

  const _SplitDetails({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.splitType.value == SplitType.equal) {
        return _EqualSplitView(controller: controller);
      } else {
        return _CustomSplitView(controller: controller);
      }
    });
  }
}

class _EqualSplitView extends StatelessWidget {
  final AddExpenseController controller;

  const _EqualSplitView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.members.isEmpty || controller.amount.value == 0) {
        return const SizedBox.shrink();
      }

      final perPerson = controller.amount.value / controller.members.length;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mintGradient[0].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mintGradient[1].withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split equally among ${controller.members.length} members',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            ...controller.members.map((member) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(member.emoji),
                    const SizedBox(width: 8),
                    Expanded(child: Text(member.name)),
                    Text(
                      perPerson.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}

class _CustomSplitView extends StatelessWidget {
  final AddExpenseController controller;

  const _CustomSplitView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isPercentage = controller.splitType.value == SplitType.percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPercentage
              ? 'Set percentage for each member'
              : 'Enter amount for each member',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          isPercentage
              ? 'Use sliders or type exact values'
              : 'Tap to enter custom amounts',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey600),
        ),
        const SizedBox(height: 16),

        ...controller.members.map((member) {
          return Obx(() {
            final value = controller.customSplits[member.id] ?? 0.0;
            final displayValue = isPercentage ? value : value;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey200.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey300.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member info row
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse('0xFF${member.colorHex}')),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            member.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
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
                            if (isPercentage && controller.amount.value > 0)
                              Text(
                                '≈ ${((controller.amount.value * value) / 100).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.grey600),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: isPercentage ? '0%' : '0.00',
                            isDense: true,
                            suffix: isPercentage ? const Text('%') : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          controller: TextEditingController(
                            text: displayValue > 0
                                ? displayValue.toStringAsFixed(
                                    isPercentage ? 1 : 2,
                                  )
                                : '',
                          ),
                          onChanged: (val) {
                            final newValue = double.tryParse(val) ?? 0.0;
                            if (isPercentage) {
                              controller.updatePercentageSplit(
                                member.id,
                                newValue,
                              );
                            } else {
                              controller.updateCustomSplit(member.id, newValue);
                            }
                          },
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Slider for easier adjustment
                  if (isPercentage) ...[
                    const SizedBox(height: 12),
                    Slider(
                      value: value.clamp(0.0, 100.0),
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: '${value.toStringAsFixed(0)}%',
                      activeColor: AppColors.lavenderGradient[1],
                      onChanged: (newValue) {
                        controller.updatePercentageSplit(member.id, newValue);
                      },
                    ),
                  ],
                ],
              ),
            );
          });
        }).toList(),

        // Total/Validation indicator
        Obx(() {
          final isPercentage =
              controller.splitType.value == SplitType.percentage;
          final total = controller.customSplits.values.fold(
            0.0,
            (sum, val) => sum + val,
          );
          final target = isPercentage ? 100.0 : controller.amount.value;
          final remaining = target - total;
          final isValid = remaining.abs() < 0.01;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isValid
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isValid
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.warning,
                  color: isValid ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isValid
                            ? (isPercentage
                                  ? 'Perfect! Total is 100%'
                                  : 'Perfect! Split is balanced')
                            : (isPercentage
                                  ? 'Total must equal 100%'
                                  : 'Total must equal amount'),
                        style: TextStyle(
                          color: isValid
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isValid)
                        Text(
                          isPercentage
                              ? 'Remaining: ${remaining.toStringAsFixed(1)}%'
                              : 'Remaining: ${remaining.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isValid
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  isPercentage
                      ? '${total.toStringAsFixed(0)}%'
                      : total.toStringAsFixed(2),
                  style: TextStyle(
                    color: isValid ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
