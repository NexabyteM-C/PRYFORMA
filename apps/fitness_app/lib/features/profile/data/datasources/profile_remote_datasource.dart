import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDatasource {
  final SupabaseClient _supabase;
  ProfileRemoteDatasource(this._supabase);

  Future<Map<String, dynamic>> getProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('profiles')
        .select('*, athlete_profiles(*)')
        .eq('id', userId)
        .single();
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('profiles')
        .update(body)
        .eq('id', userId)
        .select()
        .single();
  }

  /// Upsert the athlete_profiles row for the current user.
  Future<void> updateAthleteProfile(Map<String, dynamic> body) async {
    final userId = _supabase.auth.currentUser!.id;
    body['user_id'] = userId;
    await _supabase
        .from('athlete_profiles')
        .upsert(body, onConflict: 'user_id');
  }

  // --- Body measurements (athlete_measurements) ---

  /// All measurement records for the current user, newest first.
  Future<List<Map<String, dynamic>>> listMeasurements() async {
    final uid = _supabase.auth.currentUser!.id;
    final rows = await _supabase
        .from('athlete_measurements')
        .select('*')
        .eq('user_id', uid)
        .order('measured_at', ascending: false);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Insert a new measurement record for the current user and return it.
  Future<Map<String, dynamic>> createMeasurement(
      Map<String, dynamic> body) async {
    final uid = _supabase.auth.currentUser!.id;
    body['user_id'] = uid;
    final row = await _supabase
        .from('athlete_measurements')
        .insert(body)
        .select()
        .single();
    return Map<String, dynamic>.from(row);
  }

  /// Delete a measurement record by id.
  Future<void> deleteMeasurement(String id) async {
    await _supabase.from('athlete_measurements').delete().eq('id', id);
  }
}
