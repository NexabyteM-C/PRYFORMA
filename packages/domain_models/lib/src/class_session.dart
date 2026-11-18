import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'class_session.freezed.dart';
part 'class_session.g.dart';

@freezed
abstract class ClassSession with _$ClassSession {
  const factory ClassSession({
    required String id,
    required String programId,
    required String locationId,
    required String startTime,
    String? endTime,
    int? capacity,
    List<User>? coaches,
  }) = _ClassSession;

  factory ClassSession.fromJson(Map<String, dynamic> json) =>
      _$ClassSessionFromJson(json);
}
