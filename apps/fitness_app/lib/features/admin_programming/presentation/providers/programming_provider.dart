import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/networking/supabase_client.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../../data/datasources/programming_remote_datasource.dart';
import '../../data/repositories/programming_repository_impl.dart';
import '../../domain/repositories/programming_repository.dart';

final programmingRepositoryProvider = Provider<ProgrammingRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProgrammingRepositoryImpl(ProgrammingRemoteDatasource(supabase));
});

/// Direct datasource access for the program editor's CRUD flow.
final programmingDatasourceProvider = Provider<ProgrammingRemoteDatasource>((
  ref,
) {
  return ProgrammingRemoteDatasource(ref.watch(supabaseProvider));
});

final programmingListProvider = FutureProvider<List<ClassProgram>>((ref) {
  final repo = ref.watch(programmingRepositoryProvider);
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) return Future.value([]);
  return repo.list(org.id);
});

final programmingDetailProvider = FutureProvider.family<ClassProgram, String>((
  ref,
  programId,
) {
  final repo = ref.watch(programmingRepositoryProvider);
  final org = ref.watch(resolvedAdminOrgProvider);
  if (org == null) throw Exception('Sin organización seleccionada');
  return repo.getById(org.id, programId);
});
