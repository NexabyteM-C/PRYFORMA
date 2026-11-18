import 'package:domain_models/domain_models.dart';

import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_remote_datasource.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final OrganizationRemoteDatasource _remote;
  OrganizationRepositoryImpl(this._remote);

  @override
  Future<List<Organization>> list() async {
    final items = await _remote.list();
    return items.map(Organization.fromJson).toList();
  }

  @override
  Future<Organization> getById(String id) async {
    final data = await _remote.getById(id);
    return Organization.fromJson(data);
  }

  @override
  Future<List<OrganizationMember>> members(String orgId) async {
    final items = await _remote.members(orgId);
    return items.map(OrganizationMember.fromJson).toList();
  }

  @override
  Future<void> join(String invitationCode) async {
    await _remote.join(invitationCode);
  }
}
