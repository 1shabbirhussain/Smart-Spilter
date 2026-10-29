import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/social_models.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/social_service.dart';
import '../../auth/presentation/login_screen.dart';
import 'friends_screen.dart';
import 'user_avatar.dart';

/// Lets the user pick friends (e.g. to add to a group). Returns an empty
/// list when cancelled. Friends whose uid is in [excludeUids] are hidden.
Future<List<Friend>> pickFriends(
  BuildContext context, {
  Set<String> excludeUids = const {},
  bool multiple = true,
  String title = 'Add friends',
}) async {
  final auth = AuthService.to;
  if (!auth.firebaseReady) {
    SnackbarUtils.showError('Unavailable', 'Online features are not set up');
    return const [];
  }
  if (!auth.isSignedIn) {
    Get.to(() => const LoginScreen(fromSettings: true));
    return const [];
  }
  final result = await showModalBottomSheet<List<Friend>>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _FriendPickerSheet(
      excludeUids: excludeUids,
      multiple: multiple,
      title: title,
    ),
  );
  return result ?? const [];
}

class _FriendPickerSheet extends StatefulWidget {
  final Set<String> excludeUids;
  final bool multiple;
  final String title;

  const _FriendPickerSheet({
    required this.excludeUids,
    required this.multiple,
    required this.title,
  });

  @override
  State<_FriendPickerSheet> createState() => _FriendPickerSheetState();
}

class _FriendPickerSheetState extends State<_FriendPickerSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final social = SocialService.to;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Obx(() {
        final friends = social.friends
            .where((f) => !widget.excludeUids.contains(f.uid))
            .toList();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacing16,
              ),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing8),
            if (friends.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing24),
                child: Column(
                  children: [
                    Text(
                      social.friends.isEmpty
                          ? 'You have no friends yet.'
                          : 'All your friends are already here.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey600),
                    ),
                    const SizedBox(height: AppDimensions.spacing12),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Find friends'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(() => const FriendsScreen());
                      },
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (context, i) {
                    final friend = friends[i];
                    final avatar = UserAvatar(
                      name: friend.displayName,
                      photoUrl: friend.photoUrl,
                    );
                    if (!widget.multiple) {
                      return ListTile(
                        leading: avatar,
                        title: Text(friend.displayName),
                        subtitle: Text('@${friend.username}'),
                        onTap: () => Navigator.of(context).pop([friend]),
                      );
                    }
                    return CheckboxListTile(
                      secondary: avatar,
                      title: Text(friend.displayName),
                      subtitle: Text('@${friend.username}'),
                      value: _selected.contains(friend.uid),
                      activeColor: AppColors.lavenderGradient[1],
                      onChanged: (v) => setState(() {
                        v == true
                            ? _selected.add(friend.uid)
                            : _selected.remove(friend.uid);
                      }),
                    );
                  },
                ),
              ),
            if (widget.multiple && friends.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.lavenderGradient[1],
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(
                          friends
                              .where((f) => _selected.contains(f.uid))
                              .toList(),
                        ),
                  child: Text(
                    _selected.isEmpty
                        ? 'Select friends'
                        : 'Add ${_selected.length} friend${_selected.length == 1 ? '' : 's'}',
                  ),
                ),
              )
            else
              const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
