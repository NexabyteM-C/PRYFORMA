import '../database.dart';

Future<List<Map<String, dynamic>>> listPersonalRecords(
  Database db,
  String userId, {
  String? exerciseId,
  int limit = 50,
  int offset = 0,
}) async {
  final where = <String>['pr.user_id = @userId'];
  final params = <String, dynamic>{
    'userId': userId,
    'lim': limit,
    'off': offset,
  };

  if (exerciseId != null) {
    where.add('pr.exercise_id = @exerciseId');
    params['exerciseId'] = exerciseId;
  }

  final result = await db.query(
    '''
    SELECT pr.id, pr.exercise_id, pr.metric, pr.value_numeric, pr.value_duration_ms,
           pr.achieved_at, pr.set_id, pr.created_at,
           e.name as exercise_name, e.category
    FROM personal_records pr
    JOIN exercises e ON e.id = pr.exercise_id
    WHERE ${where.join(' AND ')}
    ORDER BY pr.achieved_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: params,
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'exerciseId': cols['exercise_id']?.toString(),
      'exerciseName': cols['exercise_name'] as String?,
      'category': cols['category'] as String?,
      'metric': cols['metric'] as String?,
      'valueNumeric': cols['value_numeric']?.toString(),
      'valueDurationMs': cols['value_duration_ms'] as int?,
      'achievedAt': cols['achieved_at']?.toString(),
      'setId': cols['set_id']?.toString(),
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Future<Map<String, dynamic>?> getCurrentPr(
  Database db, {
  required String userId,
  required String exerciseId,
  required String metric,
}) async {
  final result = await db.query(
    '''
    SELECT id, value_numeric, value_duration_ms, achieved_at, set_id
    FROM personal_records
    WHERE user_id = @userId AND exercise_id = @exerciseId AND metric = @metric
    ORDER BY value_numeric DESC NULLS LAST, value_duration_ms ASC NULLS LAST
    LIMIT 1
    ''',
    parameters: {
      'userId': userId,
      'exerciseId': exerciseId,
      'metric': metric,
    },
  );
  if (result.isEmpty) return null;
  final cols = result.first.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'valueNumeric': cols['value_numeric']?.toString(),
    'valueDurationMs': cols['value_duration_ms'] as int?,
    'achievedAt': cols['achieved_at']?.toString(),
    'setId': cols['set_id']?.toString(),
  };
}

Future<void> upsertPersonalRecord(
  Database db, {
  required String id,
  required String userId,
  required String exerciseId,
  required String metric,
  double? valueNumeric,
  int? valueDurationMs,
  required DateTime achievedAt,
  String? setId,
}) async {
  await db.query(
    '''
    INSERT INTO personal_records
      (id, user_id, exercise_id, metric, value_numeric, value_duration_ms, achieved_at, set_id)
    VALUES (@id, @userId, @exerciseId, @metric, @valueNumeric, @valueDurationMs, @achievedAt, @setId)
    ON CONFLICT (user_id, exercise_id, metric) DO UPDATE SET
      value_numeric = EXCLUDED.value_numeric,
      value_duration_ms = EXCLUDED.value_duration_ms,
      achieved_at = EXCLUDED.achieved_at,
      set_id = EXCLUDED.set_id
    WHERE
      (EXCLUDED.value_numeric IS NOT NULL AND
       (personal_records.value_numeric IS NULL OR EXCLUDED.value_numeric > personal_records.value_numeric))
      OR
      (EXCLUDED.value_duration_ms IS NOT NULL AND
       (personal_records.value_duration_ms IS NULL OR EXCLUDED.value_duration_ms < personal_records.value_duration_ms))
    ''',
    parameters: {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'metric': metric,
      'valueNumeric': valueNumeric,
      'valueDurationMs': valueDurationMs,
      'achievedAt': achievedAt,
      'setId': setId,
    },
  );
}

Future<List<Map<String, dynamic>>> getExerciseHistory(
  Database db, {
  required String userId,
  required String exerciseId,
  int limit = 30,
}) async {
  final result = await db.query(
    '''
    SELECT ps.weight_kg, ps.reps, ps.duration_ms, ps.set_number,
           ws.started_at
    FROM performance_sets ps
    JOIN workout_exercises we ON we.id = ps.workout_exercise_id
    JOIN workout_sessions ws ON ws.id = we.session_id
    WHERE we.exercise_id = @exerciseId AND ws.user_id = @userId
      AND ps.set_type = 'working'
    ORDER BY ws.started_at DESC, ps.set_number
    LIMIT @lim
    ''',
    parameters: {
      'userId': userId,
      'exerciseId': exerciseId,
      'lim': limit,
    },
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'weightKg': cols['weight_kg']?.toString(),
      'reps': cols['reps'] as int?,
      'durationMs': cols['duration_ms'] as int?,
      'setNumber': cols['set_number'] as int?,
      'date': cols['started_at']?.toString(),
    };
  }).toList();
}
