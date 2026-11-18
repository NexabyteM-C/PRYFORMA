import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persisted app brightness (dark by default). The choice is stored on the
/// device via secure storage so it survives restarts. The root widget watches
/// this, pushes it into the color tokens and rebuilds the whole tree.
class ThemeController extends StateNotifier<Brightness> {
  ThemeController() : super(Brightness.dark) {
    _load();
  }

  static const _key = 'theme_brightness';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    try {
      final v = await _storage.read(key: _key);
      if (v == 'light') {
        state = Brightness.light;
      } else if (v == 'dark') {
        state = Brightness.dark;
      }
    } catch (_) {
      // Keep the default (dark) if storage is unavailable.
    }
  }

  Future<void> _persist(Brightness b) async {
    try {
      await _storage.write(
          key: _key, value: b == Brightness.dark ? 'dark' : 'light');
    } catch (_) {
      // Non-fatal: the in-memory choice still applies for this session.
    }
  }

  /// Flips between dark and light and persists the new value.
  Future<void> toggle() async {
    final next =
        state == Brightness.dark ? Brightness.light : Brightness.dark;
    state = next;
    await _persist(next);
  }

  Future<void> set(Brightness b) async {
    state = b;
    await _persist(b);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, Brightness>(
  (ref) => ThemeController(),
);
