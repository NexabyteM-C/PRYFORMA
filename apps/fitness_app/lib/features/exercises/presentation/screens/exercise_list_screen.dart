import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise_card.dart';

/// (label, slug) pairs for the category filter. null slug = "Todos".
const _categories = <(String, String?)>[
  ('Todos', null),
  ('Halterofilia', 'halterofilia'),
  ('Fuerza', 'fuerza'),
  ('Gimnasia', 'gimnasia'),
  ('Funcional', 'funcional'),
  ('Cardio', 'cardio'),
];

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseListProvider);
    final selectedCategory = ref.watch(exerciseCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const FitBackButton(fallbackLocation: '/athlete/train'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ejercicios',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.56,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(exerciseSearchQueryProvider.notifier).state = value;
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicio...',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(exerciseSearchQueryProvider.notifier)
                                .state = '';
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final (label, slug) = _categories[i];
                    final selected = slug == selectedCategory;
                    return GestureDetector(
                      onTap: () => ref
                          .read(exerciseCategoryProvider.notifier)
                          .state = slug,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: exercises.when(
                  data: (list) => list.isEmpty
                      ? Center(
                          child: Text('No se encontraron ejercicios',
                              style:
                                  TextStyle(color: AppColors.textSecondary)))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.92,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) => ExerciseCard(
                            exercise: list[index],
                            onTap: () => context.push(
                                '/athlete/train/exercise/${list[index].id}'),
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                      child: Text('Error: $e',
                          style: TextStyle(
                              color: AppColors.textSecondary))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
