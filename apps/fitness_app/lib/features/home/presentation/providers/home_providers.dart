import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../announcements/data/datasources/announcement_remote_datasource.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../organizations/presentation/providers/membership_provider.dart';

/// All of the athlete's upcoming enrollable classes (today .. +7d), one entry
/// per distinct program — its soonest upcoming session, so a program with
/// several time slots still shows a single card (the athlete picks the slot in
/// "Ver clase"). Sorted by start time. Rows are the rich calendar maps
/// (session + program + organization + ...).
final upcomingClassesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 8));
  final rows = await ds.calendar(
    weekStart: start.toIso8601String(),
    weekEnd: end.toIso8601String(),
  );
  final upcoming = rows.where((r) {
    final st = DateTime.tryParse(r['start_time'] as String? ?? '');
    return st != null && st.isAfter(now);
  }).toList()
    ..sort((a, b) =>
        (a['start_time'] as String).compareTo(b['start_time'] as String));

  // Keep only the soonest session of each distinct program (otherwise every
  // time slot of the same class would appear as its own card).
  final seenPrograms = <String>{};
  final out = <Map<String, dynamic>>[];
  for (final r in upcoming) {
    final pid = (r['program'] as Map?)?['id'] as String? ??
        r['program_id'] as String? ??
        r['id'] as String;
    if (seenPrograms.add(pid)) out.add(r);
  }
  return out;
});

/// The athlete's next upcoming published class (today .. +7d), or null.
/// Kept for callers that only need the single next class.
final nextClassProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final list = await ref.watch(upcomingClassesProvider.future);
  return list.isEmpty ? null : list.first;
});

/// The most recent published announcement across the athlete's boxes.
/// Each row carries an attached `_org_name` for display.
final latestAnnouncementProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final memberships = await ref.watch(myMembershipsProvider.future);
  final ds = AnnouncementRemoteDatasource(ref.watch(supabaseProvider));
  final all = <Map<String, dynamic>>[];
  for (final m in memberships) {
    final rows = await ds.list(m.organizationId);
    for (final r in rows) {
      if (r['published_at'] == null) continue;
      all.add({...r, '_org_name': m.organization?.name ?? ''});
    }
  }
  all.sort((a, b) =>
      (b['published_at'] as String).compareTo(a['published_at'] as String));
  return all.isEmpty ? null : all.first;
});
