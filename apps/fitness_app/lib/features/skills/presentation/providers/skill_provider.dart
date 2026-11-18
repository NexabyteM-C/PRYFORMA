import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/skill_remote_datasource.dart';

final skillRemoteDatasourceProvider = Provider<SkillRemoteDatasource>((ref) {
  return SkillRemoteDatasource(ref.watch(supabaseProvider));
});

/// Ordered progression steps for one exercise (raw maps).
final progressionsForExerciseProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, exerciseId) {
  return ref.watch(skillRemoteDatasourceProvider).progressionsForExercise(exerciseId);
});

/// The current athlete's skill progress rows (raw maps).
final mySkillProgressProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(skillRemoteDatasourceProvider).myProgress();
});

/// Gimnasia exercises that have progressions (raw maps, with nested ids).
final gymnasticsExercisesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(skillRemoteDatasourceProvider).gymnasticsExercisesWithProgressions();
});

/// Actions that mutate skill progress and refresh affected providers.
final skillActionsProvider = Provider<SkillActions>((ref) => SkillActions(ref));

class SkillActions {
  SkillActions(this._ref);
  final Ref _ref;

  Future<void> toggle(
    String progressionId,
    bool achieved, {
    int? reps,
    int? durationMs,
    String? notes,
  }) async {
    await _ref.read(skillRemoteDatasourceProvider).toggleSkill(
          progressionId,
          achieved,
          reps: reps,
          durationMs: durationMs,
          notes: notes,
        );
    _ref.invalidate(mySkillProgressProvider);
  }
}
