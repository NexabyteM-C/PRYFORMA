// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AthleteProfile _$AthleteProfileFromJson(Map<String, dynamic> json) =>
    _AthleteProfile(
      userId: json['user_id'] as String,
      experienceLevel: json['experience_level'] as String? ?? 'beginner',
      preferredUnit: json['preferred_unit'] as String? ?? 'kg',
      primarySport: json['primary_sport'] as String?,
      dateOfBirth: json['date_of_birth'] == null
          ? null
          : DateTime.parse(json['date_of_birth'] as String),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AthleteProfileToJson(_AthleteProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'experience_level': instance.experienceLevel,
      'preferred_unit': instance.preferredUnit,
      'primary_sport': instance.primarySport,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'height_cm': instance.heightCm,
      'weight_kg': instance.weightKg,
    };
