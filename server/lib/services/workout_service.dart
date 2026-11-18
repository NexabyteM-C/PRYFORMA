import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/workout_queries.dart' as wq;
import '../db/queries/personal_record_queries.dart' as prq;

class WorkoutService {
  final Database _db;
  final _uuid = const Uuid();

  WorkoutService(this._db);

  Future<Map<String, dynamic>> createWorkout({
    required String userId,
    String? organizationId,
    String? classSessionId,
    String? clientId,
    String? notes,
    required DateTime startedAt,
    DateTime? finishedAt,
    required List<Map<String, dynamic>> exercises,
  }) async {
    final sessionId = _uuid.v4();
    final newPrs = <Map<String, dynamic>>[];

    await _db.transaction((tx) async {
      await wq.insertWorkoutSession(
        tx,
        id: sessionId,
        userId: userId,
        organizationId: organizationId,
        classSessionId: classSessionId,
        clientId: clientId,
        notes: notes,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );

      for (var i = 0; i < exercises.length; i++) {
        final ex = exercises[i];
        final weId = _uuid.v4();
        await wq.insertWorkoutExercise(
          tx,
          id: weId,
          sessionId: sessionId,
          exerciseId: ex['exerciseId'] as String,
          variantId: ex['variantId'] as String?,
          sortOrder: i,
          notes: ex['notes'] as String?,
        );

        final sets = (ex['sets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        for (var j = 0; j < sets.length; j++) {
          final s = sets[j];
          final setId = _uuid.v4();
          await wq.insertPerformanceSet(
            tx,
            id: setId,
            workoutExerciseId: weId,
            setNumber: j + 1,
            setType: s['setType'] as String? ?? 'working',
            weightKg: (s['weightKg'] as num?)?.toDouble(),
            reps: s['reps'] as int?,
            durationMs: s['durationMs'] as int?,
            distanceM: (s['distanceM'] as num?)?.toDouble(),
            calories: s['calories'] as int?,
            clientId: s['clientId'] as String?,
          );

          newPrs.add({
            'exerciseId': ex['exerciseId'] as String,
            'setId': setId,
            'weightKg': (s['weightKg'] as num?)?.toDouble(),
            'reps': s['reps'] as int?,
            'durationMs': s['durationMs'] as int?,
          });
        }
      }
    });

    for (final pr in newPrs) {
      await _checkAndUpdatePr(
        userId: userId,
        exerciseId: pr['exerciseId'] as String,
        setId: pr['setId'] as String,
        weightKg: pr['weightKg'] as double?,
        reps: pr['reps'] as int?,
        durationMs: pr['durationMs'] as int?,
        achievedAt: startedAt,
      );
    }

    return (await wq.getWorkoutDetail(_db, sessionId, userId))!;
  }

  Future<void> _checkAndUpdatePr({
    required String userId,
    required String exerciseId,
    required String setId,
    double? weightKg,
    int? reps,
    int? durationMs,
    required DateTime achievedAt,
  }) async {
    if (weightKg != null && weightKg > 0) {
      final current = await prq.getCurrentPr(
        _db,
        userId: userId,
        exerciseId: exerciseId,
        metric: '1rm',
      );
      final currentVal =
          double.tryParse(current?['valueNumeric']?.toString() ?? '') ?? 0;
      if (weightKg > currentVal) {
        await prq.upsertPersonalRecord(
          _db,
          id: _uuid.v4(),
          userId: userId,
          exerciseId: exerciseId,
          metric: '1rm',
          valueNumeric: weightKg,
          achievedAt: achievedAt,
          setId: setId,
        );
      }
    }

    if (durationMs != null && durationMs > 0) {
      final current = await prq.getCurrentPr(
        _db,
        userId: userId,
        exerciseId: exerciseId,
        metric: 'time',
      );
      final currentMs = current?['valueDurationMs'] as int? ?? 999999999;
      if (durationMs < currentMs) {
        await prq.upsertPersonalRecord(
          _db,
          id: _uuid.v4(),
          userId: userId,
          exerciseId: exerciseId,
          metric: 'time',
          valueDurationMs: durationMs,
          achievedAt: achievedAt,
          setId: setId,
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> listWorkouts(
    String userId, {
    String? organizationId,
    int limit = 20,
    int offset = 0,
  }) {
    return wq.listWorkoutSessions(
      _db,
      userId,
      organizationId: organizationId,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> countWorkouts(String userId, {String? organizationId}) {
    return wq.countWorkoutSessions(
      _db,
      userId,
      organizationId: organizationId,
    );
  }

  Future<Map<String, dynamic>?> getWorkout(String sessionId, String userId) {
    return wq.getWorkoutDetail(_db, sessionId, userId);
  }
}
