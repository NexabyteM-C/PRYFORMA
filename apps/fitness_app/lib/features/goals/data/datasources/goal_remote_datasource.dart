import 'package:supabase_flutter/supabase_flutter.dart';

class GoalRemoteDatasource {
  final SupabaseClient _supabase;
  GoalRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('goals')
        .select('*, milestones:goal_milestones(*), exercise:exercises(*)')
        .eq('athlete_id', userId)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> getById(String id) async {
    return await _supabase
        .from('goals')
        .select('*, milestones:goal_milestones(*), exercise:exercises(*)')
        .eq('id', id)
        .single();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    body['athlete_id'] = _supabase.auth.currentUser!.id;
    return await _supabase.from('goals').insert(body).select().single();
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> body) async {
    return await _supabase.from('goals').update(body).eq('id', id).select().single();
  }

  Future<void> delete(String id) async {
    await _supabase.from('goals').delete().eq('id', id);
  }
}
