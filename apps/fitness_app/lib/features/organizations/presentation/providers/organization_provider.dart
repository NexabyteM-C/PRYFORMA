import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/organization_remote_datasource.dart';
import '../../data/repositories/organization_repository_impl.dart';
import '../../domain/repositories/organization_repository.dart';
import 'membership_provider.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return OrganizationRepositoryImpl(OrganizationRemoteDatasource(supabase));
});

/// Direct datasource access for admin CRUD operations.
final organizationDatasourceProvider = Provider<OrganizationRemoteDatasource>((
  ref,
) {
  return OrganizationRemoteDatasource(ref.watch(supabaseProvider));
});

/// Boxes the signed-in user belongs to (athlete-facing "Mis Boxes").
final myOrganizationsProvider = FutureProvider<List<Organization>>((ref) {
  final repo = ref.watch(organizationRepositoryProvider);
  return repo.list();
});

/// Legacy manual selection (kept for compatibility with other features).
final currentOrgProvider = StateProvider<Organization?>((ref) => null);

/// The org the admin experience currently operates on.
///
/// Prefers the coordinator-managed [currentAdminOrgProvider]; falls back to the
/// first admin-capable membership so screens render real data even before a box
/// is explicitly selected.
final resolvedAdminOrgProvider = Provider<Organization?>((ref) {
  final selected = ref.watch(currentAdminOrgProvider);
  if (selected != null) return selected;
  final adminMemberships = ref.watch(adminMembershipsProvider);
  if (adminMemberships.isNotEmpty) {
    return adminMemberships.first.organization;
  }
  return null;
});

/// Full detail (with locations + member count) for a single organization.
final organizationDetailProvider = FutureProvider.family<Organization, String>((
  ref,
  orgId,
) async {
  final ds = ref.watch(organizationDatasourceProvider);
  final data = await ds.getById(orgId);
  return Organization.fromJson(data);
});

/// Active members of an organization.
final organizationMembersProvider =
    FutureProvider.family<List<OrganizationMember>, String>((ref, orgId) async {
      final ds = ref.watch(organizationDatasourceProvider);
      final rows = await ds.members(orgId);
      return rows.map(OrganizationMember.fromJson).toList();
    });
