import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_dimensions.dart';

/// Animated button with scale effect and haptic feedback
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradientColors,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeightMedium,
    this.borderRadius = AppDimensions.radiusMedium,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDimensions.animationFast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.mediumImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading || widget.onPressed == null ? null : _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradientColors != null
                ? LinearGradient(
                    colors: widget.gradientColors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.gradientColors?.first ??
                            widget.backgroundColor ??
                            Theme.of(context).primaryColor)
                        .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.textColor ?? Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.textColor ?? Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: widget.textColor ?? Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
