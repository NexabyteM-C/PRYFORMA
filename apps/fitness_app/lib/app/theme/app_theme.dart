import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  /// Backwards-compatible alias (callers used `AppTheme.light`). It now returns
  /// a theme built from the *currently active* [AppColors] palette (dark or
  /// light), so toggling the mode + rebuilding swaps the whole app.
  static ThemeData get light => theme;

  /// The ThemeData for whatever brightness [AppColors] is currently set to.
  static ThemeData get theme {
    final interTextTheme = GoogleFonts.interTextTheme();
    final spaceGrotesk = GoogleFonts.spaceGroteskTextTheme();
    final dark = AppColors.isDark;

    final scheme = dark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.secondaryAccent,
            onSecondary: AppColors.background,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            error: AppColors.error,
            onError: Colors.white,
            outline: AppColors.border,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.secondaryAccent,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
            error: AppColors.error,
            outline: AppColors.border,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: AppColors.brightness,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: scheme,
      textTheme: interTextTheme.copyWith(
        displayLarge: spaceGrotesk.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.64,
          color: AppColors.textPrimary,
        ),
        displayMedium: spaceGrotesk.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.56,
          color: AppColors.textPrimary,
        ),
        displaySmall: spaceGrotesk.displaySmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: spaceGrotesk.headlineMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: spaceGrotesk.headlineSmall?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: interTextTheme.titleLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: interTextTheme.titleMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: interTextTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: interTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodySmall: interTextTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: interTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: interTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: interTextTheme.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.66,
          color: AppColors.textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: interTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: interTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
