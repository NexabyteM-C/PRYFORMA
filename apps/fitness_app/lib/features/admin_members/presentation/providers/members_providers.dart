import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../../data/members_datasource.dart';

final membersDatasourceProvider = Provider<MembersDatasource>((ref) {
  return MembersDatasource(ref.watch(supabaseProvider));
});

/// The current admin org id (null when none resolved).
final adminOrgIdProvider = Provider<String?>((ref) {
  return ref.watch(resolvedAdminOrgProvider)?.id;
});

final membershipPlansProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orgId = ref.watch(adminOrgIdProvider);
  if (orgId == null) return [];
  return ref.watch(membersDatasourceProvider).plans(orgId);
});

final membershipsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orgId = ref.watch(adminOrgIdProvider);
  if (orgId == null) return [];
  return ref.watch(membersDatasourceProvider).memberships(orgId);
});

final membershipPaymentsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orgId = ref.watch(adminOrgIdProvider);
  if (orgId == null) return [];
  return ref.watch(membersDatasourceProvider).payments(orgId);
});

final rawMembersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final orgId = ref.watch(adminOrgIdProvider);
  if (orgId == null) return [];
  return ref.watch(membersDatasourceProvider).members(orgId);
});

/// Merged socio view: member profile + their current membership + status.
class SocioView {
  SocioView({
    required this.userId,
    required this.name,
    required this.email,
    required this.joinedAt,
    required this.role,
    this.membership,
  });

  final String userId;
  final String name;
  final String email;
  final DateTime? joinedAt;
  final String role;

  /// Latest non-cancelled membership row for this user, if any.
  final Map<String, dynamic>? membership;

  DateTime? get endsAt {
    final s = membership?['ends_at'] as String?;
    return s == null ? null : DateTime.tryParse(s);
  }

  String get membershipStatus => (membership?['status'] as String?) ?? 'none';
  String? get planName => membership?['plan_name'] as String?;

  /// Whole days remaining until expiry (negative if expired).
  int? get daysLeft {
    final e = endsAt;
    if (e == null) return null;
    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(e.year, e.month, e.day);
    return d1.difference(d0).inDays;
  }

  /// 'none' | 'frozen' | 'expired' | 'soon' | 'active'
  String get state {
    if (membership == null) return 'none';
    if (membershipStatus == 'frozen') return 'frozen';
    final d = daysLeft;
    if (d == null) return 'none';
    if (d < 0) return 'expired';
    if (d <= 7) return 'soon';
    return 'active';
  }

  bool get isVigente => state == 'active' || state == 'soon';
}

/// Members merged with their current membership, sorted by name.
final sociosProvider = FutureProvider<List<SocioView>>((ref) async {
  final members = await ref.watch(rawMembersProvider.future);
  final memberships = await ref.watch(membershipsProvider.future);

  // Pick the latest non-cancelled membership per user (max ends_at).
  final currentByUser = <String, Map<String, dynamic>>{};
  for (final m in memberships) {
    if ((m['status'] as String?) == 'cancelled') continue;
    final uid = m['user_id'] as String?;
    if (uid == null) continue;
    final ends = m['ends_at'] as String? ?? '';
    final existing = currentByUser[uid];
    if (existing == null || ends.compareTo(existing['ends_at'] as String? ?? '') > 0) {
      currentByUser[uid] = m;
    }
  }

  final list = members.map((row) {
    final user = (row['user'] as Map?)?.cast<String, dynamic>() ?? {};
    final uid = (user['id'] ?? row['user_id']) as String? ?? '';
    final joined = row['joined_at'] as String?;
    return SocioView(
      userId: uid,
      name: (user['display_name'] as String?)?.trim().isNotEmpty == true
          ? user['display_name'] as String
          : (user['email'] as String? ?? 'Socio'),
      email: user['email'] as String? ?? '',
      joinedAt: joined == null ? null : DateTime.tryParse(joined),
      role: (row['role'] as String?) ?? 'athlete',
      membership: currentByUser[uid],
    );
  }).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
});

/// Invalidates every socio-related provider after a mutation.
void refreshMembers(WidgetRef ref) {
  ref.invalidate(membershipPlansProvider);
  ref.invalidate(membershipsProvider);
  ref.invalidate(membershipPaymentsProvider);
  ref.invalidate(rawMembersProvider);
}
