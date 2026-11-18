import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizationRemoteDatasource {
  final SupabaseClient _supabase;
  OrganizationRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list() async {
    final userId = _supabase.auth.currentUser!.id;
    final memberships = await _supabase
        .from('organization_members')
        .select(
          'organization:organizations(*, locations:organization_locations(*))',
        )
        .eq('user_id', userId)
        .eq('status', 'active');
    return memberships
        .map((m) => m['organization'] as Map<String, dynamic>)
        .toList();
  }

  /// Returns full memberships (with role) for the current user.
  Future<List<Map<String, dynamic>>> myMemberships() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('organization_members')
        .select(
          '*, organization:organizations(*, locations:organization_locations(*))',
        )
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('joined_at');
  }

  Future<Map<String, dynamic>> getById(String id) async {
    return await _supabase
        .from('organizations')
        .select('*, locations:organization_locations(*)')
        .eq('id', id)
        .single();
  }

  Future<List<Map<String, dynamic>>> members(String orgId) async {
    return await _supabase
        .from('organization_members')
        .select(
          '*, user:profiles(id, display_name, email, avatar_url, created_at)',
        )
        .eq('organization_id', orgId)
        .eq('status', 'active')
        .order('joined_at');
  }

  Future<List<Map<String, dynamic>>> allOrganizations() async {
    return await _supabase
        .from('organizations')
        .select('*, locations:organization_locations(*)')
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    body['owner_user_id'] = _supabase.auth.currentUser!.id;
    final org = await _supabase
        .from('organizations')
        .insert(body)
        .select()
        .single();
    // Owner becomes box_owner member
    await _supabase.from('organization_members').insert({
      'organization_id': org['id'],
      'user_id': _supabase.auth.currentUser!.id,
      'role': 'box_owner',
      'status': 'active',
    });
    return org;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> body,
  ) async {
    return await _supabase
        .from('organizations')
        .update(body)
        .eq('id', id)
        .select()
        .single();
  }

  Future<void> updateMemberRole(String memberId, String role) async {
    await _supabase
        .from('organization_members')
        .update({'role': role})
        .eq('id', memberId);
  }

  Future<void> removeMember(String memberId) async {
    await _supabase
        .from('organization_members')
        .update({'status': 'cancelled'})
        .eq('id', memberId);
  }

  /// Create an invitation and return its token.
  Future<String> createInvitation(String orgId, String role) async {
    final token =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
        _supabase.auth.currentUser!.id.substring(0, 6);
    await _supabase.from('organization_invitations').insert({
      'organization_id': orgId,
      'invited_by': _supabase.auth.currentUser!.id,
      'role': role,
      'token': token,
      'status': 'pending',
      'expires_at': DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String(),
    });
    return token;
  }

  Future<Map<String, dynamic>> join(String code) async {
    final invitation = await _supabase
        .from('organization_invitations')
        .select()
        .eq('token', code)
        .eq('status', 'pending')
        .single();

    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('organization_members').upsert({
      'organization_id': invitation['organization_id'],
      'user_id': userId,
      'role': invitation['role'],
      'status': 'active',
    }, onConflict: 'organization_id,user_id');

    await _supabase
        .from('organization_invitations')
        .update({
          'status': 'accepted',
          'accepted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', invitation['id']);

    return await getById(invitation['organization_id'] as String);
  }
}
