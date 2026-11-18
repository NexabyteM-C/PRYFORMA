import 'package:freezed_annotation/freezed_annotation.dart';

part 'organization.freezed.dart';
part 'organization.g.dart';

@freezed
abstract class Organization with _$Organization {
  const factory Organization({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? logoUrl,
    @Default('active') String status,
    required String ownerUserId,
    List<OrganizationLocation>? locations,
  }) = _Organization;

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);
}

@freezed
abstract class OrganizationLocation with _$OrganizationLocation {
  const factory OrganizationLocation({
    required String id,
    required String organizationId,
    required String name,
    required String timezone,
    String? address,
    String? city,
    String? country,
    @Default(false) bool isPrimary,
  }) = _OrganizationLocation;

  factory OrganizationLocation.fromJson(Map<String, dynamic> json) =>
      _$OrganizationLocationFromJson(json);
}
