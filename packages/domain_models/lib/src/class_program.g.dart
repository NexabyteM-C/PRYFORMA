// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_program.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassProgram _$ClassProgramFromJson(Map<String, dynamic> json) =>
    _ClassProgram(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      locationId: json['location_id'] as String,
      templateId: json['template_id'] as String?,
      programDate: DateTime.parse(json['program_date'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      focusTags:
          (json['focus_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      objective: json['objective'] as String?,
      coachNotes: json['coach_notes'] as String?,
      status: json['status'] as String? ?? 'draft',
      scheduledPublishAt: json['scheduled_publish_at'] == null
          ? null
          : DateTime.parse(json['scheduled_publish_at'] as String),
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      createdBy: json['created_by'] as String,
      currentVersion: (json['current_version'] as num?)?.toInt() ?? 1,
      blocks: (json['blocks'] as List<dynamic>?)
          ?.map((e) => ClassProgramBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      sessions: (json['sessions'] as List<dynamic>?)
          ?.map((e) => ClassSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      organization: json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : OrganizationLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ClassProgramToJson(_ClassProgram instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'location_id': instance.locationId,
      'template_id': instance.templateId,
      'program_date': instance.programDate.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'focus_tags': instance.focusTags,
      'objective': instance.objective,
      'coach_notes': instance.coachNotes,
      'status': instance.status,
      'scheduled_publish_at': instance.scheduledPublishAt?.toIso8601String(),
      'published_at': instance.publishedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'current_version': instance.currentVersion,
      'blocks': instance.blocks,
      'sessions': instance.sessions,
      'organization': instance.organization,
      'location': instance.location,
    };

_ClassProgramBlock _$ClassProgramBlockFromJson(Map<String, dynamic> json) =>
    _ClassProgramBlock(
      id: json['id'] as String,
      programId: json['program_id'] as String,
      blockType: json['block_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      sortOrder: (json['sort_order'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => ClassBlockExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassProgramBlockToJson(_ClassProgramBlock instance) =>
    <String, dynamic>{
      'id': instance.id,
      'program_id': instance.programId,
      'block_type': instance.blockType,
      'title': instance.title,
      'description': instance.description,
      'duration_minutes': instance.durationMinutes,
      'sort_order': instance.sortOrder,
      'exercises': instance.exercises,
    };

_ClassBlockExercise _$ClassBlockExerciseFromJson(Map<String, dynamic> json) =>
    _ClassBlockExercise(
      id: json['id'] as String,
      blockId: json['block_id'] as String,
      exerciseId: json['exercise_id'] as String,
      variantId: json['variant_id'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
      sets: (json['sets'] as num?)?.toInt(),
      reps: json['reps'] as String?,
      weightPrescription: json['weight_prescription'] as String?,
      durationMs: (json['duration_ms'] as num?)?.toInt(),
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      exercise: json['exercise'] == null
          ? null
          : Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClassBlockExerciseToJson(_ClassBlockExercise instance) =>
    <String, dynamic>{
      'id': instance.id,
      'block_id': instance.blockId,
      'exercise_id': instance.exerciseId,
      'variant_id': instance.variantId,
      'sort_order': instance.sortOrder,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight_prescription': instance.weightPrescription,
      'duration_ms': instance.durationMs,
      'distance_m': instance.distanceM,
      'notes': instance.notes,
      'exercise': instance.exercise,
    };
