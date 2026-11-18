import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../organizations/presentation/providers/organization_provider.dart';

/// Active members of the current admin org.
final adminAthletesProvider = FutureProvider<List<OrganizationMember>>((
  ref,
) async {
  final ds = ref.watch(organizationDatasourceProvider);
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) return [];
  final rows = await ds.members(org.id);
  return rows.map(OrganizationMember.fromJson).toList();
});
