// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PerformanceSet _$PerformanceSetFromJson(Map<String, dynamic> json) =>
    _PerformanceSet(
      id: json['id'] as String,
      workoutExerciseId: json['workout_exercise_id'] as String,
      setNumber: (json['set_number'] as num).toInt(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      reps: (json['reps'] as num?)?.toInt(),
      durationMs: (json['duration_ms'] as num?)?.toInt(),
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      calories: (json['calories'] as num?)?.toInt(),
      rpe: (json['rpe'] as num?)?.toDouble(),
      isWarmup: json['is_warmup'] as bool? ?? false,
    );

Map<String, dynamic> _$PerformanceSetToJson(_PerformanceSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_exercise_id': instance.workoutExerciseId,
      'set_number': instance.setNumber,
      'weight_kg': instance.weightKg,
      'reps': instance.reps,
      'duration_ms': instance.durationMs,
      'distance_m': instance.distanceM,
      'calories': instance.calories,
      'rpe': instance.rpe,
      'is_warmup': instance.isWarmup,
    };

_PerformanceAttempt _$PerformanceAttemptFromJson(Map<String, dynamic> json) =>
    _PerformanceAttempt(
      id: json['id'] as String,
      workoutExerciseId: json['workout_exercise_id'] as String,
      attemptNumber: (json['attempt_number'] as num).toInt(),
      targetWeightKg: (json['target_weight_kg'] as num).toDouble(),
      success: json['success'] as bool,
      performedAt: DateTime.parse(json['performed_at'] as String),
    );

Map<String, dynamic> _$PerformanceAttemptToJson(_PerformanceAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workout_exercise_id': instance.workoutExerciseId,
      'attempt_number': instance.attemptNumber,
      'target_weight_kg': instance.targetWeightKg,
      'success': instance.success,
      'performed_at': instance.performedAt.toIso8601String(),
    };
