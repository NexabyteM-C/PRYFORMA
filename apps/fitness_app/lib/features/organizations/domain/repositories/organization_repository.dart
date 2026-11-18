import 'package:domain_models/domain_models.dart';

abstract class OrganizationRepository {
  Future<List<Organization>> list();
  Future<Organization> getById(String id);
  Future<List<OrganizationMember>> members(String orgId);
  Future<void> join(String invitationCode);
}
