import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementRemoteDatasource {
  final SupabaseClient _supabase;
  AnnouncementRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list(String orgId) async {
    return await _supabase
        .from('organization_announcements')
        .select(
          '*, author:profiles(id, display_name, email, avatar_url, created_at)',
        )
        .eq('organization_id', orgId)
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> create(
    String orgId,
    Map<String, dynamic> body,
  ) async {
    body['organization_id'] = orgId;
    body['author_id'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('organization_announcements')
        .insert(body)
        .select()
        .single();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _supabase
        .from('organization_announcements')
        .update(body)
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('organization_announcements').delete().eq('id', id);
  }
}
