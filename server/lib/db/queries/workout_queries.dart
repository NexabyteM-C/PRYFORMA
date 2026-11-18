import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertWorkoutSession(
  TxSession tx, {
  required String id,
  required String userId,
  String? organizationId,
  String? classSessionId,
  String? clientId,
  String? notes,
  required DateTime startedAt,
  DateTime? finishedAt,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO workout_sessions
        (id, user_id, organization_id, class_session_id, client_id, notes, started_at, finished_at)
      VALUES (@id, @userId, @orgId, @classSessionId, @clientId, @notes, @startedAt, @finishedAt)
      ON CONFLICT (client_id) WHERE client_id IS NOT NULL DO NOTHING
    '''),
    parameters: {
      'id': id,
      'userId': userId,
      'orgId': organizationId,
      'classSessionId': classSessionId,
      'clientId': clientId,
      'notes': notes,
      'startedAt': startedAt,
      'finishedAt': finishedAt,
    },
  );
}

Future<void> insertWorkoutExercise(
  TxSession tx, {
  required String id,
  required String sessionId,
  required String exerciseId,
  String? variantId,
  required int sortOrder,
  String? notes,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO workout_exercises (id, session_id, exercise_id, variant_id, sort_order, notes)
      VALUES (@id, @sessionId, @exerciseId, @variantId, @sortOrder, @notes)
    '''),
    parameters: {
      'id': id,
      'sessionId': sessionId,
      'exerciseId': exerciseId,
      'variantId': variantId,
      'sortOrder': sortOrder,
      'notes': notes,
    },
  );
}

Future<void> insertPerformanceSet(
  TxSession tx, {
  required String id,
  required String workoutExerciseId,
  required int setNumber,
  String setType = 'working',
  double? weightKg,
  int? reps,
  int? durationMs,
  double? distanceM,
  int? calories,
  bool isPr = false,
  String? clientId,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO performance_sets
        (id, workout_exercise_id, set_number, set_type, weight_kg, reps,
         duration_ms, distance_m, calories, is_pr, client_id)
      VALUES (@id, @weId, @setNumber, @setType, @weightKg, @reps,
              @durationMs, @distanceM, @calories, @isPr, @clientId)
      ON CONFLICT (client_id) WHERE client_id IS NOT NULL DO NOTHING
    '''),
    parameters: {
      'id': id,
      'weId': workoutExerciseId,
      'setNumber': setNumber,
      'setType': setType,
      'weightKg': weightKg,
      'reps': reps,
      'durationMs': durationMs,
      'distanceM': distanceM,
      'calories': calories,
      'isPr': isPr,
      'clientId': clientId,
    },
  );
}

Future<List<Map<String, dynamic>>> listWorkoutSessions(
  Database db,
  String userId, {
  String? organizationId,
  int limit = 20,
  int offset = 0,
}) async {
  final where = <String>['ws.user_id = @userId'];
  final params = <String, dynamic>{
    'userId': userId,
    'lim': limit,
    'off': offset,
  };
  if (organizationId != null) {
    where.add('ws.organization_id = @orgId');
    params['orgId'] = organizationId;
  }

  final result = await db.query(
    '''
    SELECT ws.id, ws.started_at, ws.finished_at, ws.notes, ws.organization_id,
           ws.class_session_id, ws.created_at,
           COUNT(DISTINCT we.id) as exercise_count,
           COUNT(ps.id) as set_count
    FROM workout_sessions ws
    LEFT JOIN workout_exercises we ON we.session_id = ws.id
    LEFT JOIN performance_sets ps ON ps.workout_exercise_id = we.id
    WHERE ${where.join(' AND ')}
    GROUP BY ws.id
    ORDER BY ws.started_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: params,
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'startedAt': cols['started_at']?.toString(),
      'finishedAt': cols['finished_at']?.toString(),
      'notes': cols['notes'] as String?,
      'organizationId': cols['organization_id']?.toString(),
      'classSessionId': cols['class_session_id']?.toString(),
      'exerciseCount': cols['exercise_count'] as int? ?? 0,
      'setCount': cols['set_count'] as int? ?? 0,
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Future<Map<String, dynamic>?> getWorkoutDetail(
  Database db,
  String sessionId,
  String userId,
) async {
  final sessionResult = await db.query(
    '''
    SELECT id, user_id, organization_id, class_session_id, notes,
           started_at, finished_at, created_at
    FROM workout_sessions
    WHERE id = @id AND user_id = @userId
    ''',
    parameters: {'id': sessionId, 'userId': userId},
  );
  if (sessionResult.isEmpty) return null;

  final sCols = sessionResult.first.toColumnMap();
  final session = <String, dynamic>{
    'id': sCols['id']?.toString(),
    'startedAt': sCols['started_at']?.toString(),
    'finishedAt': sCols['finished_at']?.toString(),
    'notes': sCols['notes'] as String?,
    'organizationId': sCols['organization_id']?.toString(),
    'classSessionId': sCols['class_session_id']?.toString(),
    'createdAt': sCols['created_at']?.toString(),
  };

  final exercisesResult = await db.query(
    '''
    SELECT we.id, we.exercise_id, we.variant_id, we.sort_order, we.notes,
           e.name as exercise_name, e.category
    FROM workout_exercises we
    JOIN exercises e ON e.id = we.exercise_id
    WHERE we.session_id = @sessionId
    ORDER BY we.sort_order
    ''',
    parameters: {'sessionId': sessionId},
  );

  final exercises = <Map<String, dynamic>>[];
  for (final row in exercisesResult) {
    final eCols = row.toColumnMap();
    final weId = eCols['id']?.toString();

    final setsResult = await db.query(
      '''
      SELECT id, set_number, set_type, weight_kg, reps, duration_ms,
             distance_m, calories, is_pr
      FROM performance_sets
      WHERE workout_exercise_id = @weId
      ORDER BY set_number
      ''',
      parameters: {'weId': weId},
    );

    exercises.add({
      'id': weId,
      'exerciseId': eCols['exercise_id']?.toString(),
      'exerciseName': eCols['exercise_name'] as String?,
      'category': eCols['category'] as String?,
      'variantId': eCols['variant_id']?.toString(),
      'sortOrder': eCols['sort_order'] as int? ?? 0,
      'notes': eCols['notes'] as String?,
      'sets': setsResult.map((s) {
        final sc = s.toColumnMap();
        return {
          'id': sc['id']?.toString(),
          'setNumber': sc['set_number'] as int? ?? 0,
          'setType': sc['set_type'] as String?,
          'weightKg': sc['weight_kg']?.toString(),
          'reps': sc['reps'] as int?,
          'durationMs': sc['duration_ms'] as int?,
          'distanceM': sc['distance_m']?.toString(),
          'calories': sc['calories'] as int?,
          'isPr': sc['is_pr'] as bool? ?? false,
        };
      }).toList(),
    });
  }

  session['exercises'] = exercises;
  return session;
}

Future<int> countWorkoutSessions(
  Database db,
  String userId, {
  String? organizationId,
}) async {
  final where = <String>['user_id = @userId'];
  final params = <String, dynamic>{'userId': userId};
  if (organizationId != null) {
    where.add('organization_id = @orgId');
    params['orgId'] = organizationId;
  }

  final result = await db.query(
    'SELECT COUNT(*) as cnt FROM workout_sessions WHERE ${where.join(' AND ')}',
    parameters: params,
  );
  return result.first.toColumnMap()['cnt'] as int? ?? 0;
}
