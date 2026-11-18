import 'package:domain_models/domain_models.dart';

import '../../domain/repositories/programming_repository.dart';
import '../datasources/programming_remote_datasource.dart';

class ProgrammingRepositoryImpl implements ProgrammingRepository {
  final ProgrammingRemoteDatasource _remote;
  ProgrammingRepositoryImpl(this._remote);

  @override
  Future<List<ClassProgram>> list(String orgId) async {
    final items = await _remote.list(orgId);
    return items.map(ClassProgram.fromJson).toList();
  }

  @override
  Future<ClassProgram> getById(String orgId, String programId) async {
    final data = await _remote.getById(programId);
    return ClassProgram.fromJson(data);
  }

  @override
  Future<ClassProgram> create(String orgId, ClassProgram program) async {
    final data = await _remote.create(orgId, program.toJson());
    return ClassProgram.fromJson(data);
  }

  @override
  Future<ClassProgram> update(String orgId, ClassProgram program) async {
    final data = await _remote.update(program.id, program.toJson());
    return ClassProgram.fromJson(data);
  }

  @override
  Future<void> publish(
    String orgId,
    String programId, {
    DateTime? scheduledAt,
  }) async {
    await _remote.publish(programId, scheduledAt: scheduledAt);
  }
}
