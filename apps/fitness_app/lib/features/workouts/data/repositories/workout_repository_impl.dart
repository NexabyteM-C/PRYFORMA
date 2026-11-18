import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_datasource.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDatasource _remote;
  WorkoutRepositoryImpl(this._remote);

  @override
  Future<List<WorkoutSession>> list() async {
    final items = await _remote.list();
    return items.map(WorkoutSession.fromJson).toList();
  }

  @override
  Future<WorkoutSession> getById(String id) async {
    final data = await _remote.getById(id);
    return WorkoutSession.fromJson(data);
  }

  @override
  Future<WorkoutSession> create(WorkoutSession session) async {
    final data = await _remote.create(session.toJson());
    return WorkoutSession.fromJson(data);
  }
}
