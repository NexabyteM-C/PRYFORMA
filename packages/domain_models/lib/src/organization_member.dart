import 'package:freezed_annotation/freezed_annotation.dart';

import 'organization.dart';
import 'user.dart';

part 'organization_member.freezed.dart';
part 'organization_member.g.dart';

@freezed
abstract class OrganizationMember with _$OrganizationMember {
  const factory OrganizationMember({
    required String id,
    required String organizationId,
    required String userId,
    required String role,
    @Default('active') String status,
    DateTime? joinedAt,
    User? user,
    Organization? organization,
  }) = _OrganizationMember;

  factory OrganizationMember.fromJson(Map<String, dynamic> json) =>
      _$OrganizationMemberFromJson(json);
}
