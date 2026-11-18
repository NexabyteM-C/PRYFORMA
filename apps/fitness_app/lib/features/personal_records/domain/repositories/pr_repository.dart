import 'package:domain_models/domain_models.dart';

abstract class PrRepository {
  Future<List<PersonalRecord>> list();
  Future<List<PersonalRecord>> byExercise(String exerciseId);
}
