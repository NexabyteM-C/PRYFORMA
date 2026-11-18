import 'package:domain_models/domain_models.dart';

abstract class GoalRepository {
  Future<List<Goal>> list();
  Future<Goal> getById(String id);
  Future<Goal> create(Goal goal);
  Future<Goal> update(Goal goal);
}
