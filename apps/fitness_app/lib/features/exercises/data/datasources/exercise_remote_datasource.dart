import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseRemoteDatasource {
  final SupabaseClient _supabase;
  ExerciseRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list({String? search, String? category}) async {
    var query = _supabase
        .from('exercises')
        .select('*, variants:exercise_variants(*), metric_definitions:exercise_metric_definitions(*)');

    if (search != null && search.isNotEmpty) {
      // Match either the English name or the Spanish name_es. Escape the
      // PostgREST OR separators so a stray comma/parenthesis can't break it.
      final term = search.replaceAll(RegExp(r'[(),]'), ' ').trim();
      if (term.isNotEmpty) {
        query = query.or('name.ilike.%$term%,name_es.ilike.%$term%');
      }
    }
    if (category != null) {
      query = query.eq('category', category);
    }

    return await query.order('name');
  }

  Future<Map<String, dynamic>> getById(String id) async {
    return await _supabase
        .from('exercises')
        .select('*, variants:exercise_variants(*), metric_definitions:exercise_metric_definitions(*)')
        .eq('id', id)
        .single();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    body['created_by'] = _supabase.auth.currentUser!.id;
    return await _supabase.from('exercises').insert(body).select().single();
  }
}
