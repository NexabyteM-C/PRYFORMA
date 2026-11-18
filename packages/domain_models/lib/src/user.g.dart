// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  emailVerifiedAt: json['email_verified_at'] == null
      ? null
      : DateTime.parse(json['email_verified_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
