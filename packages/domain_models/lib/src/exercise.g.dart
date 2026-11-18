// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  id: json['id'] as String,
  name: json['name'] as String,
  nameEs: json['name_es'] as String?,
  category: json['category'] as String,
  description: json['description'] as String?,
  status: json['status'] as String? ?? 'active',
  isGlobal: json['is_global'] as bool? ?? true,
  createdBy: json['created_by'] as String?,
  variants: (json['variants'] as List<dynamic>?)
      ?.map((e) => ExerciseVariant.fromJson(e as Map<String, dynamic>))
      .toList(),
  metricDefinitions: (json['metric_definitions'] as List<dynamic>?)
      ?.map((e) => ExerciseMetricDefinition.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'name_es': instance.nameEs,
  'category': instance.category,
  'description': instance.description,
  'status': instance.status,
  'is_global': instance.isGlobal,
  'created_by': instance.createdBy,
  'variants': instance.variants,
  'metric_definitions': instance.metricDefinitions,
};

_ExerciseVariant _$ExerciseVariantFromJson(Map<String, dynamic> json) =>
    _ExerciseVariant(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String,
      name: json['name'] as String,
      variantType: json['variant_type'] as String?,
    );

Map<String, dynamic> _$ExerciseVariantToJson(_ExerciseVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercise_id': instance.exerciseId,
      'name': instance.name,
      'variant_type': instance.variantType,
    };

_ExerciseMetricDefinition _$ExerciseMetricDefinitionFromJson(
  Map<String, dynamic> json,
) => _ExerciseMetricDefinition(
  id: json['id'] as String,
  exerciseId: json['exercise_id'] as String,
  metricCode: json['metric_code'] as String,
  valueType: json['value_type'] as String,
  unit: json['unit'] as String?,
  isPrimary: json['is_primary'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseMetricDefinitionToJson(
  _ExerciseMetricDefinition instance,
) => <String, dynamic>{
  'id': instance.id,
  'exercise_id': instance.exerciseId,
  'metric_code': instance.metricCode,
  'value_type': instance.valueType,
  'unit': instance.unit,
  'is_primary': instance.isPrimary,
};
