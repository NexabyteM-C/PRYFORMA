import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/pr_repository.dart';
import '../datasources/pr_remote_datasource.dart';

class PrRepositoryImpl implements PrRepository {
  final PrRemoteDatasource _remote;
  PrRepositoryImpl(this._remote);

  @override
  Future<List<PersonalRecord>> list() async {
    final items = await _remote.list();
    return items.map(PersonalRecord.fromJson).toList();
  }

  @override
  Future<List<PersonalRecord>> byExercise(String exerciseId) async {
    final items = await _remote.byExercise(exerciseId);
    return items.map(PersonalRecord.fromJson).toList();
  }
}
