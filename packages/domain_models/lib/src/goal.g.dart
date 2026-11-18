// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: json['id'] as String,
  athleteId: json['athlete_id'] as String,
  exerciseId: json['exercise_id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  goalType: json['goal_type'] as String,
  metricCode: json['metric_code'] as String?,
  initialValue: (json['initial_value'] as num?)?.toDouble(),
  targetValue: (json['target_value'] as num).toDouble(),
  currentValue: (json['current_value'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
  status: json['status'] as String? ?? 'active',
  targetDate: json['target_date'] == null
      ? null
      : DateTime.parse(json['target_date'] as String),
  achievedAt: json['achieved_at'] == null
      ? null
      : DateTime.parse(json['achieved_at'] as String),
  exercise: json['exercise'] == null
      ? null
      : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
  milestones: (json['milestones'] as List<dynamic>?)
      ?.map((e) => GoalMilestone.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'athlete_id': instance.athleteId,
  'exercise_id': instance.exerciseId,
  'title': instance.title,
  'description': instance.description,
  'goal_type': instance.goalType,
  'metric_code': instance.metricCode,
  'initial_value': instance.initialValue,
  'target_value': instance.targetValue,
  'current_value': instance.currentValue,
  'unit': instance.unit,
  'status': instance.status,
  'target_date': instance.targetDate?.toIso8601String(),
  'achieved_at': instance.achievedAt?.toIso8601String(),
  'exercise': instance.exercise,
  'milestones': instance.milestones,
};

_GoalMilestone _$GoalMilestoneFromJson(Map<String, dynamic> json) =>
    _GoalMilestone(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      value: (json['value'] as num).toDouble(),
      note: json['note'] as String?,
      achievedAt: DateTime.parse(json['achieved_at'] as String),
    );

Map<String, dynamic> _$GoalMilestoneToJson(_GoalMilestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goal_id': instance.goalId,
      'value': instance.value,
      'note': instance.note,
      'achieved_at': instance.achievedAt.toIso8601String(),
    };
