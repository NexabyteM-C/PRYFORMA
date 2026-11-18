import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../datasources/exercise_remote_datasource.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDatasource _remote;
  ExerciseRepositoryImpl(this._remote);

  @override
  Future<List<Exercise>> list({String? search, String? category}) async {
    final items = await _remote.list(search: search, category: category);
    return items.map(Exercise.fromJson).toList();
  }

  @override
  Future<Exercise> getById(String id) async {
    final data = await _remote.getById(id);
    return Exercise.fromJson(data);
  }
}
