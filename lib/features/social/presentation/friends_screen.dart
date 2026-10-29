import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/glassmorphic_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../data/models/social_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/database_service.dart';
import '../../groups/presentation/group_details_screen.dart';
import '../../../data/services/social_service.dart';
import 'user_avatar.dart';

String _errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

/// Friends list and incoming/outgoing friend requests
class FriendsScreen extends StatelessWidget {
  /// 0 = friends, 1 = requests
  final int initialTab;

  const FriendsScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final social = SocialService.to;
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Friends'),
              Tab(
                child: Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Requests'),
                      if (social.pendingCount > 0) ...[
                        const SizedBox(width: 6),
                        _CountBadge(count: social.pendingCount),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GradientBackground(
          child: const TabBarView(children: [_FriendsTab(), _RequestsTab()]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showAddFriendSheet(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Friend'),
          backgroundColor: AppColors.lavenderGradient[1],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

// MARK: - Friends tab

class _FriendsTab extends StatelessWidget {
  const _FriendsTab();

  @override
  Widget build(BuildContext context) {
    final social = SocialService.to;
    return Obx(() {
      if (social.friends.isEmpty) {
        return const _EmptyState(
          icon: Icons.people_outline,
          title: 'No friends yet',
          message: 'Add friends by their username or user ID',
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: social.friends.length,
        itemBuilder: (context, i) {
          final friend = social.friends[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
            child: GlassmorphicCard(
              onTap: () => _showSharedGroups(context, friend),
              child: Row(
                children: [
                  UserAvatar(
                    name: friend.displayName,
                    photoUrl: friend.photoUrl,
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: _NameBlock(
                      title: friend.displayName,
                      subtitle: '@${friend.username}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_remove_outlined),
                    tooltip: 'Remove friend',
                    onPressed: () => _confirmRemove(friend),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// Groups on this device that this friend is a member of
  Future<void> _showSharedGroups(BuildContext context, Friend friend) async {
    final groups = await DatabaseService().getGroupsWithMemberUid(friend.uid);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Groups with ${friend.displayName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            if (groups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No shared groups yet. Add them from a group\'s '
                  '"Manage Members" or when creating a group.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey600),
                ),
              )
            else
              ...groups.map(
                (g) => ListTile(
                  leading: Text(g.emoji, style: const TextStyle(fontSize: 28)),
                  title: Text(g.name),
                  subtitle: Text(
                    '${g.memberIds.length} members • ${g.currency}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Get.to(() => GroupDetailsScreen(groupId: g.id));
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(Friend friend) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove friend'),
        content: Text('Remove ${friend.displayName} from your friends?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Get.back();
              try {
                await SocialService.to.removeFriend(friend.uid);
              } catch (e) {
                SnackbarUtils.showError('Error', _errorText(e));
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// MARK: - Requests tab

class _RequestsTab extends StatelessWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context) {
    final social = SocialService.to;
    return Obx(() {
      final incoming = social.incomingRequests.toList();
      final outgoing = social.outgoingRequests.toList();

      if (incoming.isEmpty && outgoing.isEmpty) {
        return const _EmptyState(
          icon: Icons.mark_email_read_outlined,
          title: 'No pending requests',
          message: 'Friend requests show up here',
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          if (incoming.isNotEmpty) ...[
            const _SectionHeader('Friend requests'),
            ...incoming.map((r) => _IncomingRequestCard(request: r)),
          ],
          if (outgoing.isNotEmpty) ...[
            const _SectionHeader('Sent'),
            ...outgoing.map((r) => _OutgoingRequestCard(request: r)),
          ],
        ],
      );
    });
  }
}

/// Accept / decline buttons with a shared busy state
class _RespondButtons extends StatefulWidget {
  final Future<void> Function() onAccept;
  final Future<void> Function() onDecline;
  const _RespondButtons({required this.onAccept, required this.onDecline});

  @override
  State<_RespondButtons> createState() => _RespondButtonsState();
}

class _RespondButtonsState extends State<_RespondButtons> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      SnackbarUtils.showError('Error', _errorText(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _run(widget.onDecline),
          child: const Text('Decline'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.lavenderGradient[1],
          ),
          onPressed: () => _run(widget.onAccept),
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  final FriendRequest request;
  const _IncomingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphicCard(
        child: Column(
          children: [
            Row(
              children: [
                UserAvatar(
                  name: request.fromName,
                  photoUrl: request.fromPhotoUrl,
                ),
                const SizedBox(width: AppDimensions.spacing12),
                Expanded(
                  child: _NameBlock(
                    title: request.fromName,
                    subtitle: '@${request.fromUsername} wants to be friends',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacing8),
            _RespondButtons(
              onAccept: () => SocialService.to.acceptFriendRequest(request),
              onDecline: () => SocialService.to.deleteFriendRequest(request),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutgoingRequestCard extends StatelessWidget {
  final FriendRequest request;
  const _OutgoingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      child: GlassmorphicCard(
        child: Row(
          children: [
            UserAvatar(name: request.toName),
            const SizedBox(width: AppDimensions.spacing12),
            Expanded(
              child: _NameBlock(
                title: request.toName,
                subtitle: '@${request.toUsername} • Pending',
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await SocialService.to.deleteFriendRequest(request);
                } catch (e) {
                  SnackbarUtils.showError('Error', _errorText(e));
                }
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Add friend

void showAddFriendSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AddFriendSheet(),
  );
}

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet();

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _controller = TextEditingController();
  bool _searching = false;
  bool _sending = false;
  AppUser? _result;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _result = null;
      _message = null;
    });
    try {
      final user = await SocialService.to.findUser(query);
      setState(() {
        _result = user;
        _message = user == null ? 'No user found for "$query"' : null;
      });
    } catch (e) {
      setState(() => _message = _errorText(e));
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _send(AppUser user) async {
    setState(() => _sending = true);
    try {
      final msg = await SocialService.to.sendFriendRequest(user);
      if (mounted) Navigator.of(context).pop();
      SnackbarUtils.showSuccess('Done', msg);
    } catch (e) {
      setState(() => _message = _errorText(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String? _statusFor(AppUser user) {
    final social = SocialService.to;
    if (user.uid == AuthService.to.uid) return "That's you";
    if (social.isFriend(user.uid)) return 'Already friends';
    if (social.hasOutgoingRequest(user.uid)) return 'Request pending';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacing16,
        0,
        AppDimensions.spacing16,
        MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacing24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add a friend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.spacing16),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              labelText: 'Username or user ID',
              hintText: '@username',
              suffixIcon: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _search,
                    ),
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: AppDimensions.spacing12),
            Text(_message!, style: const TextStyle(color: AppColors.error)),
          ],
          if (result != null) ...[
            const SizedBox(height: AppDimensions.spacing16),
            GlassmorphicCard(
              child: Row(
                children: [
                  UserAvatar(
                    name: result.displayName,
                    photoUrl: result.photoUrl,
                  ),
                  const SizedBox(width: AppDimensions.spacing12),
                  Expanded(
                    child: _NameBlock(
                      title: result.displayName,
                      subtitle: result.handle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Builder(
              builder: (_) {
                final status = _statusFor(result);
                return AnimatedButton(
                  text: status ?? 'Send friend request',
                  icon: status == null ? Icons.person_add_alt_1 : null,
                  isLoading: _sending,
                  onPressed: status != null || _sending
                      ? null
                      : () => _send(result),
                  gradientColors: status == null
                      ? AppColors.lavenderGradient
                      : [AppColors.grey400, AppColors.grey500],
                );
              },
            ),
          ],
          const SizedBox(height: AppDimensions.spacing16),
          const _MyIdTile(),
        ],
      ),
    );
  }
}

/// Shows your own username + id so you can share them
class _MyIdTile extends StatelessWidget {
  const _MyIdTile();

  @override
  Widget build(BuildContext context) {
    final profile = AuthService.to.profile.value;
    if (profile == null) return const SizedBox.shrink();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.badge_outlined),
      title: Text('Your username: ${profile.handle}'),
      subtitle: Text(
        'ID: ${profile.uid}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        tooltip: 'Copy user ID',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: profile.uid));
          SnackbarUtils.showInfo('Copied', 'User ID copied to clipboard');
        },
      ),
    );
  }
}

// MARK: - Shared bits

class _NameBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  const _NameBlock({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.grey600,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: AppColors.grey400),
            const SizedBox(height: AppDimensions.spacing16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
