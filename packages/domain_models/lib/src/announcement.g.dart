// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Announcement _$AnnouncementFromJson(Map<String, dynamic> json) =>
    _Announcement(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      pinned: json['pinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, dynamic>),
      organization: json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AnnouncementToJson(_Announcement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'author_id': instance.authorId,
      'title': instance.title,
      'body': instance.body,
      'published_at': instance.publishedAt?.toIso8601String(),
      'pinned': instance.pinned,
      'created_at': instance.createdAt.toIso8601String(),
      'author': instance.author,
      'organization': instance.organization,
    };
