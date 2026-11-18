import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../organizations/presentation/providers/membership_provider.dart';

class AdminDashboardData {
  const AdminDashboardData({
    required this.orgId,
    required this.orgName,
    required this.members,
    required this.publishedThisWeek,
    required this.upcomingSessions,
    required this.draftPrograms,
    required this.todaySessions,
  });

  final String orgId;
  final String orgName;
  final int members;
  final int publishedThisWeek;
  final int upcomingSessions;
  final int draftPrograms;
  final List<Map<String, dynamic>> todaySessions;
}

/// Real stats for the admin's active organization. Resolves the org from the
/// current admin selection, falling back to the first admin-capable membership.
final adminDashboardProvider =
    FutureProvider<AdminDashboardData?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final memberships = await ref.watch(myMembershipsProvider.future);
  final adminMs = memberships.where((m) => isAdminRole(m.role)).toList();

  final selected = ref.watch(currentAdminOrgProvider);
  String? orgId = selected?.id;
  String orgName = selected?.name ?? '';
  if (orgId == null) {
    if (adminMs.isEmpty) return null;
    orgId = adminMs.first.organizationId;
    orgName = adminMs.first.organization?.name ?? 'Mi box';
  }

  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  final weekEnd = monday.add(const Duration(days: 7));
  final fmt = DateFormat('yyyy-MM-dd');
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayEnd = todayStart.add(const Duration(days: 1));

  final memberRows = await supabase
      .from('organization_members')
      .select('id')
      .eq('organization_id', orgId)
      .eq('status', 'active');

  final publishedRows = await supabase
      .from('class_programs')
      .select('id')
      .eq('organization_id', orgId)
      .eq('status', 'published')
      .gte('program_date', fmt.format(monday))
      .lt('program_date', fmt.format(weekEnd));

  final draftRows = await supabase
      .from('class_programs')
      .select('id')
      .eq('organization_id', orgId)
      .eq('status', 'draft');

  final upcomingRows = await supabase
      .from('class_sessions')
      .select('id, program:class_programs!inner(organization_id, status)')
      .gte('start_time', now.toIso8601String())
      .eq('program.organization_id', orgId)
      .eq('program.status', 'published');

  final todayRows = await supabase
      .from('class_sessions')
      .select(
        '*, program:class_programs!inner(title, status, organization_id), '
        'location:organization_locations(name), '
        'coaches:class_session_coaches(coach:profiles(display_name))',
      )
      .eq('program.organization_id', orgId)
      .gte('start_time', todayStart.toIso8601String())
      .lt('start_time', todayEnd.toIso8601String())
      .order('start_time');

  return AdminDashboardData(
    orgId: orgId,
    orgName: orgName,
    members: memberRows.length,
    publishedThisWeek: publishedRows.length,
    upcomingSessions: upcomingRows.length,
    draftPrograms: draftRows.length,
    todaySessions: List<Map<String, dynamic>>.from(todayRows),
  );
});
