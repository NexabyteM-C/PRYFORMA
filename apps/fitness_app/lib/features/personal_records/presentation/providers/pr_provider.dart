import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/pr_remote_datasource.dart';
import '../../data/repositories/pr_repository_impl.dart';
import '../../domain/repositories/pr_repository.dart';

final prRepositoryProvider = Provider<PrRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return PrRepositoryImpl(PrRemoteDatasource(supabase));
});

/// Direct datasource access for mutations (create/delete).
final prRemoteProvider = Provider<PrRemoteDatasource>((ref) {
  return PrRemoteDatasource(ref.watch(supabaseProvider));
});

final prListProvider = FutureProvider<List<PersonalRecord>>((ref) {
  final repo = ref.watch(prRepositoryProvider);
  return repo.list();
});

final prByExerciseProvider =
    FutureProvider.family<List<PersonalRecord>, String>((ref, exerciseId) {
  final repo = ref.watch(prRepositoryProvider);
  return repo.byExercise(exerciseId);
});
