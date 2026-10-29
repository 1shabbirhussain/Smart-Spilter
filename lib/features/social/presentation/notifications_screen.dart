import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../data/models/social_models.dart';
import '../../../data/services/social_service.dart';
import 'friends_screen.dart';

/// Inbox of friend / group notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void dispose() {
    // Everything that was on screen has now been seen
    SocialService.to.markAllRead();
    super.dispose();
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.friendRequest:
        return Icons.person_add_alt_1;
      case AppNotificationType.friendAccepted:
        return Icons.how_to_reg;
      case AppNotificationType.addedToGroup:
        return Icons.group_add;
    }
  }

  bool _opensRequests(AppNotificationType type) =>
      type == AppNotificationType.friendRequest;

  @override
  Widget build(BuildContext context) {
    final social = SocialService.to;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: GradientBackground(
        child: Obx(() {
          if (social.inbox.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: AppDimensions.spacing16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final format = DateFormat('d MMM, h:mm a');
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spacing16),
            itemCount: social.inbox.length,
            itemBuilder: (context, i) {
              final n = social.inbox[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
                child: GlassmorphicCard(
                  onTap: _opensRequests(n.type)
                      ? () => Get.to(() => const FriendsScreen(initialTab: 1))
                      : null,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.lavenderGradient[0]
                            .withValues(alpha: 0.3),
                        child: Icon(
                          _iconFor(n.type),
                          color: AppColors.lavenderGradient[1],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacing12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: n.read
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(n.body),
                            const SizedBox(height: 4),
                            Text(
                              format.format(n.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (!n.read)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
