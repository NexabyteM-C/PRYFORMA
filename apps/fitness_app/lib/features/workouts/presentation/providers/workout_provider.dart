import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../classes/data/datasources/class_remote_datasource.dart';
import '../../data/datasources/workout_remote_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';

/// Shared class datasource (used to link a workout to a programmed class).
final workoutClassDatasourceProvider = Provider<ClassRemoteDatasource>((ref) {
  return ClassRemoteDatasource(ref.watch(supabaseProvider));
});

/// Recent programmed classes in the athlete's boxes, for linking a workout.
final recentClassesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(workoutClassDatasourceProvider).recentProgrammedClasses();
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return WorkoutRepositoryImpl(WorkoutRemoteDatasource(supabase));
});

/// Direct datasource access for the multi-step create flow.
final workoutRemoteProvider = Provider<WorkoutRemoteDatasource>((ref) {
  return WorkoutRemoteDatasource(ref.watch(supabaseProvider));
});

final workoutListProvider = FutureProvider<List<WorkoutSession>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.list();
});

final workoutDetailProvider =
    FutureProvider.family<WorkoutSession, String>((ref, id) {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getById(id);
});

class ActiveWorkoutNotifier extends StateNotifier<WorkoutSession?> {
  ActiveWorkoutNotifier() : super(null);

  void start(WorkoutSession session) => state = session;
  void clear() => state = null;
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, WorkoutSession?>((ref) {
  return ActiveWorkoutNotifier();
});
