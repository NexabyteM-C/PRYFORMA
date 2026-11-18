// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSession _$WorkoutSessionFromJson(Map<String, dynamic> json) =>
    _WorkoutSession(
      id: json['id'] as String,
      athleteId: json['athlete_id'] as String,
      organizationId: json['organization_id'] as String?,
      classSessionId: json['class_session_id'] as String?,
      title: json['title'] as String?,
      notes: json['notes'] as String?,
      performedAt: DateTime.parse(json['performed_at'] as String),
      durationMs: (json['duration_ms'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'completed',
      clientId: json['client_id'] as String?,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutSessionToJson(_WorkoutSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'athlete_id': instance.athleteId,
      'organization_id': instance.organizationId,
      'class_session_id': instance.classSessionId,
      'title': instance.title,
      'notes': instance.notes,
      'performed_at': instance.performedAt.toIso8601String(),
      'duration_ms': instance.durationMs,
      'status': instance.status,
      'client_id': instance.clientId,
      'exercises': instance.exercises,
    };

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      exerciseId: json['exercise_id'] as String,
      variantId: json['variant_id'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      notes: json['notes'] as String?,
      exercise: json['exercise'] == null
          ? null
          : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List<dynamic>?)
          ?.map((e) => PerformanceSet.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'exercise_id': instance.exerciseId,
      'variant_id': instance.variantId,
      'sort_order': instance.sortOrder,
      'notes': instance.notes,
      'exercise': instance.exercise,
      'sets': instance.sets,
    };
