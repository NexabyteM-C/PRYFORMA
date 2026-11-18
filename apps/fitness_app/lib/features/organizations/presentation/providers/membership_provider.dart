import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/organization_remote_datasource.dart';

/// Role hierarchy (higher index = more privilege).
const _roleRank = {
  'visitor': 0,
  'athlete': 1,
  'coach': 2,
  'box_admin': 3,
  'box_owner': 4,
  'superadmin': 5,
};

int roleRank(String role) => _roleRank[role] ?? 0;

bool isAdminRole(String role) => roleRank(role) >= roleRank('coach');

/// All active memberships for the signed-in user (with org + role).
final myMembershipsProvider = FutureProvider<List<OrganizationMember>>((
  ref,
) async {
  // Re-fetch when auth changes.
  ref.watch(authStateProvider);
  final supabase = ref.watch(supabaseProvider);
  if (supabase.auth.currentUser == null) return [];
  final ds = OrganizationRemoteDatasource(supabase);
  final rows = await ds.myMemberships();
  return rows.map((r) => OrganizationMember.fromJson(r)).toList();
});

/// The highest role the user holds across all boxes.
final highestRoleProvider = Provider<String>((ref) {
  final memberships = ref.watch(myMembershipsProvider).valueOrNull ?? [];
  if (memberships.isEmpty) return 'athlete';
  return memberships
      .map((m) => m.role)
      .reduce((a, b) => roleRank(a) >= roleRank(b) ? a : b);
});

/// Whether the user can access the admin/coach experience in at least one box.
final canAccessAdminProvider = Provider<bool>((ref) {
  final memberships = ref.watch(myMembershipsProvider).valueOrNull ?? [];
  return memberships.any((m) => isAdminRole(m.role));
});

/// Current UI mode: 'athlete' or 'admin'. Defaults to admin for admin-capable users.
final currentModeProvider = StateProvider<String>((ref) => 'athlete');

/// The org currently selected in admin mode (first admin-capable org by default).
final currentAdminOrgProvider = StateProvider<Organization?>((ref) => null);

/// Memberships where the user has an admin-capable role.
final adminMembershipsProvider = Provider<List<OrganizationMember>>((ref) {
  final memberships = ref.watch(myMembershipsProvider).valueOrNull ?? [];
  return memberships.where((m) => isAdminRole(m.role)).toList();
});
