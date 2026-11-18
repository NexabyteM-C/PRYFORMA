import 'package:domain_models/domain_models.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> list({String? search, String? category});
  Future<Exercise> getById(String id);
}
