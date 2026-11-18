import 'package:supabase_flutter/supabase_flutter.dart';

/// Data access for the box's member-management system: membership plans,
/// per-member membership periods, and the income (payments) ledger.
class MembersDatasource {
  MembersDatasource(this._supabase);
  final SupabaseClient _supabase;

  // ── Members ────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> members(String orgId) async {
    final rows = await _supabase
        .from('organization_members')
        .select(
            '*, user:profiles(id, display_name, email, avatar_url, created_at)')
        .eq('organization_id', orgId)
        .eq('status', 'active')
        .order('joined_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  // ── Plans ──────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> plans(String orgId) async {
    final rows = await _supabase
        .from('membership_plans')
        .select()
        .eq('organization_id', orgId)
        .order('sort_order')
        .order('price_cop');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createPlan(Map<String, dynamic> body) async {
    return await _supabase.from('membership_plans').insert(body).select().single();
  }

  Future<void> updatePlan(String id, Map<String, dynamic> body) async {
    await _supabase.from('membership_plans').update(body).eq('id', id);
  }

  Future<void> deletePlan(String id) async {
    await _supabase.from('membership_plans').delete().eq('id', id);
  }

  // ── Memberships ─────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> memberships(String orgId) async {
    final rows = await _supabase
        .from('member_memberships')
        .select()
        .eq('organization_id', orgId)
        .order('ends_at');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createMembership(
      Map<String, dynamic> body) async {
    return await _supabase
        .from('member_memberships')
        .insert(body)
        .select()
        .single();
  }

  Future<void> setMembershipStatus(String id, String status) async {
    await _supabase
        .from('member_memberships')
        .update({'status': status}).eq('id', id);
  }

  // ── Payments (income ledger) ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> payments(String orgId) async {
    final rows = await _supabase
        .from('membership_payments')
        .select('*, user:profiles(id, display_name, email)')
        .eq('organization_id', orgId)
        .order('paid_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> body) async {
    return await _supabase
        .from('membership_payments')
        .insert(body)
        .select()
        .single();
  }
}
