import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertGoal(
  TxSession tx, {
  required String id,
  required String userId,
  required String exerciseId,
  required String metric,
  required double targetValue,
  DateTime? deadline,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO goals (id, user_id, exercise_id, metric, target_value, deadline)
      VALUES (@id, @userId, @exerciseId, @metric, @targetValue, @deadline)
    '''),
    parameters: {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      'metric': metric,
      'targetValue': targetValue,
      'deadline': deadline,
    },
  );
}

Future<List<Map<String, dynamic>>> listGoals(
  Database db,
  String userId, {
  String? status,
  int limit = 20,
  int offset = 0,
}) async {
  final where = <String>['g.user_id = @userId'];
  final params = <String, dynamic>{
    'userId': userId,
    'lim': limit,
    'off': offset,
  };
  if (status != null) {
    where.add('g.status = @status');
    params['status'] = status;
  }

  final result = await db.query(
    '''
    SELECT g.id, g.exercise_id, g.metric, g.target_value, g.current_value,
           g.status, g.deadline, g.completed_at, g.created_at,
           e.name as exercise_name
    FROM goals g
    JOIN exercises e ON e.id = g.exercise_id
    WHERE ${where.join(' AND ')}
    ORDER BY g.created_at DESC
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
      'metric': cols['metric'] as String?,
      'targetValue': cols['target_value']?.toString(),
      'currentValue': cols['current_value']?.toString(),
      'status': cols['status'] as String?,
      'deadline': cols['deadline']?.toString(),
      'completedAt': cols['completed_at']?.toString(),
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Future<Map<String, dynamic>?> findGoalById(
  Database db,
  String goalId,
  String userId,
) async {
  final result = await db.query(
    '''
    SELECT g.id, g.exercise_id, g.metric, g.target_value, g.current_value,
           g.status, g.deadline, g.completed_at, g.created_at,
           e.name as exercise_name
    FROM goals g
    JOIN exercises e ON e.id = g.exercise_id
    WHERE g.id = @goalId AND g.user_id = @userId
    ''',
    parameters: {'goalId': goalId, 'userId': userId},
  );
  if (result.isEmpty) return null;
  final cols = result.first.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'exerciseId': cols['exercise_id']?.toString(),
    'exerciseName': cols['exercise_name'] as String?,
    'metric': cols['metric'] as String?,
    'targetValue': cols['target_value']?.toString(),
    'currentValue': cols['current_value']?.toString(),
    'status': cols['status'] as String?,
    'deadline': cols['deadline']?.toString(),
    'completedAt': cols['completed_at']?.toString(),
    'createdAt': cols['created_at']?.toString(),
  };
}

Future<void> updateGoal(
  Database db, {
  required String goalId,
  required String userId,
  double? targetValue,
  double? currentValue,
  String? status,
  DateTime? deadline,
}) async {
  final sets = <String>[];
  final params = <String, dynamic>{'goalId': goalId, 'userId': userId};

  if (targetValue != null) {
    sets.add('target_value = @targetValue');
    params['targetValue'] = targetValue;
  }
  if (currentValue != null) {
    sets.add('current_value = @currentValue');
    params['currentValue'] = currentValue;
  }
  if (status != null) {
    sets.add('status = @status');
    params['status'] = status;
    if (status == 'completed') {
      sets.add('completed_at = NOW()');
    }
  }
  if (deadline != null) {
    sets.add('deadline = @deadline');
    params['deadline'] = deadline;
  }

  if (sets.isEmpty) return;

  await db.query(
    'UPDATE goals SET ${sets.join(', ')} WHERE id = @goalId AND user_id = @userId',
    parameters: params,
  );
}

Future<void> insertMilestone(
  Database db, {
  required String id,
  required String goalId,
  required double value,
  String? note,
}) async {
  await db.query(
    '''
    INSERT INTO goal_milestones (id, goal_id, value, note)
    VALUES (@id, @goalId, @value, @note)
    ''',
    parameters: {'id': id, 'goalId': goalId, 'value': value, 'note': note},
  );
}

Future<List<Map<String, dynamic>>> listMilestones(
  Database db,
  String goalId,
) async {
  final result = await db.query(
    '''
    SELECT id, value, note, reached_at, created_at
    FROM goal_milestones
    WHERE goal_id = @goalId
    ORDER BY value
    ''',
    parameters: {'goalId': goalId},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'value': cols['value']?.toString(),
      'note': cols['note'] as String?,
      'reachedAt': cols['reached_at']?.toString(),
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}
