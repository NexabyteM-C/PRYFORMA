import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';
import 'performance_set.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
abstract class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required String id,
    required String athleteId,
    String? organizationId,
    String? classSessionId,
    String? title,
    String? notes,
    required DateTime performedAt,
    int? durationMs,
    @Default('completed') String status,
    String? clientId,
    List<WorkoutExercise>? exercises,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

@freezed
abstract class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    required String id,
    required String sessionId,
    required String exerciseId,
    String? variantId,
    required int sortOrder,
    String? notes,
    Exercise? exercise,
    List<PerformanceSet>? sets,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}
