import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/exercise_remote_datasource.dart';
import '../../data/repositories/exercise_repository_impl.dart';
import '../../domain/repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ExerciseRepositoryImpl(ExerciseRemoteDatasource(supabase));
});

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Selected category filter slug, or null for "Todos".
final exerciseCategoryProvider = StateProvider<String?>((ref) => null);

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final category = ref.watch(exerciseCategoryProvider);
  return repo.list(
    search: query.isEmpty ? null : query,
    category: category,
  );
});

final exerciseDetailProvider = FutureProvider.family<Exercise, String>((ref, id) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return repo.getById(id);
});

/// Prescription unit info for a "metered" movement (machines/monostructural),
/// i.e. one whose primary metric is calories or distance. Such movements are
/// prescribed in calories or meters instead of sets×reps×load.
typedef MeteredInfo = ({List<String> units, String primaryUnit});

/// exerciseId → MeteredInfo, for every movement prescribed in cal/m.
/// Built from the full catalog (independent of the picker's search/category
/// filter) so the block editor can switch its fields when such a movement is
/// chosen.
final exerciseMeteredMapProvider =
    FutureProvider<Map<String, MeteredInfo>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final all = await repo.list();
  final map = <String, MeteredInfo>{};
  for (final e in all) {
    final defs = e.metricDefinitions ?? const [];
    final units = <String>[];
    String? primaryUnit;
    for (final d in defs) {
      final u = switch (d.metricCode) {
        'calories' => 'cal',
        'distance' => 'm',
        _ => null,
      };
      if (u == null) continue;
      units.add(u);
      if (d.isPrimary) primaryUnit = u;
    }
    if (primaryUnit == null) continue; // not a metered movement
    final ordered = [
      if (units.contains('cal')) 'cal',
      if (units.contains('m')) 'm',
    ];
    map[e.id] = (units: ordered, primaryUnit: primaryUnit);
  }
  return map;
});

/// The athlete's best personal record for an exercise (raw map), or null.
/// Weight values are stored in kg; callers convert to lb for display.
final exercisePrProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, exerciseId) async {
  final supabase = ref.watch(supabaseProvider);
  final uid = supabase.auth.currentUser?.id;
  if (uid == null) return null;
  final rows = await supabase
      .from('personal_records')
      .select()
      .eq('athlete_id', uid)
      .eq('exercise_id', exerciseId)
      .order('value_numeric', ascending: false)
      .limit(1);
  final list = List<Map<String, dynamic>>.from(rows);
  return list.isEmpty ? null : list.first;
});
