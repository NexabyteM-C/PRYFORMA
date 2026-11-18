import '../db/database.dart';
import '../db/queries/exercise_queries.dart' as q;

class ExerciseService {
  final Database _db;

  ExerciseService(this._db);

  Future<List<Map<String, dynamic>>> listExercises({
    String? search,
    String? category,
    int limit = 50,
    int offset = 0,
  }) {
    return q.listExercises(
      _db,
      search: search,
      category: category,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> countExercises({String? search, String? category}) {
    return q.countExercises(_db, search: search, category: category);
  }

  Future<Map<String, dynamic>?> getExercise(String exerciseId) {
    return q.findExerciseById(_db, exerciseId);
  }
}
