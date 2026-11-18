import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../core/networking/supabase_client.dart';

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final supabase = ref.watch(supabaseProvider);
    final session = supabase.auth.currentSession;
    if (session == null) return null;
    return _fetchProfile(supabase, session.user.id);
  }

  Future<User?> _fetchProfile(SupabaseClient supabase, String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return User.fromJson(data);
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      try {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return await _fetchProfile(supabase, response.user!.id);
      } on AuthException catch (e) {
        throw AuthErrorUser(e.message, e.statusCode);
      }
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      try {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'display_name': displayName},
        );
        final userId = response.user!.id;
        for (var i = 0; i < 5; i++) {
          final profile = await _fetchProfile(supabase, userId);
          if (profile != null) return profile;
          await Future.delayed(const Duration(milliseconds: 400));
        }
        return await _fetchProfile(supabase, userId);
      } on AuthException catch (e) {
        throw AuthErrorUser(e.message, e.statusCode);
      }
    });
  }

  Future<void> logout() async {
    final supabase = ref.read(supabaseProvider);
    await supabase.auth.signOut();
    state = const AsyncData(null);
  }
}

class AuthErrorUser implements Exception {
  final String message;
  final String? statusCode;
  AuthErrorUser(this.message, this.statusCode);

  String get userMessage {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión';
    }
    if (msg.contains('user already registered') ||
        msg.contains('user_already_exists')) {
      return 'Ya existe una cuenta con este correo';
    }
    if (msg.contains('password') && msg.contains('short')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (msg.contains('rate limit') || msg.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return 'Error de conexión. Verifica tu internet';
    }
    if (msg.contains('invalid api key')) {
      return 'Error de configuración del servidor. Contacta al administrador';
    }
    if (msg.contains('email_provider_disabled')) {
      return 'El inicio de sesión por correo está deshabilitado';
    }
    if (msg.contains('signup_disabled')) {
      return 'El registro de nuevos usuarios está deshabilitado';
    }
    return 'Ocurrió un error. Intenta de nuevo';
  }

  @override
  String toString() => userMessage;
}
