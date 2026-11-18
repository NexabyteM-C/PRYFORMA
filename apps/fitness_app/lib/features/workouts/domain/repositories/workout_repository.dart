import 'package:domain_models/domain_models.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutSession>> list();
  Future<WorkoutSession> getById(String id);
  Future<WorkoutSession> create(WorkoutSession session);
}
