import 'package:domain_models/domain_models.dart';

abstract class ProgrammingRepository {
  Future<List<ClassProgram>> list(String orgId);
  Future<ClassProgram> getById(String orgId, String programId);
  Future<ClassProgram> create(String orgId, ClassProgram program);
  Future<ClassProgram> update(String orgId, ClassProgram program);
  Future<void> publish(String orgId, String programId, {DateTime? scheduledAt});
}
