import 'package:domain_models/domain_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

abstract class AuthRepository {
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<User?> getCurrentUser();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase;

  SupabaseAuthRepository(this._supabase);

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();
    return User.fromJson(data);
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', response.user!.id)
        .single();
    return User.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentSession != null;
  }

  @override
  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', session.user.id)
        .maybeSingle();
    if (data == null) return null;
    return User.fromJson(data);
  }
}
