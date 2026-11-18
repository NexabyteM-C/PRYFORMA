import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String athleteId,
    String? exerciseId,
    required String title,
    String? description,
    required String goalType,
    String? metricCode,
    double? initialValue,
    required double targetValue,
    double? currentValue,
    String? unit,
    @Default('active') String status,
    DateTime? targetDate,
    DateTime? achievedAt,
    Exercise? exercise,
    List<GoalMilestone>? milestones,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}

@freezed
abstract class GoalMilestone with _$GoalMilestone {
  const factory GoalMilestone({
    required String id,
    required String goalId,
    required double value,
    String? note,
    required DateTime achievedAt,
  }) = _GoalMilestone;

  factory GoalMilestone.fromJson(Map<String, dynamic> json) =>
      _$GoalMilestoneFromJson(json);
}
