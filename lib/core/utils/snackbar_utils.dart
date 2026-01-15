import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Utility class for showing premium polished snackbars
class SnackbarUtils {
  SnackbarUtils._();

  static void showSuccess(String title, String message) {
    _show(
      title: title,
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.check_circle_outline,
    );
  }

  static void showError(String title, String message) {
    _show(
      title: title,
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFFE57373), Color(0xFFEF9A9A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.error_outline,
    );
  }

  static void showInfo(String title, String message) {
    _show(
      title: title,
      message: message,
      gradient: AppColors.lavenderGradient,
      icon: Icons.info_outline,
    );
  }

  static void _show({
    required String title,
    required String message,
    required dynamic gradient, // List<Color> or LinearGradient
    required IconData icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.transparent, // Using gradient in background
      barBlur: 20, // Glassmorphism effect
      isDismissible: true,
      margin: const EdgeInsets.all(AppDimensions.spacing16),
      borderRadius: AppDimensions.radiusMedium,
      colorText: Colors.white,
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      icon: Icon(icon, color: Colors.white, size: 28),
      shouldIconPulse: true,
      backgroundGradient: gradient is LinearGradient
          ? gradient
          : LinearGradient(
              colors: gradient as List<Color>,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
