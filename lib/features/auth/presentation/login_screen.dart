import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/services/app_prefs.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/widgets/animated_button.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../data/services/auth_service.dart';

/// Google sign-in. Signing in is optional: groups work offline without it.
class LoginScreen extends StatefulWidget {
  /// Shown from Settings (pops on success) rather than as the app's home
  final bool fromSettings;

  const LoginScreen({super.key, this.fromSettings = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await AuthService.to.signInWithGoogle();
      if (AuthService.to.isSignedIn) {
        AppPrefs.skippedLogin = false;
        // Back to the root so the auth gate can show username setup if needed
        if (widget.fromSettings && mounted) Get.until((r) => r.isFirst);
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Sign-in failed',
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _skip() {
    AppPrefs.skippedLogin = true;
    if (widget.fromSettings) {
      Get.back();
    } else {
      AuthGateController.to.refreshGate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.fromSettings ? AppBar(title: const Text('Sign in')) : null,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing24),
            child: Column(
              children: [
                const Spacer(),
                Image.asset('assets/branding/splash_logo.png', width: 120),
                const SizedBox(height: AppDimensions.spacing24),
                Text(
                  'Smart Split',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacing12),
                Text(
                  'Sign in to add friends, invite them to groups and get '
                  'notified about requests.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const Spacer(),
                AnimatedButton(
                  text: 'Continue with Google',
                  icon: Icons.login,
                  width: double.infinity,
                  isLoading: _loading,
                  onPressed: _loading ? null : _signIn,
                  gradientColors: AppColors.lavenderGradient,
                ),
                const SizedBox(height: AppDimensions.spacing12),
                TextButton(
                  onPressed: _loading ? null : _skip,
                  child: Text(
                    widget.fromSettings
                        ? 'Not now'
                        : 'Continue without account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lets screens ask the gate to re-evaluate (e.g. after "skip")
class AuthGateController extends GetxController {
  static AuthGateController get to => Get.find<AuthGateController>();

  final RxBool skipped = AppPrefs.skippedLogin.obs;

  void refreshGate() => skipped.value = AppPrefs.skippedLogin;
}
