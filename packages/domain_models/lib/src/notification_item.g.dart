// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      eventType: json['event_type'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      channel: json['channel'] as String,
      status: json['status'] as String? ?? 'pending',
      title: json['title'] as String,
      body: json['body'] as String,
      dataJson: json['data_json'] as Map<String, dynamic>?,
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_type': instance.eventType,
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'channel': instance.channel,
      'status': instance.status,
      'title': instance.title,
      'body': instance.body,
      'data_json': instance.dataJson,
      'sent_at': instance.sentAt?.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
