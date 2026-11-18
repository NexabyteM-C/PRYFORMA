// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassSession _$ClassSessionFromJson(Map<String, dynamic> json) =>
    _ClassSession(
      id: json['id'] as String,
      programId: json['program_id'] as String,
      locationId: json['location_id'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      coaches: (json['coaches'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ClassSessionToJson(_ClassSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'program_id': instance.programId,
      'location_id': instance.locationId,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'capacity': instance.capacity,
      'coaches': instance.coaches,
    };
