import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../auth/presentation/auth_gate.dart';

/// Picks up where the native splash leaves off: same background and logo,
/// then reveals the app name before fading into the auth gate. The swap
/// happens in place (not via navigation) so routes pushed at launch, such as
/// the inbox from a notification tap, stay on top.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Matches the native splash colour in pubspec.yaml
  static const background = Color(0xFF141A2E);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      child: _done ? const AuthGate() : _buildSplash(),
    );
  }

  Widget _buildSplash() {
    return Scaffold(
      backgroundColor: SplashScreen.background,
      body: Stack(
        children: [
          // Soft colour glows behind the logo
          Positioned(
            top: -120,
            left: -80,
            child: _Glow(color: AppColors.lavenderGradient[0]),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: _Glow(color: AppColors.mintGradient[1]),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/branding/splash_logo.png', width: 180)
                    .animate()
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      duration: 700.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .shimmer(
                      duration: 900.ms,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                const SizedBox(height: 24),
                const Text(
                  'Smart Split',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(delay: 250.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                Text(
                  'Split smarter. Settle faster.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;

  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 360,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ),
      ),
    ).animate().fadeIn(duration: 900.ms);
  }
}
