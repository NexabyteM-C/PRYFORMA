import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization.dart';
import 'user.dart';

part 'announcement.freezed.dart';
part 'announcement.g.dart';

@freezed
abstract class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String organizationId,
    required String authorId,
    required String title,
    required String body,
    DateTime? publishedAt,
    @Default(false) bool pinned,
    required DateTime createdAt,
    User? author,
    Organization? organization,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}
