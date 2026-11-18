import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote datasource for gymnastics skill progressions (spec §3.2).
///
/// These tables have no freezed model, so everything is raw maps.
class SkillRemoteDatasource {
  final SupabaseClient _supabase;
  SkillRemoteDatasource(this._supabase);

  String get _uid => _supabase.auth.currentUser!.id;

  /// Ordered progression steps for one exercise.
  Future<List<Map<String, dynamic>>> progressionsForExercise(
      String exerciseId) async {
    final rows = await _supabase
        .from('skill_progressions')
        .select()
        .eq('exercise_id', exerciseId)
        .order('sort_order');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// All of the current athlete's skill progress rows.
  Future<List<Map<String, dynamic>>> myProgress() async {
    final rows = await _supabase
        .from('athlete_skill_progress')
        .select()
        .eq('athlete_id', _uid);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Upsert the athlete's progress for one progression step.
  Future<void> toggleSkill(
    String progressionId,
    bool achieved, {
    int? reps,
    int? durationMs,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'athlete_id': _uid,
      'progression_id': progressionId,
      'achieved': achieved,
      'reps': reps,
      'duration_ms': durationMs,
      'notes': notes,
      'achieved_at': achieved ? DateTime.now().toUtc().toIso8601String() : null,
    };
    await _supabase.from('athlete_skill_progress').upsert(
          body,
          onConflict: 'athlete_id,progression_id',
        );
  }

  /// Distinct `gimnasia` exercises that have at least one progression,
  /// each carrying its progression step ids for X/N counting.
  Future<List<Map<String, dynamic>>> gymnasticsExercisesWithProgressions() async {
    final rows = await _supabase
        .from('exercises')
        .select('id, name, name_es, category, skill_progressions(id)')
        .eq('category', 'gimnasia')
        .order('name');
    return List<Map<String, dynamic>>.from(rows).where((e) {
      final progs = e['skill_progressions'];
      return progs is List && progs.isNotEmpty;
    }).toList();
  }
}
