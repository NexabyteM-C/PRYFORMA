import 'package:supabase_flutter/supabase_flutter.dart';

class PrRemoteDatasource {
  final SupabaseClient _supabase;
  PrRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('personal_records')
        .select('*, exercise:exercises(*)')
        .eq('athlete_id', userId)
        .order('achieved_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> byExercise(String exerciseId) async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('personal_records')
        .select('*, exercise:exercises(*)')
        .eq('athlete_id', userId)
        .eq('exercise_id', exerciseId)
        .order('achieved_at', ascending: false);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    body['athlete_id'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('personal_records')
        .upsert(body, onConflict: 'athlete_id,exercise_id,record_type')
        .select('*, exercise:exercises(*)')
        .single();
  }

  Future<void> delete(String id) async {
    await _supabase.from('personal_records').delete().eq('id', id);
  }
}
