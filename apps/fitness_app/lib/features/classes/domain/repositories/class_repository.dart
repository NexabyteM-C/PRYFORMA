import 'package:domain_models/domain_models.dart';

abstract class ClassRepository {
  Future<List<ClassSession>> calendar({required DateTime weekStart});
  Future<ClassProgram> getProgram(String programId);
  Future<void> submitResults(String sessionId, Map<String, dynamic> results);
}
