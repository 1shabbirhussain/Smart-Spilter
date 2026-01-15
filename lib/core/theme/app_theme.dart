import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  AppTheme._();

  // MARK: - Light Theme

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.lavenderGradient[1],
        secondary: AppColors.mintGradient[1],
        tertiary: AppColors.peachGradient[1],
        error: AppColors.error,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.grey900,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.grey50,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.grey900,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: AppColors.white,
      ),

      // Text Theme
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.grey900,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey900,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.grey800,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.grey800,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.grey600,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.grey700,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.grey600,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lavenderGradient[1],
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // MARK: - Dark Theme

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.lavenderGradient[0],
        secondary: AppColors.mintGradient[0],
        tertiary: AppColors.peachGradient[0],
        error: AppColors.errorLight,
        surface: const Color(0xFF1E1E2E),
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.grey100,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF16213E),

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.grey100,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.grey100,
        ),
      ),

      // Card
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Color(0xFF1E1E2E),
      ),

      // Text Theme
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              fontSize: 57,
              fontWeight: FontWeight.bold,
              color: AppColors.grey100,
            ),
            displayMedium: GoogleFonts.outfit(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: AppColors.grey100,
            ),
            displaySmall: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.grey100,
            ),
            headlineLarge: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.grey100,
            ),
            headlineMedium: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.grey100,
            ),
            headlineSmall: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.grey100,
            ),
            titleLarge: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.grey100,
            ),
            titleMedium: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey100,
            ),
            titleSmall: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey100,
            ),
            bodyLarge: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: AppColors.grey200,
            ),
            bodyMedium: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.grey200,
            ),
            bodySmall: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.grey400,
            ),
            labelLarge: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.grey300,
            ),
            labelMedium: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey300,
            ),
            labelSmall: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.grey400,
            ),
          ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252538),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.lavenderGradient[0],
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.errorLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
