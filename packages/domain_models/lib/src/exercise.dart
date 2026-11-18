import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    String? nameEs,
    required String category,
    String? description,
    @Default('active') String status,
    @Default(true) bool isGlobal,
    String? createdBy,
    List<ExerciseVariant>? variants,
    List<ExerciseMetricDefinition>? metricDefinitions,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

@freezed
abstract class ExerciseVariant with _$ExerciseVariant {
  const factory ExerciseVariant({
    required String id,
    required String exerciseId,
    required String name,
    String? variantType,
  }) = _ExerciseVariant;

  factory ExerciseVariant.fromJson(Map<String, dynamic> json) =>
      _$ExerciseVariantFromJson(json);
}

@freezed
abstract class ExerciseMetricDefinition with _$ExerciseMetricDefinition {
  const factory ExerciseMetricDefinition({
    required String id,
    required String exerciseId,
    required String metricCode,
    required String valueType,
    String? unit,
    @Default(false) bool isPrimary,
  }) = _ExerciseMetricDefinition;

  factory ExerciseMetricDefinition.fromJson(Map<String, dynamic> json) =>
      _$ExerciseMetricDefinitionFromJson(json);
}
