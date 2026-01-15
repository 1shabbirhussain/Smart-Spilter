import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import '../../../core/widgets/animated_button.dart';
import 'settlements_controller.dart';

/// Settlements Screen showing optimized settlements
class SettlementsScreen extends StatefulWidget {
  final int groupId;
  final Map<int, double> balances;
  final dynamic members;
  final String currency;

  const SettlementsScreen({
    super.key,
    required this.groupId,
    required this.balances,
    required this.members,
    required this.currency,
  });

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SettlementsController(
        groupId: widget.groupId,
        balances: widget.balances,
        members: widget.members,
      ),
    );

    // Listen to confetti trigger
    ever(controller.showConfetti, (show) {
      if (show) _confettiController.play();
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Settle Up')),
      body: Stack(
        children: [
          GradientBackground(
            child: SafeArea(
              child: Obx(() {
                if (controller.optimizedSettlements.isEmpty) {
                  return _buildAllSettled(context);
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suggested Settlements',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Optimized to minimize transactions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing20),

                      ...controller.optimizedSettlements.map((settlement) {
                        return _SettlementCard(
                          settlement: settlement,
                          controller: controller,
                          currency: widget.currency,
                        );
                      }).toList(),

                      if (controller.completedSettlements.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacing32),
                        Text(
                          'Payment History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.spacing12),

                        ...controller.completedSettlements.map((settlement) {
                          return _HistoryCard(
                            settlement: settlement,
                            controller: controller,
                            currency: widget.currency,
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppColors.success,
                AppColors.info,
                Color(0xFFFFD700),
                Color(0xFFFF69B4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSettled(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.mintGradient),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing24),
          Text(
            'All Settled! 🎉',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Everyone is even',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final dynamic settlement;
  final SettlementsController controller;
  final String currency;

  const _SettlementCard({
    required this.settlement,
    required this.controller,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final fromMember = controller.getMemberById(settlement.fromMemberId);
    final toMember = controller.getMemberById(settlement.toMemberId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphicCard(
        child: Column(
          children: [
            Row(
              children: [
                // From Member
                _MemberAvatar(member: fromMember),
                const SizedBox(width: 12),

                // Arrow
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.lavenderGradient[1],
                      ),
                      Text(
                        '$currency ${settlement.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.lavenderGradient[1],
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),
                // To Member
                _MemberAvatar(member: toMember),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${fromMember?.name ?? "Unknown"} pays ${toMember?.name ?? "Unknown"}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacing16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showPartialPaymentDialog(context),
                    child: const Text('Partial'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AnimatedButton(
                    text: 'Mark as Paid',
                    onPressed: () => controller.markAsSettled(settlement),
                    gradientColors:
                        AppColors.success.withOpacity(0.8) == AppColors.success
                        ? [
                            AppColors.success,
                            AppColors.success.withOpacity(0.7),
                          ]
                        : AppColors.mintGradient,
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPartialPaymentDialog(BuildContext context) {
    final amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Partial Payment'),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: 'Max: ${settlement.amount.toStringAsFixed(2)}',
            prefixText: '$currency ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0 && amount <= settlement.amount) {
                Get.back();
                controller.markPartialPayment(settlement, amount);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final dynamic member;

  const _MemberAvatar({this.member});

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person),
      );
    }

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${member.colorHex}')),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(member.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 4),
        Text(member.name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final dynamic settlement;
  final SettlementsController controller;
  final String currency;

  const _HistoryCard({
    required this.settlement,
    required this.controller,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final fromMember = controller.getMemberById(settlement.fromMemberId);
    final toMember = controller.getMemberById(settlement.toMemberId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey200.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${fromMember?.name ?? "Unknown"} → ${toMember?.name ?? "Unknown"}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '$currency ${settlement.amount.toStringAsFixed(2)}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
