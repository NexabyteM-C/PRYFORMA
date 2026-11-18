import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../personal_records/data/datasources/pr_remote_datasource.dart';
import '../../data/datasources/class_remote_datasource.dart';

/// Monday of the currently selected week (date-only).
final selectedWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  return monday;
});

final classRemoteDatasourceProvider = Provider<ClassRemoteDatasource>((ref) {
  return ClassRemoteDatasource(ref.watch(supabaseProvider));
});

/// Published class sessions (rich rows) for the week beginning [weekStart],
/// across every box the athlete belongs to.
// autoDispose so re-entering the Clases tab (or re-logging in) re-fetches —
// a coach's new/updated publication then shows up without a hard reload.
final weekSessionsProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, DateTime>(
        (ref, weekStart) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
  final end = start.add(const Duration(days: 7));
  return ds.calendar(
    weekStart: start.toIso8601String(),
    weekEnd: end.toIso8601String(),
  );
});

/// A session (preferred) or program detail with blocks + exercises.
/// The router passes a session id; we fall back to program lookup.
// autoDispose so re-opening a class always re-fetches: when a coach edits a
// published program (adds/removes an exercise, changes a block) the athlete
// sees it on the next open instead of a stale cached copy.
final classDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  try {
    return await ds.getSession(id);
  } catch (_) {
    return await ds.getProgram(id);
  }
});

/// Map of `exerciseId -> athlete's 1RM in KG`, derived from personal records.
/// Only real `1rm` records are used — never invented.
final athleteRmMapProvider =
    FutureProvider.autoDispose<Map<String, double>>((ref) async {
  // Refresh when auth changes.
  final supabase = ref.watch(supabaseProvider);
  if (supabase.auth.currentUser == null) return {};
  final ds = PrRemoteDatasource(supabase);
  final rows = await ds.list();
  final map = <String, double>{};
  for (final r in rows) {
    if (r['record_type'] != '1rm') continue;
    final exId = r['exercise_id'] as String?;
    final value = (r['value_numeric'] as num?)?.toDouble();
    if (exId == null || value == null) continue;
    if (!map.containsKey(exId) || value > map[exId]!) map[exId] = value;
  }
  return map;
});
