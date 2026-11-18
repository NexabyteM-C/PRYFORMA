// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Organization _$OrganizationFromJson(Map<String, dynamic> json) =>
    _Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      status: json['status'] as String? ?? 'active',
      ownerUserId: json['owner_user_id'] as String,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => OrganizationLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrganizationToJson(_Organization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'status': instance.status,
      'owner_user_id': instance.ownerUserId,
      'locations': instance.locations,
    };

_OrganizationLocation _$OrganizationLocationFromJson(
  Map<String, dynamic> json,
) => _OrganizationLocation(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  address: json['address'] as String?,
  city: json['city'] as String?,
  country: json['country'] as String?,
  isPrimary: json['is_primary'] as bool? ?? false,
);

Map<String, dynamic> _$OrganizationLocationToJson(
  _OrganizationLocation instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'timezone': instance.timezone,
  'address': instance.address,
  'city': instance.city,
  'country': instance.country,
  'is_primary': instance.isPrimary,
};
