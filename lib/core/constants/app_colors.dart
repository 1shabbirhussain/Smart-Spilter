import 'package:flutter/material.dart';

/// App color constants with premium calming palette
class AppColors {
  AppColors._();

  // MARK: - Gradient Colors

  /// Mint gradient - calming and fresh
  static const List<Color> mintGradient = [
    Color.fromARGB(250, 125, 255, 231),
    Color(0xFF6DD5C3),
  ];

  /// Lavender gradient - soothing and elegant
  static const List<Color> lavenderGradient = [
    Color.fromARGB(250, 144, 97, 255),
    Color(0xFF9B7FD8),
  ];

  /// Sky gradient - peaceful and open
  static const List<Color> skyGradient = [Color(0xFF87CEEB), Color(0xFF5FB3E0)];

  /// Peach gradient - warm and friendly
  static const List<Color> peachGradient = [
    Color.fromARGB(250, 255, 157, 96),
    Color(0xFFFF9A6C),
  ];

  /// Sunset gradient - vibrant and energetic
  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFC06C84),
  ];

  /// Ocean gradient - deep and calming
  static const List<Color> oceanGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];

  // MARK: - Semantic Colors

  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color info = Color(0xFF42A5F5);
  static const Color infoLight = Color(0xFF64B5F6);

  // MARK: - Neutral Colors

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // MARK: - Glassmorphism

  /// Light glass overlay for glassmorphic cards
  static const Color glassLight = Color(0x1AFFFFFF);

  /// Dark glass overlay for glassmorphic cards
  static const Color glassDark = Color(0x1A000000);

  /// Glass border color
  static const Color glassBorder = Color(0x33FFFFFF);

  // MARK: - Category Colors

  static const Color foodColor = Color(0xFFFF6B6B);
  static const Color transportColor = Color(0xFF4ECDC4);
  static const Color shoppingColor = Color(0xFFFFBE0B);
  static const Color entertainmentColor = Color(0xFF9B59B6);
  static const Color billsColor = Color(0xFF3498DB);
  static const Color healthColor = Color(0xFF2ECC71);
  static const Color travelColor = Color(0xFFE74C3C);
  static const Color otherColor = Color(0xFF95A5A6);

  // MARK: - Avatar Colors

  static const List<Color> avatarColors = [
    Color(0xFFFF6B9D),
    Color(0xFF4ECDC4),
    Color(0xFFFFBE0B),
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
    Color(0xFFF39C12),
    Color(0xFF1ABC9C),
    Color(0xFF34495E),
  ];

  // MARK: - Background Gradients

  /// Light mode background gradient
  static const List<Color> backgroundLightGradient = [
    Color(0xFFF8F9FA),
    Color(0xFFE9ECEF),
  ];

  /// Dark mode background gradient
  static const List<Color> backgroundDarkGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ];
}
