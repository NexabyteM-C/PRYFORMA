// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalRecord _$PersonalRecordFromJson(Map<String, dynamic> json) =>
    _PersonalRecord(
      id: json['id'] as String,
      athleteId: json['athlete_id'] as String,
      exerciseId: json['exercise_id'] as String,
      variantId: json['variant_id'] as String?,
      recordType: json['record_type'] as String,
      valueNumeric: (json['value_numeric'] as num).toDouble(),
      resultSourceId: json['result_source_id'] as String?,
      markType: json['mark_type'] as String? ?? 'real',
      achievedAt: DateTime.parse(json['achieved_at'] as String),
      exercise: json['exercise'] == null
          ? null
          : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PersonalRecordToJson(_PersonalRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'athlete_id': instance.athleteId,
      'exercise_id': instance.exerciseId,
      'variant_id': instance.variantId,
      'record_type': instance.recordType,
      'value_numeric': instance.valueNumeric,
      'result_source_id': instance.resultSourceId,
      'mark_type': instance.markType,
      'achieved_at': instance.achievedAt.toIso8601String(),
      'exercise': instance.exercise,
    };
