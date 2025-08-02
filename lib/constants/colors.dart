import 'package:flutter/material.dart';

class AppColors {
  // 🟦 Primary Colors
  static const Color primary = Color(0xFF4A90E2); // Calming Blue
  static const Color primaryLight = Color(0xFF6BA3E8);
  static const Color primaryDark = Color(0xFF3578D1);
  
  static const Color background = Color(0xFFF9FAFB); // Soft White
  static const Color textPrimary = Color(0xFF2C3E50); // Midnight Blue
  
  // 🌱 Secondary Colors
  static const Color secondary = Color(0xFFB2F0E7); // Mint Green
  static const Color secondaryLight = Color(0xFFE0F7F4); // Pale Aqua
  static const Color secondaryDark = Color(0xFF89E3D4);
  
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFC3C8DF); // Lavender Gray
  
  static const Color textSecondary = Color(0xFF7A8B99); // Slate Gray
  static const Color textTertiary = Color(0xFFA0A4B8);
  
  // 🌈 Accent Colors (Emotions & Highlights)
  static const Color accentYellow = Color(0xFFFFEB99); // Warm Yellow
  static const Color accentOrange = Color(0xFFFFAA7B); // Sunset Orange
  static const Color accentPurple = Color(0xFFB49FCC); // Muted Purple
  
  // 🚨 Status Colors
  static const Color success = Color(0xFF2ECC71); // Lime Green
  static const Color warning = Color(0xFFF5A623); // Amber
  static const Color error = Color(0xFFFF6F61); // Coral Red
  static const Color info = Color(0xFF56CCF2); // Sky Blue
  
  static const Color divider = Color(0xFFE0F7F4);
  static const Color disabled = Color(0xFFC3C8DF);
  
  // Wellness Score Colors
  static const Color wellnessHigh = Color(0xFF2ECC71); // Lime Green
  static const Color wellnessMedium = Color(0xFFF5A623); // Amber
  static const Color wellnessLow = Color(0xFFFF6F61); // Coral Red
  
  // Mood Colors (Using new palette)
  static const Color moodHappy = Color(0xFFFFEB99); // Warm Yellow
  static const Color moodCalm = Color(0xFFB2F0E7); // Mint Green
  static const Color moodNeutral = Color(0xFFC3C8DF); // Lavender Gray
  static const Color moodSad = Color(0xFF56CCF2); // Sky Blue
  static const Color moodAnxious = Color(0xFFFFAA7B); // Sunset Orange
  static const Color moodAngry = Color(0xFFFF6F61); // Coral Red
  static const Color moodEnergetic = Color(0xFFFFAA7B); // Sunset Orange
  static const Color moodTired = Color(0xFF7A8B99); // Slate Gray
  static const Color moodMindful = Color(0xFFB49FCC); // Muted Purple
  static const Color moodOverwhelmed = Color(0xFFFF6F61); // Coral Red
  
  // 🌒 Dark Mode Colors
  static const Color darkBackground = Color(0xFF1C1C2E);
  static const Color darkSurface = Color(0xFF2A2A3D);
  static const Color darkTextPrimary = Color(0xFFEDEDF2);
  static const Color darkTextSecondary = Color(0xFFA0A4B8);
  static const Color darkPrimary = Color(0xFF4A90E2);
  static const Color darkError = Color(0xFFFF6F61);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    // cardTheme will be handled via widget-level theming for now
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 8,
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.darkError,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

