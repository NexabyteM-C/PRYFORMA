import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../organizations/presentation/providers/membership_provider.dart';

/// The signed-in athlete's paid-membership status with their box(es).
///
/// Distinct from `organization_members` (belonging to a box): this reflects the
/// `member_memberships` the box admin manages in "Socios". Without an active
/// (vigente) membership the athlete may still use the app but cannot see or
/// enroll in classes — only their own progress and profile.
class AthleteMembership {
  const AthleteMembership({
    required this.active,
    required this.staffBypass,
    this.endsAt,
    this.planName,
  });

  /// Has a currently-valid paid membership (status active, not expired).
  final bool active;

  /// Coach/owner/admin in any box — never gated.
  final bool staffBypass;

  final DateTime? endsAt;
  final String? planName;

  /// Whether classes (calendar, detail, enrollment) are available.
  bool get canAccessClasses => active || staffBypass;
}

/// autoDispose so it re-fetches whenever a class screen is (re)entered and on
/// a fresh login — a box can activate a membership and the athlete sees it.
final athleteMembershipProvider =
    FutureProvider.autoDispose<AthleteMembership>((ref) async {
  ref.watch(authStateProvider); // re-fetch when auth changes
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) {
    return const AthleteMembership(active: false, staffBypass: false);
  }

  // Staff (coach/owner/admin in any box) bypass the membership gate.
  final memberships = await ref.watch(myMembershipsProvider.future);
  final staff = memberships.any((m) => isAdminRole(m.role));

  final now = DateTime.now();
  final todayStr =
      DateTime(now.year, now.month, now.day).toIso8601String().substring(0, 10);

  final rows = await supabase
      .from('member_memberships')
      .select('status, ends_at, plan_name')
      .eq('user_id', uid)
      .eq('status', 'active')
      .gte('ends_at', todayStr)
      .order('ends_at', ascending: false)
      .limit(1);

  final list = List<Map<String, dynamic>>.from(rows);
  if (list.isEmpty) {
    return AthleteMembership(active: false, staffBypass: staff);
  }
  final m = list.first;
  return AthleteMembership(
    active: true,
    staffBypass: staff,
    endsAt: DateTime.tryParse(m['ends_at'] as String? ?? ''),
    planName: m['plan_name'] as String?,
  );
});
