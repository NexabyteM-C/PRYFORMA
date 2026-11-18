import 'package:supabase_flutter/supabase_flutter.dart';

class WorkoutRemoteDatasource {
  final SupabaseClient _supabase;
  WorkoutRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('workout_sessions')
        .select('*, exercises:workout_exercises(*, exercise:exercises(*))')
        .eq('athlete_id', userId)
        .order('performed_at', ascending: false);
  }

  Future<Map<String, dynamic>> getById(String id) async {
    return await _supabase
        .from('workout_sessions')
        .select('*, exercises:workout_exercises(*, exercise:exercises(*), sets:performance_sets(*))')
        .eq('id', id)
        .single();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    body['athlete_id'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('workout_sessions')
        .insert(body)
        .select()
        .single();
  }

  Future<Map<String, dynamic>> addExercise(Map<String, dynamic> body) async {
    return await _supabase.from('workout_exercises').insert(body).select().single();
  }

  Future<Map<String, dynamic>> addSet(Map<String, dynamic> body) async {
    return await _supabase.from('performance_sets').insert(body).select().single();
  }
}
