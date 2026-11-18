import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/class_repository.dart';
import '../datasources/class_remote_datasource.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDatasource _remote;
  ClassRepositoryImpl(this._remote);

  @override
  Future<List<ClassSession>> calendar({required DateTime weekStart}) async {
    final start = weekStart.toIso8601String().substring(0, 10);
    final end = weekStart.add(const Duration(days: 7)).toIso8601String().substring(0, 10);
    final items = await _remote.calendar(weekStart: start, weekEnd: end);
    return items.map(ClassSession.fromJson).toList();
  }

  @override
  Future<ClassProgram> getProgram(String programId) async {
    final data = await _remote.getProgram(programId);
    return ClassProgram.fromJson(data);
  }

  @override
  Future<void> submitResults(String sessionId, Map<String, dynamic> results) async {
    await _remote.submitResults(sessionId, results);
  }
}
