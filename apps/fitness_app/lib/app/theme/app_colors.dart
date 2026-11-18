import 'package:flutter/material.dart';

/// Runtime-switchable design tokens. The app defaults to the **dark**
/// (black-first) palette; the user can flip to **light** from the day/night
/// toggle and the choice is persisted on the device.
///
/// Because the whole app reads `AppColors.<token>`, the tokens are **getters**
/// (not `const`) that resolve against [brightness]. When the mode changes,
/// [apply] updates it and the root rebuilds the tree so every screen re-reads
/// the new values. `FitColors` (design_system) mirrors this for the shared
/// shells/bottom-nav.
abstract final class AppColors {
  static Brightness _brightness = Brightness.dark;
  static Brightness get brightness => _brightness;
  static bool get isDark => _brightness == Brightness.dark;

  /// Switches the active palette. Call before rebuilding the widget tree.
  static void apply(Brightness b) => _brightness = b;

  static Color _p(Color dark, Color light) => isDark ? dark : light;

  // ── Base surfaces ──
  static Color get background =>
      _p(const Color(0xFF0A0C10), const Color(0xFFF4F7FC));
  static Color get surface =>
      _p(const Color(0xFF151A22), const Color(0xFFFFFFFF));
  static Color get inputBackground =>
      _p(const Color(0xFF11161E), const Color(0xFFF9FBFE));
  static Color get badgeBackground =>
      _p(const Color(0xFF1C222C), const Color(0xFFEEF1F6));
  static Color get border =>
      _p(const Color(0xFF262C38), const Color(0xFFDDE5F2));

  // ── Brand blue ──
  static Color get primary =>
      _p(const Color(0xFF4C7DFF), const Color(0xFF2A52BE));
  static Color get primaryDark =>
      _p(const Color(0xFF2A52BE), const Color(0xFF0B2A6F));
  static Color get primaryLight =>
      _p(const Color(0xFF17233F), const Color(0xFFE6EEFF));
  static Color get primaryLighter =>
      _p(const Color(0xFF24335A), const Color(0xFFC9D8FF));
  static Color get primaryLightest =>
      _p(const Color(0xFF1B2948), const Color(0xFFDCE6FF));

  // ── Text ──
  static Color get textPrimary =>
      _p(const Color(0xFFF2F5FA), const Color(0xFF0A1A3F));
  static Color get textSecondary =>
      _p(const Color(0xFF9AA4B4), const Color(0xFF4B5A7A));

  // ── Secondary accent (teal) ──
  static Color get secondaryAccent =>
      _p(const Color(0xFF2BC4E6), const Color(0xFF0E7C9A));
  static Color get secondaryLight =>
      _p(const Color(0xFF0E2E39), const Color(0xFFE2F3F7));
  static Color get secondaryDark =>
      _p(const Color(0xFF7FD9EE), const Color(0xFF0B5F76));

  // ── Status ──
  static Color get warningBackground =>
      _p(const Color(0xFF2C2410), const Color(0xFFFFF3DC));
  static Color get warningText =>
      _p(const Color(0xFFF2C24E), const Color(0xFF7A4B00));
  static Color get success =>
      _p(const Color(0xFF2BD07A), const Color(0xFF16A34A));
  static Color get error =>
      _p(const Color(0xFFF26168), const Color(0xFFDC2626));
}
