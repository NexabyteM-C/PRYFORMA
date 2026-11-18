// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationMember _$OrganizationMemberFromJson(Map<String, dynamic> json) =>
    _OrganizationMember(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.parse(json['joined_at'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      organization: json['organization'] == null
          ? null
          : Organization.fromJson(json['organization'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrganizationMemberToJson(_OrganizationMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'user_id': instance.userId,
      'role': instance.role,
      'status': instance.status,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'user': instance.user,
      'organization': instance.organization,
    };
