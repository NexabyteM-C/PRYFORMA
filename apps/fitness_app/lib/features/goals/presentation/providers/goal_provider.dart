import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/goal_remote_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return GoalRepositoryImpl(GoalRemoteDatasource(supabase));
});

/// Direct datasource access for mutations (create/update/delete).
final goalRemoteProvider = Provider<GoalRemoteDatasource>((ref) {
  return GoalRemoteDatasource(ref.watch(supabaseProvider));
});

final goalListProvider = FutureProvider<List<Goal>>((ref) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.list();
});

final goalDetailProvider = FutureProvider.family<Goal, String>((ref, id) {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getById(id);
});
