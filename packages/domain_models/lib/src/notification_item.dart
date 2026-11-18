import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String eventType,
    required String eventId,
    required String userId,
    required String channel,
    @Default('pending') String status,
    required String title,
    required String body,
    Map<String, dynamic>? dataJson,
    DateTime? sentAt,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}
