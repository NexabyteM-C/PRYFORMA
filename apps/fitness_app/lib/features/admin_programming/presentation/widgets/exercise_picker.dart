import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';

const _categories = <(String?, String)>[
  (null, 'Todas'),
  ('halterofilia', 'Halterofilia'),
  ('fuerza', 'Fuerza'),
  ('gimnasia', 'Gimnasia'),
  ('funcional', 'Funcional'),
  ('cardio', 'Cardio'),
];

/// Opens a modal catalog picker. Returns (exerciseId, displayName) or null.
/// Responsive: a comfortable dialog on wide screens, near-fullscreen on phones.
Future<(String, String)?> showExercisePicker(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final w = size.width < 560 ? size.width - 24 : 520.0;
  final h = size.height < 680 ? size.height * 0.85 : 560.0;
  return showDialog<(String, String)?>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SizedBox(width: w, height: h, child: const _ExercisePickerBody()),
    ),
  );
}

class _ExercisePickerBody extends ConsumerStatefulWidget {
  const _ExercisePickerBody();

  @override
  ConsumerState<_ExercisePickerBody> createState() =>
      _ExercisePickerBodyState();
}

class _ExercisePickerBodyState extends ConsumerState<_ExercisePickerBody> {
  String? _category;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(exerciseListProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Catálogo de ejercicios',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            autofocus: true,
            onChanged: (v) {
              setState(() => _search = v);
              ref.read(exerciseSearchQueryProvider.notifier).state = v;
            },
            decoration: const InputDecoration(
              hintText: 'Buscar ejercicio…',
              prefixIcon: Icon(Icons.search_rounded, size: 20),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = _categories[i];
                final selected = c.$1 == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = c.$1),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      c.$2,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: async.when(
              data: (list) {
                final q = _search.trim().toLowerCase();
                final filtered = list.where((e) {
                  final okCat = _category == null || e.category == _category;
                  // Match either language so English or Spanish queries work.
                  final en = e.name.toLowerCase();
                  final es = (e.nameEs ?? '').toLowerCase();
                  final okSearch =
                      q.isEmpty || en.contains(q) || es.contains(q);
                  return okCat && okSearch;
                }).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin resultados',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _ExerciseRow(exercise: filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final name = exerciseBilingual(exercise.nameEs, exercise.name);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        exercise.category,
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Icons.add_circle_outline_rounded,
        color: AppColors.primary,
        size: 20,
      ),
      onTap: () => Navigator.of(context).pop((exercise.id, name)),
    );
  }
}
