import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_datasource.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDatasource _remote;
  GoalRepositoryImpl(this._remote);

  @override
  Future<List<Goal>> list() async {
    final items = await _remote.list();
    return items.map(Goal.fromJson).toList();
  }

  @override
  Future<Goal> getById(String id) async {
    final data = await _remote.getById(id);
    return Goal.fromJson(data);
  }

  @override
  Future<Goal> create(Goal goal) async {
    final data = await _remote.create(goal.toJson());
    return Goal.fromJson(data);
  }

  @override
  Future<Goal> update(Goal goal) async {
    final data = await _remote.update(goal.id, goal.toJson());
    return Goal.fromJson(data);
  }
}
