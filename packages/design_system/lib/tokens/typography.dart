import 'package:flutter/material.dart';
import 'colors.dart';

abstract final class FitTypography {
  static const _heading = 'Space Grotesk';
  static const _body = 'Inter';

  static TextStyle get displayLarge => TextStyle(
        fontFamily: _heading,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        color: FitColors.textPrimary,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _heading,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.56,
        color: FitColors.textPrimary,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _heading,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: FitColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _heading,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: FitColors.textPrimary,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _heading,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: FitColors.textPrimary,
      );

  static TextStyle get titleLarge => TextStyle(
        fontFamily: _body,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: FitColors.textPrimary,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: FitColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _body,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: FitColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _body,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: FitColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _body,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: FitColors.textPrimary,
      );

  static TextStyle get labelLarge => TextStyle(
        fontFamily: _body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: FitColors.textPrimary,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _body,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: FitColors.textSecondary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _body,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.66,
        color: FitColors.textSecondary,
      );

  static TextStyle get statLarge => TextStyle(
        fontFamily: _heading,
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.32,
        height: 1,
        color: FitColors.textPrimary,
      );

  static TextStyle get statMedium => TextStyle(
        fontFamily: _heading,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: FitColors.textPrimary,
      );

  static TextStyle get blockNumber => TextStyle(
        fontFamily: _heading,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: FitColors.primary,
      );
}
