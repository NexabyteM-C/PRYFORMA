import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';

const _categoryLabels = {
  'halterofilia': 'Halterofilia',
  'fuerza': 'Fuerza',
  'gimnasia': 'Gimnasia',
  'funcional': 'Funcional',
  'cardio': 'Cardio',
};

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise, this.onTap});

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = exerciseBilingual(exercise.nameEs, exercise.name);
    final categoryLabel =
        _categoryLabels[exercise.category] ?? exercise.category;

    final metrics = exercise.metricDefinitions ?? const [];
    ExerciseMetricDefinition? primary;
    for (final m in metrics) {
      if (m.isPrimary) {
        primary = m;
        break;
      }
    }
    primary ??= metrics.isNotEmpty ? metrics.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.fitness_center_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    categoryLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ),
                if (primary != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.straighten_rounded,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            primary.unit ?? primary.metricCode,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
