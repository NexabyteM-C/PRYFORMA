import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_profile.freezed.dart';
part 'athlete_profile.g.dart';

@freezed
abstract class AthleteProfile with _$AthleteProfile {
  const factory AthleteProfile({
    required String userId,
    @Default('beginner') String experienceLevel,
    @Default('kg') String preferredUnit,
    String? primarySport,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
  }) = _AthleteProfile;

  factory AthleteProfile.fromJson(Map<String, dynamic> json) =>
      _$AthleteProfileFromJson(json);
}
