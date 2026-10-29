import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../data/services/auth_service.dart';

/// Pick (or change) a unique username that friends can search for
class UsernameSetupScreen extends StatefulWidget {
  /// Opened from Settings to change an existing username
  final bool isEditing;

  const UsernameSetupScreen({super.key, this.isEditing = false});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.text = AuthService.to.profile.value?.username ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = AuthService.normalizeUsername(_controller.text);
    if (!AuthService.usernamePattern.hasMatch(name)) {
      setState(
        () => _error = 'Use 3-20 lowercase letters, numbers, "_" or "."',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AuthService.to.setUsername(name);
      if (widget.isEditing && mounted) {
        Get.back();
        SnackbarUtils.showSuccess('Saved', 'Your username is now @$name');
      }
    } on UsernameTakenException catch (e) {
      setState(() => _error = e.toString());
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Change username' : 'Choose a username'),
        actions: [
          if (!widget.isEditing)
            TextButton(
              onPressed: () => AuthService.to.signOut(),
              child: const Text('Sign out'),
            ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            children: [
              Text(
                'Friends find you by your username. It must be unique.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing24),
              TextField(
                controller: _controller,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _saving ? null : _save(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                decoration: InputDecoration(
                  prefixText: '@',
                  labelText: 'Username',
                  hintText: 'e.g. ali_khan',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: AppDimensions.spacing32),
              AnimatedButton(
                text: widget.isEditing ? 'Save' : 'Continue',
                width: double.infinity,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
                gradientColors: AppColors.lavenderGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
