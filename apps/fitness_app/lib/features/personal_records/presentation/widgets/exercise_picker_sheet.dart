import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../exercises/data/datasources/exercise_remote_datasource.dart';
import '../pr_formatting.dart';

/// Searchable exercise list backed by the exercises catalog.
final _exercisePickerProvider =
    FutureProvider.autoDispose.family<List<Exercise>, String>((ref, query) async {
  final ds = ExerciseRemoteDatasource(ref.watch(supabaseProvider));
  final rows = await ds.list(search: query.isEmpty ? null : query);
  return rows.map(Exercise.fromJson).toList();
});

/// Presents a modal bottom sheet to pick an exercise from the catalog.
Future<Exercise?> showExercisePicker(BuildContext context) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExercisePickerSheet(),
  );
}

class _ExercisePickerSheet extends ConsumerStatefulWidget {
  const _ExercisePickerSheet();

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final asyncExercises = ref.watch(_exercisePickerProvider(_query));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        'Elegir ejercicio',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    autofocus: false,
                    onChanged: (v) => setState(() => _query = v),
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Buscar ejercicio...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: asyncExercises.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No se pudieron cargar los ejercicios.\n$e',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    data: (exercises) {
                      if (exercises.isEmpty) {
                        return Center(
                          child: Text(
                            'Sin resultados',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: exercises.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final ex = exercises[i];
                          return Material(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.of(context).pop(ex),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.fitness_center_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exerciseBilingual(
                                                ex.nameEs, ex.name),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            categoryLabel(ex.category),
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
