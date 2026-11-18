import '../db/database.dart';
import '../db/queries/personal_record_queries.dart' as q;

class PersonalRecordService {
  final Database _db;

  PersonalRecordService(this._db);

  Future<List<Map<String, dynamic>>> listRecords(
    String userId, {
    String? exerciseId,
    int limit = 50,
    int offset = 0,
  }) {
    return q.listPersonalRecords(
      _db,
      userId,
      exerciseId: exerciseId,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory({
    required String userId,
    required String exerciseId,
    int limit = 30,
  }) {
    return q.getExerciseHistory(
      _db,
      userId: userId,
      exerciseId: exerciseId,
      limit: limit,
    );
  }
}
