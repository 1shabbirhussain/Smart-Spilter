import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

/// Animated gradient background with floating blobs
class GradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? gradientColors;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradientColors,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors =
        widget.gradientColors ??
        (isDark
            ? AppColors.backgroundDarkGradient
            : AppColors.backgroundLightGradient);

    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),

        // Animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _BlobPainter(
                animation: _controller.value,
                isDark: isDark,
              ),
              child: Container(),
            );
          },
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  _BlobPainter({required this.animation, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Blob 1 - Mint
    final blob1Color =
        (isDark ? AppColors.mintGradient[1] : AppColors.mintGradient[0])
            .withOpacity(0.22);
    paint.color = blob1Color;

    final blob1X =
        size.width * 0.2 + math.sin(animation * 2 * math.pi) * size.width * 0.1;
    final blob1Y =
        size.height * 0.3 +
        math.cos(animation * 2 * math.pi) * size.height * 0.1;

    canvas.drawCircle(Offset(blob1X, blob1Y), size.width * 0.3, paint);

    // Blob 2 - Lavender
    final blob2Color =
        (isDark ? AppColors.lavenderGradient[1] : AppColors.lavenderGradient[0])
            .withOpacity(0.20);
    paint.color = blob2Color;

    final blob2X =
        size.width * 0.8 +
        math.cos(animation * 2 * math.pi + 1) * size.width * 0.1;
    final blob2Y =
        size.height * 0.6 +
        math.sin(animation * 2 * math.pi + 1) * size.height * 0.1;

    canvas.drawCircle(Offset(blob2X, blob2Y), size.width * 0.35, paint);

    // Blob 3 - Peach
    final blob3Color =
        (isDark ? AppColors.peachGradient[1] : AppColors.peachGradient[0])
            .withOpacity(0.22);
    paint.color = blob3Color;

    final blob3X =
        size.width * 0.5 +
        math.sin(animation * 2 * math.pi + 2) * size.width * 0.15;
    final blob3Y =
        size.height * 0.8 +
        math.cos(animation * 2 * math.pi + 2) * size.height * 0.1;

    canvas.drawCircle(Offset(blob3X, blob3Y), size.width * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.isDark != isDark;
  }
}
