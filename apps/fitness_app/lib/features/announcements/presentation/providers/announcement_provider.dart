import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../../data/datasources/announcement_remote_datasource.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/repositories/announcement_repository.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AnnouncementRepositoryImpl(AnnouncementRemoteDatasource(supabase));
});

/// Direct datasource access for creating announcements.
final announcementDatasourceProvider = Provider<AnnouncementRemoteDatasource>((
  ref,
) {
  return AnnouncementRemoteDatasource(ref.watch(supabaseProvider));
});

/// Announcements for the current admin org, pinned first then newest first.
final announcementListProvider = FutureProvider<List<Announcement>>((
  ref,
) async {
  final repo = ref.watch(announcementRepositoryProvider);
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) return [];
  final list = await repo.list(org.id);
  final sorted = [...list];
  sorted.sort((a, b) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
    return b.createdAt.compareTo(a.createdAt);
  });
  return sorted;
});
