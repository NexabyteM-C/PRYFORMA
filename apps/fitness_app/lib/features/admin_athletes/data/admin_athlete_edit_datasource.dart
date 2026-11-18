import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/networking/supabase_client.dart';

/// Calls the `admin-update-athlete` Edge Function so an admin/owner can change
/// another athlete's name, email and/or password. Email and password changes
/// need the service_role key, which lives only inside the function — never in
/// this client.
class AdminAthleteEditDatasource {
  AdminAthleteEditDatasource(this._supabase);
  final SupabaseClient _supabase;

  /// Updates the athlete. Pass only the fields that changed; null = untouched.
  /// Throws [AdminAthleteEditException] with a readable message on failure.
  Future<void> updateAthlete({
    required String organizationId,
    required String targetUserId,
    String? displayName,
    String? email,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'organizationId': organizationId,
      'targetUserId': targetUserId,
      'displayName': ?displayName,
      'email': ?email,
      'password': ?password,
    };

    try {
      final res = await _supabase.functions.invoke(
        'admin-update-athlete',
        body: body,
      );
      final data = res.data;
      if (data is Map && data['ok'] == true) return;
      final msg = (data is Map ? data['error'] : null)?.toString() ??
          'No se pudo actualizar el atleta.';
      throw AdminAthleteEditException(msg);
    } on FunctionException catch (e) {
      // The function returned a non-2xx status; surface its error message.
      final details = e.details;
      final msg = (details is Map ? details['error'] : null)?.toString() ??
          e.reasonPhrase ??
          'No se pudo actualizar el atleta.';
      throw AdminAthleteEditException(msg);
    }
  }
}

class AdminAthleteEditException implements Exception {
  AdminAthleteEditException(this.message);
  final String message;
  @override
  String toString() => message;
}

final adminAthleteEditDatasourceProvider =
    Provider<AdminAthleteEditDatasource>((ref) {
  return AdminAthleteEditDatasource(ref.watch(supabaseProvider));
});
