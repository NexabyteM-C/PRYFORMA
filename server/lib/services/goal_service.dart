import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/goal_queries.dart' as q;

class GoalService {
  final Database _db;
  final _uuid = const Uuid();

  GoalService(this._db);

  Future<Map<String, dynamic>> createGoal({
    required String userId,
    required String exerciseId,
    required String metric,
    required double targetValue,
    DateTime? deadline,
  }) async {
    final id = _uuid.v4();
    await _db.transaction((tx) async {
      await q.insertGoal(
        tx,
        id: id,
        userId: userId,
        exerciseId: exerciseId,
        metric: metric,
        targetValue: targetValue,
        deadline: deadline,
      );
    });
    return (await q.findGoalById(_db, id, userId))!;
  }

  Future<List<Map<String, dynamic>>> listGoals(
    String userId, {
    String? status,
    int limit = 20,
    int offset = 0,
  }) {
    return q.listGoals(_db, userId, status: status, limit: limit, offset: offset);
  }

  Future<Map<String, dynamic>?> getGoal(String goalId, String userId) {
    return q.findGoalById(_db, goalId, userId);
  }

  Future<void> updateGoal({
    required String goalId,
    required String userId,
    double? targetValue,
    double? currentValue,
    String? status,
    DateTime? deadline,
  }) {
    return q.updateGoal(
      _db,
      goalId: goalId,
      userId: userId,
      targetValue: targetValue,
      currentValue: currentValue,
      status: status,
      deadline: deadline,
    );
  }

  Future<Map<String, dynamic>> addMilestone({
    required String goalId,
    required double value,
    String? note,
  }) async {
    final id = _uuid.v4();
    await q.insertMilestone(_db, id: id, goalId: goalId, value: value, note: note);
    return {'id': id, 'value': value, 'note': note};
  }

  Future<List<Map<String, dynamic>>> listMilestones(String goalId) {
    return q.listMilestones(_db, goalId);
  }
}
