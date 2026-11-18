import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRemoteDatasource {
  final SupabaseClient _supabase;
  NotificationRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('notification_deliveries')
        .select()
        .eq('user_id', userId)
        .eq('channel', 'in_app')
        .order('created_at', ascending: false)
        .limit(50);
  }

  Future<void> markRead(String id) async {
    await _supabase
        .from('notification_deliveries')
        .update({'status': 'read', 'read_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }
}
