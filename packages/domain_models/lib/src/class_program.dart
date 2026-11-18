import 'package:freezed_annotation/freezed_annotation.dart';

import 'class_session.dart';
import 'exercise.dart';
import 'organization.dart';

part 'class_program.freezed.dart';
part 'class_program.g.dart';

@freezed
abstract class ClassProgram with _$ClassProgram {
  const factory ClassProgram({
    required String id,
    required String organizationId,
    required String locationId,
    String? templateId,
    required DateTime programDate,
    required String title,
    String? description,
    @Default([]) List<String> focusTags,
    String? objective,
    String? coachNotes,
    @Default('draft') String status,
    DateTime? scheduledPublishAt,
    DateTime? publishedAt,
    DateTime? cancelledAt,
    required String createdBy,
    @Default(1) int currentVersion,
    List<ClassProgramBlock>? blocks,
    List<ClassSession>? sessions,
    Organization? organization,
    OrganizationLocation? location,
  }) = _ClassProgram;

  factory ClassProgram.fromJson(Map<String, dynamic> json) =>
      _$ClassProgramFromJson(json);
}

@freezed
abstract class ClassProgramBlock with _$ClassProgramBlock {
  const factory ClassProgramBlock({
    required String id,
    required String programId,
    required String blockType,
    required String title,
    String? description,
    int? durationMinutes,
    required int sortOrder,
    List<ClassBlockExercise>? exercises,
  }) = _ClassProgramBlock;

  factory ClassProgramBlock.fromJson(Map<String, dynamic> json) =>
      _$ClassProgramBlockFromJson(json);
}

@freezed
abstract class ClassBlockExercise with _$ClassBlockExercise {
  const factory ClassBlockExercise({
    required String id,
    required String blockId,
    required String exerciseId,
    String? variantId,
    required int sortOrder,
    int? sets,
    String? reps,
    String? weightPrescription,
    int? durationMs,
    double? distanceM,
    String? notes,
    Exercise? exercise,
  }) = _ClassBlockExercise;

  factory ClassBlockExercise.fromJson(Map<String, dynamic> json) =>
      _$ClassBlockExerciseFromJson(json);
}
