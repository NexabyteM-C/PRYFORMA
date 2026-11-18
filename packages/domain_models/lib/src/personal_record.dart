import 'package:freezed_annotation/freezed_annotation.dart';

import 'exercise.dart';

part 'personal_record.freezed.dart';
part 'personal_record.g.dart';

@freezed
abstract class PersonalRecord with _$PersonalRecord {
  const factory PersonalRecord({
    required String id,
    required String athleteId,
    required String exerciseId,
    String? variantId,
    required String recordType,
    required double valueNumeric,
    String? resultSourceId,
    @Default('real') String markType,
    required DateTime achievedAt,
    Exercise? exercise,
  }) = _PersonalRecord;

  factory PersonalRecord.fromJson(Map<String, dynamic> json) =>
      _$PersonalRecordFromJson(json);
}
