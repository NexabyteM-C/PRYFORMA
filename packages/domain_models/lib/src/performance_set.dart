import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_set.freezed.dart';
part 'performance_set.g.dart';

@freezed
abstract class PerformanceSet with _$PerformanceSet {
  const factory PerformanceSet({
    required String id,
    required String workoutExerciseId,
    required int setNumber,
    double? weightKg,
    int? reps,
    int? durationMs,
    double? distanceM,
    int? calories,
    double? rpe,
    @Default(false) bool isWarmup,
  }) = _PerformanceSet;

  factory PerformanceSet.fromJson(Map<String, dynamic> json) =>
      _$PerformanceSetFromJson(json);
}

@freezed
abstract class PerformanceAttempt with _$PerformanceAttempt {
  const factory PerformanceAttempt({
    required String id,
    required String workoutExerciseId,
    required int attemptNumber,
    required double targetWeightKg,
    required bool success,
    required DateTime performedAt,
  }) = _PerformanceAttempt;

  factory PerformanceAttempt.fromJson(Map<String, dynamic> json) =>
      _$PerformanceAttemptFromJson(json);
}
